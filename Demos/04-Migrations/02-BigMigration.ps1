# databases are too large to migrate with backup\restore in a downtime window

# stage full backup

# set up log shipping and cut over

##################################################################################
# Jess - go start the application - otherwise this is going to be a bit boring...#
##################################################################################

# Let's see what databases we have available here
Get-DbaDatabase -SqlInstance Jess2017, Beard2019Ag1 -ExcludeSystem | Select-Object SqlInstance, Name, Status, SizeMB

# Lets focus on pubs and GoGoGo
Get-DbaDatabase -SqlInstance Jess2017, Beard2019Ag1 -Database pubs, Titan | Select-Object SqlInstance, Name, Status, SizeMB

##################################
## METHOD 1 - Stage Full backup ##
##################################

# before downtime we'll stage most of the data
$copySplat = @{
    Source        = 'Jess2017'
    Destination   = 'Beard2019Ag1'
    Database      = 'Pubs'
    SharedPath    = '\\poshfs1\SQLBackups\Shared'
    BackupRestore = $true
    NoRecovery    = $true # leave the database ready to receive more restores
    NoCopyOnly    = $true # this will break our backup chain!
    OutVariable   = 'CopyResults'
}
Copy-DbaDatabase @copySplat

# This DateTime is going to be important...
$CopyResults | Select-Object *

# How are our databases looking now?
Get-DbaDatabase -SqlInstance jess2017, beard2019ag1 -Database pubs, Titan | Select-Object SqlInstance, Name, Status, SizeMB

#################################
## DOWNTIME WINDOWS STARTS NOW ##
#################################
# App team will stop the app running...

$processSplat = @{
    SqlInstance = 'Jess2017', 'Beard2019Ag1'
    Database    = 'Pubs'
}
Get-DbaProcess @processSplat |
Select-Object Host, login, Program

# Kill any left over processes
Get-DbaProcess @processSplat | Stop-DbaProcess

# What's our newest order?
Invoke-DbaQuery -SqlInstance Jess2017 -Database Pubs -Query 'select @@servername AS [SqlInstance], count(*)NumberOfOrders, max(ord_date) as NewestOrder from pubs.dbo.sales' -OutVariable 'sourceSales'

# Remember the date from our full backup!
$CopyResults | Select-Object *

# Let's take a differential to get any changes
$diffSplat = @{
    SqlInstance = 'Jess2017'
    Database    = 'pubs'
    Path        = '\\poshfs1\SQLBackups\Shared'
    Type        = 'Differential'
}
$diff = Backup-DbaDatabase @diffSplat

# Set the source database offline
$offlineSplat = @{
    SqlInstance = 'Jess2017'
    Database    = 'pubs'
    Offline     = $true
    Force       = $true
}
Set-DbaDbState @offlineSplat

# How are our databases looking now?
Get-DbaDatabase -SqlInstance jess2017, beard2019ag1 -Database pubs, Titan | Select-Object SqlInstance, Name, Status, SizeMB

# restore the differential and bring the destination online
$restoreSplat = @{
    SqlInstance = 'Beard2019Ag1'
    Database    = 'Pubs'
    Path        = $diff.Path
    Continue    = $true
}
Restore-DbaDatabase @restoreSplat

# Let's check on our databases
Get-DbaDatabase -SqlInstance jess2017, beard2019ag1 -Database pubs, Titan | Select-Object SqlInstance, Name, Status, SizeMB

# Let's check our data
Invoke-DbaQuery -SqlInstance beard2019ag1 -Database Pubs -Query 'select @@servername AS [SqlInstance], count(*)NumberOfOrders, max(ord_date) as NewestOrder from pubs.dbo.sales' -OutVariable 'destSales'

# Compare these dates and orders
$sourceSales, $destSales

##############################
## METHOD 2 - Log Shipping  ##
##############################

$logship = @{
    SourceSqlInstance      = 'Jess2017'
    Database               = 'Titan'
    DestinationSqlInstance = 'Beard2019AG1'
    SharedPath             = '\\poshfs1\SQLBackups\Shared'
    CopyDestinationFolder  = '\\poshfs1\SQLBackups\LogShipping'
}
Invoke-DbaDbLogShipping @logship

# Let's check on our databases
Get-DbaDatabase -SqlInstance jess2017, beard2019ag1 -Database pubs, Titan | Select-Object SqlInstance, Name, Status, SizeMB

# With log shipping jobs?
Get-DbaAgentJob -SqlInstance jess2017, beard2019ag1 -Category 'Log Shipping' | Select-Object SqlInstance, Name, LastRunDate, LastRunOutcome, NextRunDate | Format-Table

# lets run the backup then the copy then the restpre
Start-DbaAgentJob -SqlInstance jess2017 -Job 'LSBackup_Titan'
Start-Sleep -Seconds 5
Start-DbaAgentJob -SqlInstance beard2019ag1 -Job 'LSCopy_Jess2017_Titan'
Start-Sleep -Seconds 5
Start-DbaAgentJob -SqlInstance beard2019ag1 -Job 'LSRestore_Jess2017_Titan'
Start-Sleep -Seconds 5

# review those log shipping jobs
Get-DbaAgentJob -SqlInstance jess2017, beard2019ag1 -Category 'Log Shipping' |
Select-Object SqlInstance, Name, LastRunDate, LastRunOutcome, NextRunDate, Enabled |
Sort-Object LastRunDate |
Format-Table

# Lets make some data
$query = @"
CREATE TABLE NewTable (ID INT IDENTITY(1,1) PRIMARY KEY, Name VARCHAR(50))
INSERT INTO NewTable (Name) VALUES ('Jess')
"@

Invoke-DbaQuery -SqlInstance Jess2017 -Database Titan -Query $query

# Lets see the data
Invoke-DbaQuery -SqlInstance Jess2017 -Database Titan -Query 'SELECT * FROM NewTable'

# Run the log shipping jobs again
Start-DbaAgentJob -SqlInstance jess2017 -Job 'LSBackup_Titan'
Start-Sleep -Seconds 5
Start-DbaAgentJob -SqlInstance beard2019ag1 -Job 'LSCopy_Jess2017_Titan'
Start-Sleep -Seconds 5
Start-DbaAgentJob -SqlInstance beard2019ag1 -Job 'LSRestore_Jess2017_Titan'

# review those log shipping jobs
Get-DbaAgentJob -SqlInstance jess2017, beard2019ag1 -Category 'Log Shipping' |
Select-Object SqlInstance, Name, LastRunDate, LastRunOutcome, NextRunDate, Enabled |
Sort-Object LastRunDate |
Format-Table

# Lets cutover
Invoke-DbaDbLogShipRecovery -SqlInstance beard2019ag1 -Database Titan

# review those log shipping jobs
Get-DbaAgentJob -SqlInstance jess2017, beard2019ag1 -Category 'Log Shipping' |
Select-Object SqlInstance, Name, LastRunDate, LastRunOutcome, NextRunDate, Enabled |
Sort-Object LastRunDate |
Format-Table

# Lets check on our databases
Get-DbaDatabase -SqlInstance jess2017, beard2019ag1 -Database pubs, Titan | Select-Object SqlInstance, Name, Status, SizeMB

# Lets see the data
Invoke-DbaQuery -SqlInstance Beard2019Ag1 -Database Titan -Query 'SELECT * FROM NewTable'

# reset stuff
Set-DbaDbState -SqlInstance Jess2017 -Database Pubs, Titan -Online -Force
Remove-DbaDatabase -SqlInstance beard2019ag1 -Database Pubs, Titan -Confirm:$false