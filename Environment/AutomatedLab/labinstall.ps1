# Needs to be run in an elevated PowerShell session

$labName = 'SQLBits2023-TrainingDay' #THIS NAME MUST BE GLOBALLY UNIQUE

$azureDefaultLocation = 'West Europe' #COMMENT OUT -DefaultLocationName BELOW TO USE THE FASTEST LOCATION

$DomainName = 'jessandbeard.local'

$SubscriptionId = '6d8f994c-9051-4cef-ba61-528bab27d213' # Robs Beard MVP subscription

$AdminPass = 'dbatools.IO1'

$CLientVM = 'POSHClient1'

$Dc1 = 'JessDC1'
$Dc2 = 'BeardDC2'
$FileServer = 'POSHFS1'
$DemoMachine = 'RainbowDragon'

$SQLServers = @(

    @{
        Role      = 'SQLServer2016'
        # Properties = @{InstallSampleDatabase = 'true' }
        Name      = 'Jess2016'
        Memory    = 1GB
        IPAddress = '192.168.2.53'
    }
    @{
        Role      = 'SQLServer2017'
        # Properties = @{InstallSampleDatabase = 'true' }
        Name      = 'Jess2017'
        Memory    = 1GB
        IPAddress = '192.168.2.55'
    }
    @{
        Role      = 'SQLServer2019'
        # Properties = @{InstallSampleDatabase = 'true' }
        Name      = 'Jess2019'
        Memory    = 1GB
        IPAddress = '192.168.2.56'
    }
    @{
        Role      = 'SQLServer2019', 'FailoverNode'
        # Properties = @{InstallSampleDatabase = 'true' }
        Name      = 'Beard2019AG1'
        Memory    = 1GB
        IPAddress = '192.168.2.57'
    }
    @{
        Role      = 'SQLServer2019', 'FailoverNode'
        # Properties = @{InstallSampleDatabase = 'true' }
        Name      = 'Beard2019AG2'
        Memory    = 1GB
        IPAddress = '192.168.2.58'
    }
    @{
        Role      = 'SQLServer2019', 'FailoverNode'
        # Properties = @{InstallSampleDatabase = 'true' }
        Name      = 'Beard2019AG3'
        Memory    = 1GB
        IPAddress = '192.168.2.59'
    }
    @{
        Role      = 'SQLServer2019', 'FailoverNode'
        # Properties = @{InstallSampleDatabase = 'true' }
        Name      = 'Beard2019AG4'
        Memory    = 1GB
        IPAddress = '192.168.2.60'
    }
)

$GenericBlankBoxes = @(
    @{
        Name            = 'WS2022Vm1'
        Memory          = 1GB
        IPAddress       = '192.168.2.61'
        OperatingSystem = 'Windows Server 2022 Datacenter (Desktop Experience)'
    }
    @{
        Name            = 'WS2019Vm1'
        Memory          = 1GB
        IPAddress       = '192.168.2.62'
        OperatingSystem = 'Windows Server 2022 Datacenter (Desktop Experience)'
    }
    @{
        Name            = 'WS2022Vm2'
        Memory          = 1GB
        IPAddress       = '192.168.2.63'
        OperatingSystem = 'Windows Server 2022 Datacenter (Desktop Experience)'
    }
    @{
        Name            = 'WS2019Vm2'
        Memory          = 1GB
        IPAddress       = '192.168.2.64'
        OperatingSystem = 'Windows Server 2022 Datacenter (Desktop Experience)'
    }
    @{
        Name            = 'WS2022Vm3'
        Memory          = 1GB
        IPAddress       = '192.168.2.65'
        OperatingSystem = 'Windows Server 2022 Datacenter (Desktop Experience)'
    }
    @{
        Name            = 'WS2019Vm3'
        Memory          = 1GB
        IPAddress       = '192.168.2.66'
        OperatingSystem = 'Windows Server 2022 Datacenter (Desktop Experience)'
    }
)

$AllMachines = $SQLServers + $GenericBlankBoxes + @(
    @{
        Name = $CLientVM
    },
    @{
        Name = $dc1
    }
    @{
        Name = $dc2
    }
    @{
        Name = $FileServer
    }
    @{
        Name = $DemoMachine
    }
)

