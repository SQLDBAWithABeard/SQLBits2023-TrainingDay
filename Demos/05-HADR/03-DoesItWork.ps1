# this is all great - but does the AG actually work

# Planned failover
    # to our Synchronous Replica
    Invoke-DbaAgFailover -SqlInstance Beard2019AG2 -AvailabilityGroup DragonAg

    # to our Asynchronous Replica
    Invoke-DbaAgFailover -SqlInstance Beard2019AG3 -AvailabilityGroup DragonAg
    Invoke-DbaAgFailover -SqlInstance Beard2019AG3 -AvailabilityGroup DragonAg -Force

    # get back to our Synchronous Replica
    Invoke-DbaAgFailover -SqlInstance Beard2019AG1 -AvailabilityGroup DragonAg -Force

    # we need to also resume data movement
    Get-DbaAgDatabase -SqlInstance Beard2019AG1,Beard2019AG2,Beard2019AG3,Beard2019AG4 -AvailabilityGroup dragonag |
    Select-Object SqlInstance, Name, SynchronizationState, IsJoined, IsSuspended |
    Format-Table

    Get-DbaAgDatabase -SqlInstance Beard2019AG1,Beard2019AG2,Beard2019AG3,Beard2019AG4 -AvailabilityGroup dragonag |
    Where-Object IsSuspended |
    Resume-DbaAgDbDataMovement

    Get-DbaAgDatabase -SqlInstance Beard2019AG1,Beard2019AG2,Beard2019AG3,Beard2019AG4 -AvailabilityGroup dragonag |
    Select-Object SqlInstance, Name, SynchronizationState, IsJoined, IsSuspended |
    Format-Table



## Unplanned failovers - well we can't demo those....

                                            ▒▒▒▒▒▒░░
                                    ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒░░
                                ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▓▓
                              ▓▓▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
                            ▒▒▒▒▒▒▒▒▒▒▒▒▓▓██████████▒▒▒▒▒▒▒▒▒▒  ▓▓████▓▓
                            ▒▒▒▒▒▒▒▒▒▒██████████████████▒▒██████████████████▓▓
                          ▒▒▒▒▒▒▒▒▓▓████████████████████████████████████████████
                          ▒▒▒▒▒▒▒▒████████████████████████████████████████████████
                    ▒▒▓▓▒▒▒▒▒▒▒▒██████████████████████████████████████████████████▓▓
              ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▓▓████████████████████████████████████████████████████
            ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒████████████████████████████████████████████████████████▒▒▒▒
          ▒▒▒▒▒▒▒▒▒▒▒▒▒▒██████████████████████████████████████████████████████████████████████▒▒
        ▒▒▒▒▒▒▒▒▒▒▓▓██████████████████████████████████████████████████████████████████████████████
      ░░▒▒▒▒▒▒▒▒████████████████████████████████████████████████████████████████████████████████████
      ▒▒▒▒▒▒▒▒████████████████████████████████████████████████████████████████████████████████████████
      ▒▒▒▒▒▒▓▓████████████████████████████████████████████████████████████████████████████████████████
    ▓▓▒▒▒▒▒▒████████████████████████████████████████████████████████████████████████████████████████████
    ▓▓▒▒▒▒▒▒████████████████████████████████████████████████████████████████████████████████████████████
    ▒▒▒▒▒▒▒▒████████████████████████████████████████████████████████████████████████████████████████████
    ░░▒▒▒▒██████████████████████████████████████████████████████████████████████████████████████████████░░
      ▒▒▒▒██████████████████████████████████████████████████████████████████████████████████████████████
      ▒▒▒▒▒▒████████████████████████████████████████████████████████████████████████████████████████████
      ▒▒▒▒▒▒████████████████████████████████████████████████████████████████████████████████████████████
        ▒▒▒▒██████████████████████████████████████████████████████████████████████████████████████████
        ░░▒▒▒▒████████████████████████████████████████████████████████████████████████████████████████
          ▒▒▒▒▓▓████████████████████████████████████████████████████████████████████████████████████
            ░░▒▒▓▓████████████████████████████████████████████████████████████████████████████████
                ▒▒▒▒██████████████████████████████████████████████████████████████████████████
                        ░░  ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░



Get-DbaAgReplica -SqlInstance dragonlist  |
Select-Object SqlInstance, AvailabilityGroup, Role, ConnectionState, RollupSynchronizationState, AvailabilityMode, FailoverMode |
Format-Table









## Rob trips over a cable in the cloud...






## Check everything is good


Get-DbaAvailabilityGroup -SqlInstance dragonlist

# With some replicas
Get-DbaAgReplica -SqlInstance dragonlist  |
Select-Object SqlInstance, AvailabilityGroup, Role, ConnectionState, RollupSynchronizationState, AvailabilityMode, FailoverMode |
Format-Table

# With some databases
Get-DbaAgDatabase -SqlInstance dragonlist |
Select-Object SqlInstance, AvailabilityGroup, LocalReplicaRole, Name, SynchronizationState, IsFailoverReady, IsJoined, IsSuspended |
Format-Table
