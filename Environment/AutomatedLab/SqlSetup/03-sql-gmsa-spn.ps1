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