#create an empty lab template and define where the lab XML files and the VMs will be stored
if ((Get-Lab -List) -contains $LabName) {
    Import-LabDefinition  -Name $LabName
    $LabDefinition = Get-LabDefinition
} else {
    New-LabDefinition -Name $labName -DefaultVirtualizationEngine Azure
    Add-LabAzureSubscription -DefaultLocationName $azureDefaultLocation  -AllowBastionHost -SubscriptionId $SubscriptionId -AutoShutdownTime 18:00 -AutoShutdownTimeZone 'UTC'
}


if (Get-LabVirtualNetwork) {} else {
    #make the network definition
    Add-LabVirtualNetworkDefinition -Name $labName -AddressSpace 192.168.2.0/24

}

if (Get-LabDomainDefinition) {} else {
    #and the domain definition with the domain admin account
    Add-LabDomainDefinition -Name $DomainName  -AdminUser theboss -AdminPassword $AdminPass
}


Set-LabInstallationCredential -Username theboss -Password $AdminPass

#defining default parameter values, as these ones are the same for all the machines
$PSDefaultParameterValues = @{
    'Add-LabMachineDefinition:Network'         = $labName
    'Add-LabMachineDefinition:ToolsPath'       = "$labSources\Tools"
    'Add-LabMachineDefinition:DomainName'      = $DomainName
    'Add-LabMachineDefinition:DnsServer1'      = '192.168.2.10'
    'Add-LabMachineDefinition:DnsServer2'      = '192.168.2.11'
    'Add-LabMachineDefinition:OperatingSystem' = 'Windows Server 2016 Datacenter (Desktop Experience)'
}

if ($LabDefinition.Machines | Where-Object { $_.Roles -like 'RootDC' -and $_.Name -eq $dc1 }) {} else {
    #the first machine is the root domain controller
    $roles = Get-LabMachineRoleDefinition -Role RootDC
    #The PostInstallationActivity is just creating some users
    $postInstallActivity = @()
    $postInstallActivity += Get-LabPostInstallationActivity -ScriptFileName 'New-ADLabAccounts 2.0.ps1' -DependencyFolder $labSources\PostInstallationActivities\PrepareFirstChildDomain
    $postInstallActivity += Get-LabPostInstallationActivity -ScriptFileName PrepareRootDomain.ps1 -DependencyFolder $labSources\PostInstallationActivities\PrepareRootDomain

    $DC1Config = @{
        Name                     = $dc1
        Memory                   = 512MB
        Roles                    = $roles
        IpAddress                = '192.168.2.10'
        DNSServer1               = '192.168.2.10'
        DNSServer2               = '192.168.2.11'
        PostInstallationActivity = $postInstallActivity
    }
    Add-LabMachineDefinition @dc1Config
}

if ($LabDefinition.Machines | Where-Object { $_.Roles -like 'DC' -and $_.Name -eq $dc2 }) {} else {
    #the root domain gets a second domain controller
    $roles = Get-LabMachineRoleDefinition -Role DC

    $DC2Config = @{
        Name       = $dc2
        Memory     = 512MB
        Roles      = $roles
        IpAddress  = '192.168.2.11'
        DNSServer1 = '192.168.2.11'
        DNSServer2 = '192.168.2.10'
    }
    Add-LabMachineDefinition @dc2Config
}

If ($LabDefinition.Machines | Where-Object { $_.Roles -like 'FileServer' -and $_.Name -eq $FileServer }) {} else {
    #file server
    $roles = Get-LabMachineRoleDefinition -Role FileServer
    Add-LabDiskDefinition -Name premium1 -DiskSizeInGb 128

    # Using SSD storage for the additional disks
    Add-LabMachineDefinition -Name $FileServer -Memory 512MB -DiskName premium1 -Roles $roles -IpAddress 192.168.2.50 -AzureProperties @{StorageSku = 'StandardSSD_LRS' }
}

