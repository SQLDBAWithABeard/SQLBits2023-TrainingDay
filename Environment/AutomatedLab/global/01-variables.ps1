$global:__secStringPassword = 'dbatools.IO1' | ConvertTo-SecureString -AsPlainText -Force
[pscredential]$global:__cred = New-Object System.Management.Automation.PSCredential ('theboss', $__secStringPassword)
[pscredential]$global:__domaincred = New-Object System.Management.Automation.PSCredential ('jessandbeard\theboss', $__secStringPassword)

$global:__SASQLHosts = 'Jess2016', 'Jess2017', 'Jess2019'
$global:__SQLAgs = 'Beard2019AG1','Beard2019AG2','Beard2019AG3','Beard2019AG4'

$global:__SQLHosts = $__SASQLHosts + $__SQLAgs