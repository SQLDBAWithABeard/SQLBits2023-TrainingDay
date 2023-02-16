$resourceGroup = 'SQLBits2023-TrainingDay'

$location = 'uksouth'
$SubscriptionId = '6d8f994c-9051-4cef-ba61-528bab27d213' # Robs Beard MVP

Set-AzContext -SubscriptionId $SubscriptionId

$DatabaseNames = 'KellySmith', 'FaraWilliams', 'RachelYankey', 'JodieTaylor', 'KarenCarney', 'EllenWhite', 'AlexScott', 'EniolaAluko', 'RachelBrown-Finnis', 'ToniDuggan', 'CaseyStoney', 'NatashaDowie', 'AngharadJames', 'LianneSanderson', 'JillScott', 'GeorgiaStanway', 'KarenWalker', 'LucyBronze', 'SueSmith', 'KatieChapman', 'DionneLennon', 'FranKirby', 'KarenBardsley', 'AlexGreenwood', 'RachelDaly', 'KeiraWalsh'

$AdminUser = 'jesspomfretobe'
$AdminPassword = 'dbatools.IO' | ConvertTo-SecureString -AsPlainText -Force

$NumberOneConfig = @{
    ResourceGroupName          = $resourceGroup
    location                   = $location
    TemplateFile               = 'Environment\AutomatedLab\Bicep\05sqlserveranddatabaseswithlooparray.bicep'
    Name                       = 'releasenumberone'
    sqlserverName              = 'hopepowell'
    administratorLogin         = $AdminUser
    administratorLoginPassword = $AdminPassword
    databaseNames              = (Get-Random -Count 7 $DatabaseNames  )
}
New-AzResourceGroupDeployment @NumberOneConfig

$NumberTwoConfig = @{
    ResourceGroupName          = $resourceGroup
    TemplateFile               = 'Environment\AutomatedLab\Bicep\05sqlserveranddatabaseswithlooparray.bicep'
    location                   = $location
    Name                       = 'releasenumbertwo'
    sqlserverName              = 'sarinawiegman'
    administratorLogin         = $AdminUser
    administratorLoginPassword = $AdminPassword
    databaseNames              = (Get-Random -Count 7 $DatabaseNames  )

}
New-AzResourceGroupDeployment @NumberTwoConfig


# Connect-AzAccount
# Select-AzSubscription -SubscriptionId <xxxxxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx>


$VNetName = Get-AzVirtualNetwork -ResourceGroupName $resourceGroup | Select-Object -ExpandProperty Name
$SubnetName = 'default'              # Subnet name
$ILBName = 'rainbowagilb'            # ILB name
$VMNames = 'Beard2019AG1', 'Beard2019AG2', 'Beard2019AG3', 'Beard2019AG4'                   # Virtual machine names
$location = 'westeurope'
$ILBIP = "192.168.2.68"                         # IP address
[int]$ListenerPort = "1433"                # AG listener port
[int]$ProbePort = "59999"                   # Probe port
$storageName = 'beard2019agstorage'

#https://learn.microsoft.com/en-us/azure/azure-sql/virtual-machines/windows/availability-group-az-commandline-configure?view=azuresql&tabs=azure-powershell

$StorageAccountConfig = @{
    ResourceGroupName      = $resourceGroup
    Name                   = $storageName
    SkuName                = 'Standard_LRS'
    Location               = $location
    Kind                   = 'StorageV2'
    AccessTier             = 'Hot'
    EnableHttpsTrafficOnly = $true
}

New-AzStorageAccount @StorageAccountConfig

$storageAccountPrimaryKey = (Get-AzStorageAccountKey -ResourceGroupName $resourceGroup -Name $storageName )[0].Value | ConvertTo-SecureString -AsPlainText -Force

$SQLVMGroupConfig = @{
    Name                     = 'Duck' # cluster name
   # Location                 = $location
    ResourceGroupName        = $resourceGroup
    #Offer                    = 'SQL2019-WS2019'
   # Sku                      = 'Enterprise'
    DomainFqdn               = 'jessandbeard.local'
    ClusterOperatorAccount   = 'theboss'
    ClusterBootstrapAccount  = 'theboss'
    SqlServiceAccount        = 'sql'
    storageAccountURl        = 'https://beard2019agstorage.blob.core.windows.net/'
    StorageAccountPrimaryKey = $storageAccountPrimaryKey

}
$group = New-AzSqlVMGroup @SQLVMGroupConfig


foreach ($VMName in $VMNames[0..2]) {
    Write-Host "Working on $VMName"

    try {
        Get-AzSqlVM -Name $VMName -ResourceGroupName $resourceGroup -ErrorAction Stop
    } catch {
        # Get the existing Compute VM
        $vm = Get-AzVM -Name $VMName -ResourceGroupName $resourceGroup

        New-AzSqlVM -Name $VMName -ResourceGroupName $resourceGroup -Location $location -LicenseType PAYG -SqlManagementType Full
    }

    $VM = Get-AzSqlVM -Name $VMName -ResourceGroupName $resourceGroup
    $VM.SqlManagementType = 'Full'
    $AzSqlVMConfigGroupConfig = @{
        SqlVM                           = $VM
        SqlVMGroup                      = $group
        ClusterOperatorAccountPassword  = ('dbatools.IO1' | ConvertTo-SecureString -AsPlainText -Force)
        ClusterBootstrapAccountPassword = ('dbatools.IO1' | ConvertTo-SecureString -AsPlainText -Force)
        SqlServiceAccountPassword       = ('dbatools.IO1' | ConvertTo-SecureString -AsPlainText -Force)

    }
    $SQlVMConfig = Set-AzSqlVMConfigGroup  @AzSqlVMConfigGroupConfig
    Write-Host "Updating it"
    Update-AzSqlVM -ResourceId $VM.ResourceId -SqlVM $SQlVMConfig
    Write-Host "Done"
}

$LoadBalancerConfig = @{
    Name              = $ILBName
    ResourceGroupName = $resourceGroup
    Location          = $location
    Sku               = 'Standard'
}
New-AzLoadBalancer @LoadBalancerConfig

$VMIds = foreach ($VMName in $VMNames) {
        (Get-AzSQLVM -Name $VMName -ResourceGroupName $resourceGroup).Id
}

$ListenerConfig = @{
    Name                   = 'dragonlist'
    ResourceGroupName      = $resourceGroup
    AvailabilityGroupName  = 'DragonAg'
    GroupName              = 'Duck' # cluster name
    IpAddress              = $ILBIP
    LoadBalancerResourceId = (Get-AzLoadBalancer -Name $ILBName -ResourceGroupName $resourceGroup).Id
    ProbePort              = $ProbePort
    SubnetId               = ((Get-AzVirtualNetwork -Name $VNetName -ResourceGroupName $resourceGroup).Subnets | where Name -EQ $SubnetName).Id
    SqlVirtualMachineId    = $VMIds[0..2]
}
New-AzAvailabilityGroupListener @ListenerConfig

az sql vm group ag-listener create -n 'dragonlist' -g $resourceGroup `
  --ag-name 'DragonAg' --group-name 'Duck'--ip-address $ILBIP `
  --load-balancer $ILBName  --probe-port $ProbePort  `
  --subnet ((Get-AzVirtualNetwork -Name $VNetName -ResourceGroupName $resourceGroup).Subnets | where Name -EQ $SubnetName).Id `
  --sqlvms $VMNames
