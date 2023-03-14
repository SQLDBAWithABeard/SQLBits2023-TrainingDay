


# reset stuff from 04-Migrations\02-BigMigration.ps1
Set-DbaDbState -SqlInstance Jess2017 -Database Pubs, Titan -Online -Force
Remove-DbaDatabase -SqlInstance beard2019ag1 -Database Pubs, Titan -Confirm:$false

# drop the NewTable from Titan on Jess2017
Invoke-DbaQuery -SqlInstance Jess2017 -Database Titan -Query 'DROP TABLE NewTable'

# AG cleanup
# remove 4th node
$agSplat = @{
    SqlInstance       = 'Beard2019AG1'
    AvailabilityGroup = 'DragonAg'
}
Remove-DbaAgReplica @agSplat -Replica Beard2019AG4 -Confirm:$false

# Remove databases from 4th node
Get-DbaDatabase -sqlinstance Beard2019AG4 -Status Restoring | Remove-DbaDatabase -Confirm:$false

# remove pubs & titan from ag
Remove-DbaAgDatabase -SqlInstance Beard2019AG1 -AvailabilityGroup DragonAg -Database Pubs, Titan -Confirm:$false

# remove pubs & titan databases from ag nodes
Get-DbaDatabase -SqlInstance beard2019ag1, Beard2019AG2, Beard2019AG3 -Database Pubs, Titan | Remove-DbaDatabase -Confirm:$false

# disable hadr from node 4
Disable-DbaAgHadr -SqlInstance Beard2019AG4 -Force