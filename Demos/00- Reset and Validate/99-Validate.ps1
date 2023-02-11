
$PesterConfig = New-PesterConfiguration 
$PesterConfig.Run.Path = '*.Tests.ps1'
$PesterConfig.Run.PassThru = $false
$PesterConfig.Filter.Tag = 'Morning'
$PesterConfig.TestResult.Enabled = $true
$PesterConfig.Output.Verbosity = 'Detailed'
Invoke-Pester -Configuration $PesterConfig
<#
do this first becuase we get this if we dont
ipmo dbachecks
Import-Module: Could not import C:\Program Files\WindowsPowerShell\Modules\dbatools\1.1.145\bin\smo\coreclr\Microsoft.SqlServer.XE.Core.dll :
MethodInvocationException: C:\Program Files\WindowsPowerShell\Modules\dbatools\1.1.145\internal\scripts\libraryimport.ps1:150
Line |
 150 |                      [Reflection.Assembly]::LoadFrom($assemblyPath)
     |                      ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
     | Exception calling "LoadFrom" with "1" argument(s): "Could not load file or assembly 'C:\Program
     | Files\WindowsPowerShell\Modules\dbatools\1.1.145\bin\smo\coreclr\Microsoft.SqlServer.XE.Core.dll'. The specified
     | module could not be found."
#>
Import-Module dbatools
$SQlinstances =  $__SQLAgs + $__SASQLHosts
Invoke-DbcCheck -SqlInstance $SQLInstances -Check InstanceConnection -legacy:$false

