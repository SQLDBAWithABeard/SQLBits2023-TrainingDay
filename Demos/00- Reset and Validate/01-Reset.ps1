


# reset stuff from 04-Migrations\02-BigMigration.ps1
Set-DbaDbState -SqlInstance Jess2017 -Database Pubs, Titan -Online -Force
Remove-DbaDatabase -SqlInstance beard2019ag1 -Database Pubs, Titan -Confirm:$false