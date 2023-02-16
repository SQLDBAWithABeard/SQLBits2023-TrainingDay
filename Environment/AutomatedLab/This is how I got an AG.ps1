$aghosts = 'errol', 'laolith', 'ninereeds', 'thelibrarian'
$agName = 'Dragon_Ag'
$secStringPassword = 'dbatools.IO1' | ConvertTo-SecureString -AsPlainText -Force
[pscredential]$cred = New-Object System.Management.Automation.PSCredential ('sqladmin', $secStringPassword)

Add-DbaServerRoleMember -SqlInstance $aghosts -Role sysadmin -Login 'jessandbeard\theboss' -SqlCredential $cred

# because of course the primary is not the first one
$Primary = (Get-DbaAgReplica -SqlInstance $aghosts | where Role -EQ 'Primary').Name
$Secondary = ((Get-DbaAgReplica -SqlInstance $aghosts | where Role -EQ 'Secondary') | select Name -Unique).Name

Restore-DbaDatabase -SqlInstance $Primary -Path \\POSHFS1\SQLBackups\Shared

$dbname = (Get-DbaDatabase -SqlInstance $Primary  -ExcludeSystem |Select -First 1).Name
$Query = "ALTER AVAILABILITY GROUP [dragon_ag]
ADD DATABASE [{0}];" -f $dbname
Invoke-DbaQuery -SqlInstance $Primary -Query $Query

Get-DbaDatabase -SqlInstance $Primary  -ExcludeSystem | Where Name -ne $dbname |Add-DbaAgDatabase -AvailabilityGroup $agName -SeedingMode Automatic


