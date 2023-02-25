# Find all the SQL Instances on your estate
Get-ADComputer -Filter * | Sort-Object Name | ForEach-Object { Resolve-DnsName -Name $_.Name }

Find-DbaInstance -DiscoveryType All -OutVariable svrs

Find-DbaInstance -DiscoveryType DomainSPN -DomainController jessdc1

$AdComputerNames = (Get-adcomputer -Filter * ).Name
$uprightnow = @(
'Jess2017',
'Jess2016',
'Jess2019',
'Beard2019AG1',
'Beard2019AG4',
'Beard2019AG2',
'Beard2019AG3'
)
$SQLInstances = $AdComputerNames| Where {$_ -in $uprightnow} | Find-DbaInstance

# this is slow - but it is the way you may think of doing it
$AvailableSQL = $SQLInstances | where Availability -eq 'Available' | ForEach-Object {
    Write-PSFMessage -Level Host -Message "Testing connection to $($_.SqlInstance)"
    $results = Test-DbaConnection -SqlInstance $_.SqlInstance -SkipPSRemoting -WarningAction SilentlyContinue
    if ($results.ConnectSuccess) {
        Write-PSFMessage -Level Host -Message "SUCCESS - Testing connection to $($_.SqlInstance)"
        $_
    }
}

$SQLInstances | where Availability -eq 'Available'

# using new dbachecks is way way quicker
$Testresults = Invoke-DbcCheck -SqlInstance ($SQLInstances | where Availability -eq 'Available') -Check InstanceConnection -legacy:$false -PassThru | Convert-DbcResult
# we have the output on the screen but we also have it in a variable 
#lets get the results of the test that have passed
$Testresults |Where-Object { $_.Result -eq 'Passed' }
#huh? What is up with that? Why is it not showing the instance name?
# What type is the variable ?
$Testresults.GetType()

# Its a data table - so we can use it like a data table :-) 
# This means that we can use our sql skills to query it ;-)

# lets build a filter to get the results that we want - this is a really neat quick way of using powershell to filter large data sets

# this one is not too big though but lets do it anyway
# First we need to create a view of the data table
$TestFilter  = New-Object System.Data.DataView($Testresults)
# Now we have a view we can use the RowFilter property to filter the datatable
$TestFilter.RowFilter = "Result = 'Passed'" 
# How many rows are in the view?
$TestFilter.Count
# What are the unique instances in the view?
$TEstFilter | Select INstance -Unique
# 1 milliseconds to run the query

# compare that to using PowerShell and Where-Object
$PesterTestresults = Invoke-DbcCheck -SqlInstance ($SQLInstances | where Availability -eq 'Available') -Check InstanceConnection -legacy:$false -PassThru
$PesterTestresults |Where-Object { $_.Result -eq 'Passed' } | Select Instance -Unique

# 18 milliseconds to run the query !!!
# If you extrapolate that over 1000 instances - that is 180 seconds to run the query 

# Anwyway, lets get back to the demo


# Save the results to excel - Because everyone wants excel !!
$Testresults |Export-Excel -Path C:\temp\SQLInstances.xlsx -Show

# Wait! - You see that? We dont even have Excel on this machine and still we can create Excel files :-)
# lets jump into onedrive - 
explorer c:\temp
start msedge 'https://onedrive.live.com/?id=C802DF42025D5E1F%211237265&cid=C802DF42025D5E1F'

# meh thats ok - but I want to see the results in a table 
# Lets face it our users are demanding ;-)
$ExportExcelConfig = @{
    Path = 'C:\temp\SQLInstances-nicer.xlsx'
    AutoSize = $true
    FreezeTopRow = $true
    TableName = 'SQLInstances'
    WorkSheetname = 'SQLInstances'
    BoldTopRow = $true
    AutoFilter = $true
}
$Testresults |Export-Excel @ExportExcelConfig

# Save the results to a database - so you can use it for all sorts of things

#dbachecks has a command to save the results to a database already Write-DbcTable
# but we can also use the data table to do it ourselves so you can see how easy it is to
# get ANY PowerShell output into a database

$DatabaseConfig = @{
    SqlInstance = 'jess2017'
    Database = 'tempdb'
    Schema = 'dbo'
    Table = 'Processes'
    AutoCreateTable = $true
}
Get-Process | Write-DbaDataTable @DatabaseConfig

# Lets add the SQLInstances to the database

$DatabaseConfig.Table = 'SQLInstances'
$DatabaseConfig.Database = 'Infinity'
$TestFilter | Select INstance -Unique | Write-DbaDataTable @DatabaseConfig

# Use the results as tab completion for your PowerShell commands
