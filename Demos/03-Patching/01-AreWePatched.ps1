# KBUpdate

# Import the module - https://github.com/potatoqualitee/kbupdate
Import-Module kbupdate

# View the commands
Get-Command -Module kbupdate

# Get the updates needed for a computer
Get-KbNeededUpdate -ComputerName jess2019 -OutVariable patches

# Also see this with dbatools
Test-DbaBuild -SqlInstance jess2016,jess2017,jess2019 -Latest |
Format-Table SqlInstance, BuildLevel, BuildTarget, SupportedUntil, Compliant

# And we can check it with dbachecks
Invoke-DbcCheck -SqlInstance jess2016,jess2017,jess2019 -Check LatestBuild -legacy:$false

# set this to the update you want to use
$kb = 'KB5023049' # SQL Server 2019 RTM Cumulative Update (CU) 19 KB5023049

# build website
Start-Process https://dbatools.io/build

# KB5023363 - Get information about the update
Get-KbUpdate -Name $kb -Simple | Format-List

# Patch the computer with the needed updates - 15mins to install
Install-KbUpdate -ComputerName Jess2019 -HotfixId $kb -Verbose

# reboot
Restart-Computer -ComputerName Jess2019 -Force -Wait

# we good?
Get-KbInstalledUpdate -ComputerName Jess2019 -Name $kb

# Also see this with dbatools
Test-DbaBuild -SqlInstance jess2016,jess2017,jess2019 -Latest |
Format-Table SqlInstance, BuildLevel, BuildTarget, SupportedUntil, Compliant

# And we can check it with dbachecks
Invoke-DbcCheck -SqlInstance jess2016,jess2017,jess2019 -Check LatestBuild -legacy:$false

######

# Actually uninstall the update - ~10mins
Uninstall-KbUpdate -ComputerName Jess2019 -Name $kb -Verbose

<#
ComputerName : Jess2019
Title        : SQL Server 2019 RTM Cumulative Update (CU) 19 KB5023049
ID           : KB5023049
Status       : Install successful
FileName     : sqlserver2019-kb5023049-x64_a0df7db34758ce47d81286df13fd3d396c4abf51.exe

VERBOSE: [08:50:42][Start-JobProcess] Finished installing updates on Jess2019
#>

# reboot
Restart-Computer -ComputerName Jess2019 -Force -Wait

# Also see this with dbatools - we're no longer compliant
Test-DbaBuild -SqlInstance jess2019 -Latest |
Format-Table SqlInstance, BuildLevel, BuildTarget, SupportedUntil, Compliant
