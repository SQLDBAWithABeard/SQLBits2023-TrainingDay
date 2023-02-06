$global:secStringPassword = 'dbatools.IO1' | ConvertTo-SecureString -AsPlainText -Force
[pscredential]$global:cred = New-Object System.Management.Automation.PSCredential ('theboss', $secStringPassword)
[pscredential]$global:domaincred = New-Object System.Management.Automation.PSCredential ('jessandbeard\theboss', $secStringPassword)

$PSDefaultParameterValues = @{
    '*Ad*:credential' = $cred
}

$global:SQLHosts = 'Jess2016', 'Jess2017', 'Jess2019'


