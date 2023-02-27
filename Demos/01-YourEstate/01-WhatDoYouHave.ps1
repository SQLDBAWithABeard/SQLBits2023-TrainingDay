# Find all the SQL Instances on your estate

# Lets start by getting all the computers in the domain
# so that you can see some of the demo environment
Get-ADComputer -Filter * | Sort-Object Name | ForEach-Object {
    Resolve-DnsName -Name $_.Name 
}

# find the SQL Instances on your estate

# these take time to run

Find-DbaInstance -DiscoveryType All -OutVariable svrs

Find-DbaInstance -DiscoveryType DomainSPN -DomainController jessdc1

# so we will just start with three 
# RUN THIS THEN TALK ROB AND JESS !!

$AdComputerNames = (Get-adcomputer -Filter * ).Name
$uprightnow = @(
    'Jess2017',
    'Jess2016',
    'Jess2019'
)
$SQLInstances = $AdComputerNames | Where { 
    $_ -in $uprightnow 
} | Find-DbaInstance

# So you can see the results of the command
# Panel below

$SQLInstances

# We can filter by Availability to see which ones are available

$SQLInstances | where Availability -eq 'Available'

# this is slow - but it is the way you may think of doing it this way # 14 seconds or 28 seconds with a module load
$AvailableSQL = $SQLInstances | where Availability -eq 'Available' | ForEach-Object {
    Write-PSFMessage -Level Host -Message "Testing connection to $($_.SqlInstance)"
    $results = Test-DbaConnection -SqlInstance $_.SqlInstance -SkipPSRemoting -WarningAction SilentlyContinue
    if ($results.ConnectSuccess) {
        Write-PSFMessage -Level Host -Message "SUCCESS - Testing connection to $($_.SqlInstance)"
        $_
    }
}


# using new dbachecks is way way quicker 7 seconds or 12 seconds with a module load
$Testresults = Invoke-DbcCheck -SqlInstance ($SQLInstances | where Availability -eq 'Available') -Check InstanceConnection -legacy:$false -PassThru | Convert-DbcResult
# we have the output on the screen but we also have it in a variable 
# What type is the variable ?
$Testresults.GetType()

# Its a data table - so we can use it like a data table :-) 
# This means that we can use our sql skills to query it ;-)

# lets build a filter to get the results that we want - this is a really neat quick way of using powershell to filter large data sets

# this one is not too big though but lets do it anyway
# First we need to create a view of the data table
$TestFilter = New-Object System.Data.DataView($Testresults)
# Now we have a view we can use the RowFilter property to filter the datatable
$TestFilter.RowFilter = "Result = 'Passed'" 
# How many rows are in the view?
$TestFilter.Count
# What are the unique instances in the view?
$TestFilter | Select Instance -Unique
# 1 milliseconds to run the query

# But is it really like that ?

# compare that to using PowerShell and Where-Object

# These two queries are the same 
# but one is returning a data table and the other is returning a PSObject
$dataTableQuery = {
    $Testresults = Invoke-DbcCheck -SqlInstance ($SQLInstances | where Availability -eq 'Available') -Check InstanceConnection -legacy:$false -PassThru | Convert-DbcResult
    $TestFilter = New-Object System.Data.DataView($Testresults)
    $TestFilter.RowFilter = "Result = 'Passed'" 
    $TestFilter.Count
    $TestFilter | Select Instance -Unique
}

$PsObjectQuery = {
    $PesterTestresults = Invoke-DbcCheck -SqlInstance ($SQLInstances | where Availability -eq 'Available') -Check InstanceConnection -legacy:$false -PassThru
    ($PesterTestresults | Where-Object { $_.Result -eq 'Passed' } ).Passed | ForEach-Object { ($_.ExpandedName -split ' ')[-1] } | Select -Unique    
}

# lets measure the execeution time of each query
$datatablettrace = Trace-Script -ScriptBlock $dataTableQuery 
$PsObjecttrace = Trace-Script -ScriptBlock $PsObjectQuery

# and compare the execution time
$datatablettrace.StopwatchDuration.TotalSeconds
$PsObjecttrace.StopwatchDuration.TotalSeconds

# lets use a larger comparision than a dozen rows of data :-)

# Grab a database from one of the instances
$DbName = (Get-DbaDatabase -SqlInstance Jess2019 -ExcludeSystem -ExcludeDatabase ReportServer, ReportServerTempDB | Select -First 1).Name

# get the biggest table in the database
Get-DbaDbTable -SqlInstance Jess2019 -Database $DbName | Sort-Object RowCount -Descending | Select -First 1

$BigTable = Get-DbaDbTable -SqlInstance Jess2019 -Database $DbName | Sort-Object RowCount -Descending | Select -First 1

# select all the rows from the table
$Query = " Select * from [{0}].[{1}] " -f $BigTable.Schema, $BigTable.Name

# run the query and get the results as a datatable and as a PSObject
$QueryConfig = @{
    SqlInstance = $BigTable.SqlInstance
    Database    = $BigTable.Database
    Query       = $Query
}
$DatatableResults = Invoke-DbaQuery @QueryConfig -As DataTable
$PsObjectResults = Invoke-DbaQuery @QueryConfig -As PSObject

# this is what we have
$PsObjectResults[0]

# how many rows
$PsObjectResults.count

