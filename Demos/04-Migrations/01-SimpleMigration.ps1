# We have found some older instances

# backup\restore - simple migrations from one instance to another

# 2016 is old - we want to move it all to 2019
Get-DbaDatabase -SqlInstance jess2016 -ExcludeSystem -OutVariable 2016dbs | Format-Table SqlInstance, Name

# outvariable is the best - How many dbs?
($2016dbs | Measure-Object).Count

# how many dbs on 2019 right now?
Get-DbaDatabase -SqlInstance jess2019 -ExcludeSystem | Measure-Object

# Copy all the database to Jess2019
$migrate = @{
    Source           = 'jess2016'
    Destination      = 'jess2019'
    Database         = $2016dbs.Name
    BackupRestore    = $true
    SharedPath       = '\\poshfs1\SQLBackups\Shared'
    SetSourceOffline = $true
    OutVariable      = 'migrated'
}
Copy-DbaDatabase @migrate

# Review the results
$migrated | Where-Object type -eq 'database'

# Spoiler alert - the actual migration is the easy bit
    # planning
    # testing applications & who knows what else
    # coordination

    # and what if it's a 1TB database? are we going to wait for backup/restore?

# reset stuff
$offline = Get-DbaDatabase -SqlInstance Jess2016 -Status Offline
Get-DbaDatabase -SqlInstance Jess2019 -Database $offline.Name | Remove-DbaDatabase -Confirm:$false
Get-DbaDatabase -SqlInstance Jess2016 -Database $offline.Name | Set-DbaDbState -Online