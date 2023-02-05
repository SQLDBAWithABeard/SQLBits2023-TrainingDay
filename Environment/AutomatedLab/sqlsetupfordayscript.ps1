$secStringPassword = 'dbatools.IO1' | ConvertTo-SecureString -AsPlainText -Force
[pscredential]$cred = New-Object System.Management.Automation.PSCredential ('theboss', $secStringPassword)
[pscredential]$domaincred = New-Object System.Management.Automation.PSCredential ('jessandbeard\theboss', $secStringPassword)

$PSDefaultParameterValues = @{
    '*Ad*:credential' = $cred
}

$SQLHosts = 'Jess2016', 'Jess2017', 'Jess2019'
<#
# needs to be run on DC
if (Get-KdsRootKey) {
    Write-PSFMessage -Level Host -Message "KDS root key exists"
} else {
    Write-PSFMessage -Level Host -Message "Creating KDS root key"
    Add-KdsRootKey -EffectiveImmediately
}

while (-not (Get-KdsRootKey)) {
    Write-PSFMessage -Level Host -Message "Waiting for KDS root key to become effective"
    Start-Sleep -Seconds 5
}

try {
    Test-KdsRootKey -KeyId (Get-KdsRootKey).KeyId -ErrorAction Stop 
    Write-PSFMessage -Level Host -Message "KDS Root key testing correctly"

} catch {
    Write-PSFMessage -Level Host -Message "KDS Root key not testing correctly"
    Break
}

#>
if ($null -eq (Get-ADGroup -Identity SQLInstancesgMSAs)) {
    Write-PSFMessage -Level Host -Message "Creating SQLInstancesgMSAs security group"
    New-ADGroup -Name SQLInstancesgMSAs -Description “Security group for SQLInstances” -GroupCategory Security -GroupScope Global
} else {
    Write-PSFMessage -Level Host -Message "SQLInstancesgMSAs security group already exists"
}

$SQLHosts | ForEach-Object {
    if ((Get-ADGroupMember -Identity SQLInstancesgMSAs).Name -notcontains $_) {
        Write-PSFMessage -Level Host -Message "Adding $($_)$ to SQLInstancesgMSAs security group"
        Add-ADGroupMember -Identity SQLInstancesgMSAs -Members "$_$"
    } else {
        Write-PSFMessage -Level Host -Message "$($_)$ is already a member of SQLInstancesgMSAs security group"
    }
}

try {
    Get-ADServiceAccount -Identity SQLgMSA -ErrorAction Stop | Out-Null
    Write-PSFMessage -Level Host -Message "SQLgMSA service account already exists"
} catch {
    Write-PSFMessage -Level Host -Message "Creating SQLgMSA service account"
    New-ADServiceAccount -Name SQLgMSA -PrincipalsAllowedToRetrieveManagedPassword SQLInstancesgMSAs -Enabled:$true -DNSHostName SQLgMSA.jessandbeard.local -SamAccountName SQLgMSA -ManagedPasswordIntervalInDays 90
} 

$dbatoolsmodulebase = (Get-Module dbatools -ListAvailable | select -First 1 | select modulebase).modulebase
$PsFrameworkmodulebase = (Get-Module PSFramework -ListAvailable | select -First 1 | select modulebase).modulebase

$SQLHosts | ForEach-Object {
    $session = New-PSSession -ComputerName $_ -Credential $domaincred
    Write-Host "Copying modules over to $($_)"
     Copy-Item $dbatoolsmodulebase  -ToSession $session -Destination $dbatoolsmodulebase -Recurse -Force
      Copy-Item $PsFrameworkmodulebase  -ToSession $session -Destination $PsFrameworkmodulebase -Recurse -Force
}
# Run the SQL Server as the gMSA
$SQLHosts | ForEach-Object {
    $message = "Update {0} to use the SQLgMSA service account" -f $_
    Write-PSFMessage -Level Host -Message $message
    Invoke-Command {
        $secStringPassword = 'dbatools.IO1' | ConvertTo-SecureString -AsPlainText -Force
        [pscredential]$cred = New-Object System.Management.Automation.PSCredential ('theboss', $secStringPassword)
        [pscredential]$domaincred = New-Object System.Management.Automation.PSCredential ('jessandbeard\theboss', $secStringPassword)
        if ((Get-DbaService -SqlInstance localhost -Type Engine).StartName -ne 'jessandbeard\SQLgMSA$') {
            Update-DbaServiceAccount -ComputerName localhost -Credential $domaincred -ServiceName MSSQLSERVER -Username 'jessandbeard\SQLgMSA$'
        } 
    } -ComputerName $_ -Credential $domaincred
}

# Set up the SPNs
# Thank you Jess https://jesspomfret.com/spn-troubles/

$SQLHosts | ForEach-Object {
    $SQLHost = $PSItem
    $secStringPassword = 'dbatools.IO1' | ConvertTo-SecureString -AsPlainText -Force
    [pscredential]$cred = New-Object System.Management.Automation.PSCredential ('theboss', $secStringPassword)
    [pscredential]$domaincred = New-Object System.Management.Automation.PSCredential ('jessandbeard\theboss', $secStringPassword)
    $SPNs = Test-DbaSpn -ComputerName $SQLHost -Credential $domaincred 
    if (($Spns | Where-Object { $psitem.IsSet -eq $false }).Count -gt 0) {
        $message = "Remove SPNs for {0}" -f $_
        Write-PSFMessage -Level Host -Message $message
        Invoke-Command { param($SQLHost)
            setspn -d MSSQLSvc/$SQLHost.jessandbeard.local $SQLHost
            setspn -d MSSQLSvc/$SQLHost.jessandbeard.local:1433 $SQLHost
        } -ComputerName JessDC1 -Credential $domaincred -ArgumentList $SQLHost
    } else {
        $message = "Don't need to remove SPNs for {0}" -f $_
        Write-PSFMessage -Level Host -Message $message
    }
}

$SQLHosts | ForEach-Object {
    $message = "Setting SPNs for {0}" -f $_
    Write-PSFMessage -Level Host -Message $message
    Invoke-Command {
        $secStringPassword = 'dbatools.IO1' | ConvertTo-SecureString -AsPlainText -Force
        [pscredential]$cred = New-Object System.Management.Automation.PSCredential ('theboss', $secStringPassword)
        [pscredential]$domaincred = New-Object System.Management.Automation.PSCredential ('jessandbeard\theboss', $secStringPassword)

        try {
            Test-DbaSpn -ComputerName $Env:ComputerName -Credential $domaincred | Where-Object { $psitem.IsSet -eq $false } | Set-DbaSpn -Credential $domaincred -ErrorAction Stop -WarningAction Stop
            $message = "SPNs on {0} set" -f $Env:ComputerName 
            Write-PSFMessage -Level Host -Message $message
        } catch {
            $message = "Failed to set SPNs on {0}" -f $Env:ComputerName 
            Write-PSFMessage -Level Error -Message $message -Exception $_.Exception
        }

    } -ComputerName $_ -Credential $domaincred
}

