


# reset stuff from 04-Migrations\02-BigMigration.ps1
Set-DbaDbState -SqlInstance Jess2017 -Database Pubs, Titan -Online -Force
Remove-DbaDatabase -SqlInstance beard2019ag1 -Database Pubs, Titan -Confirm:$false

# drop the NewTable from Titan on Jess2017
Invoke-DbaQuery -SqlInstance Jess2017 -Database Titan -Query 'DROP TABLE NewTable'