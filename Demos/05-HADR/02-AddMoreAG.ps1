
# Databases that aren't currently in an AG
Get-DbaDatabase -SqlInstance Beard2019AG1 |
Select-Object SqlInstance, Name, Status, RecoveryModel, AvailabilityGroupName |
Format-Table

## NOTE - this'll find the databases that got migrated here

# Add databases

# Add another replica

