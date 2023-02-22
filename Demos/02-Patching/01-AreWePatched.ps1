# KBUpdate

# Import the module
Import-Module kbupdate

# View the commands
Get-Command -Module kbupdate

# Get the updates needed for a computer
Get-KbNeededUpdate -ComputerName jess2016

# set this to the update you want to use
$kb = 'KB459208'

# KB5023363 - Get information about the update
Get-KbUpdate -Name $kb -Simple

# Is it installed on our computers?
Get-KbInstalledUpdate -ComputerName jess2016 -Name $kb

# Patch the computer with the needed updates
Get-KbNeededUpdate -ComputerName jess2016 | Install-KbUpdate

# reboot
Restart-Computer -ComputerName jess2016 -Force -Wait

# Actually uninstall the update
Uninstall-KbUpdate -ComputerName jess2016 -Name $kb -Verbose

# Is it installed on our computers?
Get-KbInstalledUpdate -ComputerName jess2016 -Name $kb