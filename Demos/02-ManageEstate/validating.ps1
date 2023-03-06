# Now that we have the Instances in a database, we can set them to a variable and validate them
$SqlInstances = (Invoke-DbaQuery -SqlInstance jess2017 -Database Infinity -Query "Select Instance from dbo.SQLInstances").Instance

$SqlInstances = 'localhost,7403','localhost,7402','localhost,7401'

$sqlCredential = Get-Credential -UserName sqladmin
$PSDefaultParameterValues = @{
    'Invoke-DbcCheck:SqlCredential' = $sqlCredential
    'Invoke-DbcCheck:legacy' = $false
}

# Now we can validate the instances
# But first lets check if they exist

Reset-DbcConfig

Invoke-DbcCheck -SqlInstance $SqlInstances -Check InstanceConnection

# maybe we want to check the authentication scheme is correct - this enables us to talk about configuration for dbachecks

Get-DbcCheck -Tag InstanceConnection | Format-List

Get-DbcConfig -Name policy.connection.authscheme

Set-DbcConfig -Name policy.connection.authscheme -Value 'SQL'

Invoke-DbcCheck -SqlInstance $SqlInstances -Check InstanceConnection

# Maybe our firewall does not allow ICMP and we dont want to check if we cna remote.
# This lets us talk about skipping for dbachecks

Set-DbcConfig -Name skip.connection.ping -Value $true
Set-DbcConfig -Name skip.connection.remoting  -Value $true

Invoke-DbcCheck -SqlInstance $SqlInstances -Check InstanceConnection

# Of course, if we dont to have to specify the instance every time, we can set it as a configuration

Set-DbcConfig -Name app.sqlinstance -Value $SqlInstances

Invoke-DbcCheck -Check InstanceConnection

Invoke-DbcCheck -Check Instance

# Lets make this useful

Invoke-DbcCheck -Check Instance -PassThru | Convert-DbcResult

# this means that we can output whatever we like

Invoke-DbcCheck -Check Instance -PassThru | Convert-DbcResult | Export-Excel -Path .\InstanceChecks.xlsx -AutoSize -AutoFilter -FreezeTopRow -BoldTopRow -WorkSheetname InstanceChecks -TableName InstanceChecks

# Or better still into a database

Invoke-DbcCheck -Check Instance -PassThru | Convert-DbcResult | Write-DbaDataTable -SqlInstance jess2017 -Database Infinity -Schema dbo -Table InstanceChecks -AutoCreateTable