foreach ($SQLServer in $SQLServers) {
    if ($LabDefinition.Machines | Where-Object { $_.Roles -like $SQLServer.Role -and $_.Name -eq $SQLServer.Name }) {
        Write-PsfMessage -level Output -Message ('All good for {0}' -f $SQLServer.Name)
    } else {
        $role = Get-LabMachineRoleDefinition -Role $SQLServer.Role -Properties $SQLServer.Properties
        if ( Get-LabMachineDefinition  -ComputerName $SQLServer.Name ) {
            Write-PsfMessage -Level Output -Message ("Machine exists but roles don't match on {0}" -f $SqlServer.Name)
            Remove-LabMachineDefinition -Name $SQLServer.Name
        }
        Add-LabMachineDefinition -Name $SQLServer.Name -Memory $SQLServer.Memory -Roles $role -IpAddress $SQLServer.IPAddress
    }
}

if ($LabDefinition.Machines | Where-Object { $_.Name -eq $ClientVM }) {} else {
    #a
    #Development client in the child domain a with some extra tools
    Add-LabMachineDefinition -Name $ClientVM -Memory 1GB -IpAddress 192.168.2.54
}
if ($LabDefinition.Machines | Where-Object { $_.Name -eq $DemoMachine }) {} else {
    #a
    #Development client in the child domain a with some extra tools
    Add-LabMachineDefinition -Name $DemoMachine -Memory 1GB -IpAddress 192.168.2.67 -OperatingSystem 'Windows 11 Pro' -AzureProperties @{ RoleSize = 'Standard_DS3_v2' }
}

foreach ($GenericHost in $GenericBlankBoxes) {
    if ($LabDefinition.Machines | Where-Object { $_.Name -eq $GenericHost.Name }) {} else {
        Add-LabMachineDefinition -Name $GenericHost.Name -Memory $GenericHost.Memory -IpAddress $GenericHost.IPAddress -OperatingSystem $GenericHost.OperatingSystem
    }
}


Install-Lab -Verbose

Show-LabDeploymentSummary -Detailed

# add inbound firewall rule for TCP 1433, 5022 and remote management
foreach ($Machine in $AllMachines) {
    $ActivityName = "firewall rules for {0}" -f $Machine.Name
    Invoke-LabCommand -FilePath .\Environment\AutomatedLab\AllMachines\firewall.ps1 -ComputerName $Machine.Name -DoNotUseCredSsp -ActivityName $ActivityName

    Copy-LabFileItem -Path Environment\AutomatedLab\AllMachines\logon.bgi -ComputerName $Machine.Name -DestinationFolderPath C:\BgInfo

    $ActivityName = "BGInfo for {0}" -f $Machine.Name
    Invoke-LabCommand -FilePath .\Environment\AutomatedLab\AllMachines\bginfo.ps1 -ComputerName $Machine.Name  -ActivityName $ActivityName
}

foreach ($SQLServer in $SQLServers) {
    $ActivityName = "SQL Start for {0}" -f $SQLServer.Name
    Invoke-LabCommand -FilePath .\Environment\AutomatedLab\AllMachines\startsql.ps1 -ComputerName $SQLServer.Name -DoNotUseCredSsp -ActivityName $ActivityName
}

foreach ($VM in @($DemoMachine, $CLientVM)) {

    Get-ChildItem .\Environment\AutomatedLab\ClientMachines -File | Sort-Object Name | ForEach-Object {
        $ActivityName = 'Client VM {0} Setup - {1}' -f $Vm, ($_.Name -replace '.ps1', '' )
        Write-PSFMessage -Message $ActivityName -Level Output
        Invoke-LabCommand -FilePath $_.FullName -ComputerName $Vm -DoNotUseCredSsp -ActivityName $ActivityName
        if ($_.Name -eq '02-chocolatey-install.ps1') {
           Restart-LabVM -Name $VM -Wait
        }
    }
}

# sql setup
Get-ChildItem .\Environment\AutomatedLab\SqlSetup -File | Sort-Object Name | ForEach-Object {
    $ActivityName = 'SQL Setup - {0}' -f ($_.Name -replace '.ps1', '' )
    Write-PSFMessage -Message $ActivityName -Level Output
    Invoke-LabCommand -FilePath $_.FullName -ComputerName $DemoMachine -DoNotUseCredSsp -ActivityName $ActivityName
}

Invoke-LabCommand -FilePath .\Environment\AutomatedLab\fileserversetup.ps1 -ComputerName $FileServer -DoNotUseCredSsp -ActivityName 'FileServer'


Stop-LabVM -All

