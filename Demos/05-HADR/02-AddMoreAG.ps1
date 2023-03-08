
# Lets check the databases on the AG instance
Get-DbaDatabase -SqlInstance Beard2019AG1 |
Select-Object SqlInstance, Name, Status, RecoveryModel, AvailabilityGroupName |
Format-Table

# Databases that aren't currently in an AG
Get-DbaDatabase -SqlInstance Beard2019AG1 -ExcludeSystem |
Where-Object {-not $_.AvailabilityGroupName } |
Select-Object SqlInstance, Name, Status, RecoveryModel, AvailabilityGroupName |
Format-Table

# Add databases into the AG
$pubsSplat = @{
    SqlInstance       = 'Beard2019AG1'
    AvailabilityGroup = 'DragonAg'
    Database          = 'pubs'
    SeedingMode       = 'Automatic'
}
Add-DbaAgDatabase @pubsSplat

<#
WARNING: [14:59:40][Add-DbaAgDatabase] Testing prerequisites for joining database pubs to Availability Group DragonAg failed. |
RecoveryModel of database [pubs] is not Full, but Simple.
#>

# Lets change the recovery model
$recoverySplat = @{
    SqlInstance       = 'Beard2019AG1'
    Database          = 'pubs'
    RecoveryModel     = 'Full'
    Confirm           = $false
}
Set-DbaDbRecoveryModel @recoverySplat

# lets try again and add databases into the AG
$pubsSplat = @{
    SqlInstance       = 'Beard2019AG1'
    AvailabilityGroup = 'DragonAg'
    Database          = 'pubs'
    SeedingMode       = 'Automatic'
}
Add-DbaAgDatabase @pubsSplat

<#
WARNING: [15:01:02][Add-DbaAgDatabase] Failed to add database pubs to Availability Group DragonAg |
Database "pubs" might contain bulk logged changes that have not been backed up.
Take a log backup on the principal database or primary database.
Then restore this backup either on the mirror database to enable database mirroring or on every secondary database to enable you to join it to the availability group.
#>

# Lets take a full backup
$backupSplat = @{
    SqlInstance = 'Beard2019AG1'
    Database    = 'pubs'
    CopyOnly    = $false
}
Backup-DbaDatabase @backupSplat

# third time lucky - add databases into the AG
$pubsSplat = @{
    SqlInstance       = 'Beard2019AG1'
    AvailabilityGroup = 'DragonAg'
    Database          = 'pubs'
    SeedingMode       = 'Automatic'
}
Add-DbaAgDatabase @pubsSplat

# What if we have a monster db
# and we don't want to use automatic seeding

'Beard2019AG2','Beard2019AG3' | ForEach-Object {
    Get-DbaDbBackupHistory -SqlInstance Beard2019AG1 -Database Titan -Last |
    Restore-DbaDatabase -SqlInstance $psitem -NoRecovery -UseDestinationDefaultDirectories
}

# Lets check on our databases
Get-DbaDatabase -SqlInstance beard2019ag1, beard2019ag2, beard2019ag3 -Database Titan |
Select-Object SqlInstance, Name, Status, SizeMB

# add titan into the AG
$titanSplat = @{
    SqlInstance       = 'Beard2019AG1'
    AvailabilityGroup = 'DragonAg'
    Database          = 'titan'
    SeedingMode       = 'Manual'
}
Add-DbaAgDatabase @titanSplat

# Lets check on our databases
Get-DbaDatabase -SqlInstance beard2019ag1, beard2019ag2, beard2019ag3 -Database Titan |
Select-Object SqlInstance, Name, Status, SizeMB, IsAccessible |
Format-Table

# Add another replica
$agSplat = @{
    SqlInstance       = 'Beard2019AG1'
    AvailabilityGroup = 'DragonAg'
}
Get-DbaAvailabilityGroup @agSplat |
Add-DbaAgReplica -SqlInstance Beard2019AG4 -FailoverMode Manual

<#
WARNING: [15:12:56][Join-DbaAvailabilityGroup] Failure | The Always On Availability Groups feature must be enabled for this server instance before you can perform availability group operations. Please enable the feature, then retry the operation.
#>

Get-DbaAgHadr -SqlInstance Beard2019AG4 | Format-List

# Enable the feature - force means restart!
Enable-DbaAgHadr -SqlInstance Beard2019AG4 -Force

# clear up the first attempt
Remove-DbaAgReplica @agSplat -Replica Beard2019AG4 -Confirm:$false

# and...
Get-DbaAvailabilityGroup @agSplat |
Add-DbaAgReplica -SqlInstance Beard2019AG4 -ClusterType Wsfc -FailoverMode manual -SeedingMode Automatic

Get-DbaAgDatabase -SqlInstance Beard2019AG4 -AvailabilityGroup DragonAg |
Select-Object SqlInstance, Name, SynchronizationState, IsJoined, IsSuspended |
Format-Table

