$global:secStringPassword = 'dbatools.IO1' | ConvertTo-SecureString -AsPlainText -Force
[pscredential]$global:cred = New-Object System.Management.Automation.PSCredential ('theboss', $secStringPassword)
[pscredential]$global:domaincred = New-Object System.Management.Automation.PSCredential ('jessandbeard\theboss', $secStringPassword)

$global:SASQLHosts = 'Jess2016', 'Jess2017', 'Jess2019'
$global:SQLAgs = 'Beard2019AG1','Beard2019AG2','Beard2019AG3','Beard2019AG4'

$global:SQLHosts = $SASQLHosts + $SQLAgs