# lets compare using the data view row filter and where-object
$dataTableBiggerQuery = {
    $TestBiggerFilter = New-Object System.Data.DataView($DatatableResults)
    $TestBiggerFilter.RowFilter = "UnitPrice = '2024.9940'" 
    # $TestBiggerFilter.RowFilter = "UnitPrice > '2024.9940'" 
    $TestBiggerFilter | Select SalesOrderID
}

$PsObjectBiggerQuery = {
    
    $PsObjectResults | Where-Object { $_.UnitPrice -eq '2024.9940' }   | Select SalesOrderID 
}

$datatableBiggertrace = Trace-Script -ScriptBlock $dataTableBiggerQuery 
$PsObjectBiggertrace = Trace-Script -ScriptBlock $PsObjectBiggerQuery

$datatableBiggertrace.StopwatchDuration.TotalSeconds
$PsObjectBiggertrace.StopwatchDuration.TotalSeconds

# If you extrapolate that over 1000 instances .....

# Oh - you want to compare running the query as well ??
# lets compare using the data view row filter and where-object
$dataTableBiggerQuery = {
    $QueryConfig = @{
        SqlInstance = $BigTable.SqlInstance
        Database    = $BigTable.Database
        Query       = $Query
    }
    $DatatableResults = Invoke-DbaQuery @QueryConfig -As DataTable
    $TestBiggerFilter = New-Object System.Data.DataView($DatatableResults)
    $TestBiggerFilter.RowFilter = "UnitPrice = '2024.9940'" 
    # $TestBiggerFilter.RowFilter = "UnitPrice > '2024.9940'" 
    $TestBiggerFilter | Select SalesOrderID
}

$PsObjectBiggerQuery = {
    $QueryConfig = @{
        SqlInstance = $BigTable.SqlInstance
        Database    = $BigTable.Database
        Query       = $Query
    }
    $PsObjectResults = Invoke-DbaQuery @QueryConfig -As PSObject
    $PsObjectResults | Where-Object { $_.UnitPrice -eq '2024.9940' }   | Select SalesOrderID 
}

$datatableBiggertrace = Trace-Script -ScriptBlock $dataTableBiggerQuery 
$PsObjectBiggertrace = Trace-Script -ScriptBlock $PsObjectBiggerQuery

$datatableBiggertrace.StopwatchDuration.TotalSeconds
$PsObjectBiggertrace.StopwatchDuration.TotalSeconds



# Anwyway, lets get back to the demo


# Save the results to excel - Because everyone wants excel !!
$Testresults | Export-Excel -Path C:\temp\SQLInstances.xlsx -Show

# Wait! - You see that? We dont even have Excel on this machine and still we can create Excel files :-)
# lets jump into onedrive - 
explorer c:\temp
start msedge 'https://onedrive.live.com/?id=C802DF42025D5E1F%211237265&cid=C802DF42025D5E1F'

# meh thats ok - but I want to see the results in a table 
# Lets face it our users are demanding ;-)
$ExportExcelConfig = @{
    Path          = 'C:\temp\SQLInstances-nicer.xlsx'
    AutoSize      = $true
    FreezeTopRow  = $true
    TableName     = 'SQLInstances'
    WorkSheetname = 'SQLInstances'
    BoldTopRow    = $true
    AutoFilter    = $true
}
$Testresults | Export-Excel @ExportExcelConfig

# Save the results to a database - so you can use it for all sorts of things

#dbachecks has a command to save the results to a database already Write-DbcTable
# but we can also use the data table to do it ourselves so you can see how easy it is to
# get ANY PowerShell output into a database

$DatabaseConfig = @{
    SqlInstance     = 'jess2017'
    Database        = 'tempdb'
    Schema          = 'dbo'
    Table           = 'Processes'
    AutoCreateTable = $true
}
Get-Process | Write-DbaDataTable @DatabaseConfig

# Lets add the SQLInstances to the database

$DatabaseConfig.Table = 'SQLInstances'
$DatabaseConfig.Database = 'Infinity'
$TestFilter | Select Instance -Unique | Write-DbaDataTable @DatabaseConfig

# Use the results as tab completion for your PowerShell commands

# Lets have function to returnt eh largest table in the database

function Get-TheBossLargestTable {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]
        $SqlInstance,
        [Parameter()]
        [string]
        $database
    )
    $BigTable = Get-DbaDbTable -SqlInstance $SqlInstance -Database $database | Sort-Object RowCount -Descending | Select -First 1

    "[{0}].[{1}]" -f $BigTable.Schema, $BigTable.Name
}

Get-TheBossLargestTable -SqlInstance jess2019 -database $DbName

# Create scriptblock that collects information and name it
Register-PSFTeppScriptblock -Name "SqlInstances" -ScriptBlock { 
(Invoke-DbaQuery -SqlInstance jess2017 -Database Infinity -Query "Select Instance from dbo.SQLInstances").Instance
}

#Assign scriptblock to function
Register-PSFTeppArgumentCompleter -Command Get-TheBossLargestTable -Parameter SqlInstance -Name SqlInstances

Get-TheBossLargestTable -SqlInstance CTRLSPACE to see the list of SQLInstances

# Create scriptblock that collects information and name it
Register-PSFTeppScriptblock -Name "databasesoninstance" -ScriptBlock { 

    (Get-DbaDatabase -SqlInstance $fakeBoundParameter.SqlInstance).Name
}
    
#Assign scriptblock to function
Register-PSFTeppArgumentCompleter -Command Get-TheBossLargestTable -Parameter database -Name databasesoninstance
    
# and now you have tab completion for the database parameter :-)