$secStringPassword = 'dbatools.IO1' | ConvertTo-SecureString -AsPlainText -Force
[pscredential]$cred = New-Object System.Management.Automation.PSCredential ('theboss', $secStringPassword)

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
