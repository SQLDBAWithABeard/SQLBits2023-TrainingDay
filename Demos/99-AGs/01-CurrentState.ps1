# Get our favourite module
Import-Module dbatools

# What commands do we have for AGs?
Find-DbaCommand *Availability*Group*

# We can also use the AG tag
Find-DbaCommand -Tag AG

# Let's just get our AG
Get-DbaAvailabilityGroup -SqlInstance Beard2019Ag1

# There is a lot more info here than you first see
(Get-DbaAvailabilityGroup -SqlInstance Beard2019Ag1).AvailabilityReplicas

# What is it?
(Get-DbaAvailabilityGroup -SqlInstance Beard2019Ag1).AvailabilityReplicas | Get-Member
# TypeName: Microsoft.SqlServer.Management.Smo.AvailabilityReplica

## Talk about SMO and the magic of PowerShell objects

# There are dbatools commands for these specifics parts of an ag though
Get-DbaAgReplica -SqlInstance Beard2019Ag1

# What is it?
Get-DbaAgReplica -SqlInstance Beard2019Ag1 | Get-Member
#  TypeName: Microsoft.SqlServer.Management.Smo.AvailabilityReplica

########################
## So what do we have ##
########################

# An availability group
    Get-DbaAvailabilityGroup -SqlInstance Beard2019Ag1

    # We can also use the listener as our sql instance
    Get-DbaAvailabilityGroup -SqlInstance dragonlist

# With some replicas
    Get-DbaAgReplica -SqlInstance dragonlist  |
    Select-Object SqlInstance, AvailabilityGroup, Role, ConnectionState, RollupSynchronizationState, AvailabilityMode, FailoverMode |
    Format-Table

# With some databases
    Get-DbaAgDatabase -SqlInstance dragonlist |
    Select-Object SqlInstance, AvailabilityGroup, LocalReplicaRole, Name, SynchronizationState, IsFailoverReady, IsJoined, IsSuspended |
    Format-Table

# and a listener
    Get-DbaAgListener -SqlInstance dragonlist

## BUT WE NEED MORE HADR!