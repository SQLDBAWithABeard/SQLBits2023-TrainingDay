@description('The name of the VM')
param sqlName string = 'myVM'

@description('The virtual machine size for the sql servers.')
param sqlVirtualMachineSize string = 'Standard_D8s_v3'

@description('The virtual machine size for the jumpbox.')
param jumpVirtualMachineSize string = 'Standard_D8s_v3'

@description('Specify the name of the VNet')
param VirtualNetworkName string

@description('Specify the name of the subnet for the SQL Servers')
param sqlsubnetname string = 'sql-subnet-1'

@description('Specify the name of the subnet for the jump box')
param jumpsubnetname string = 'jump-subnet-1'

@description('Windows Server and SQL Offer')
@allowed([
  'sql2019-ws2019'
  'sql2017-ws2019'
  'SQL2017-WS2016'
  'SQL2016SP1-WS2016'
  'SQL2016SP2-WS2016'
  'SQL2014SP3-WS2012R2'
  'SQL2014SP2-WS2012R2'
])
param imageOffer string = 'sql2019-ws2019'

@description('SQL Server Sku')
@allowed([
  'Standard'
  'Enterprise'
  'SQLDEV'
  'Web'
  'Express'
])
param sqlSku string = 'Standard'

@description('The admin user name of the VM')
param adminUsername string

@description('The admin password of the VM')
@secure()
param adminPassword string

@description('SQL Server Workload Type')
@allowed([
  'General'
  'OLTP'
  'DW'
])
param storageWorkloadType string = 'General'

@description('Amount of data disks (1TB each) for SQL Data files')
@minValue(1)
@maxValue(8)
param sqlDataDisksCount int = 1

@description('Path for SQL Data files. Please choose drive letter from F to Z, and other drives from A to E are reserved for system')
param dataPath string = 'F:\\SQLData'

@description('Amount of data disks (1TB each) for SQL Log files')
@minValue(1)
@maxValue(8)
param sqlLogDisksCount int = 1

@description('Path for SQL Log files. Please choose drive letter from F to Z and different than the one used for SQL data. Drive letter from A to E are reserved for system')
param logPath string = 'G:\\SQLLog'

@description('Location for all resources.')
param location string = resourceGroup().location

@description('The tags that should be added to the resource')
param tags object = {}

// both vms
var networkSecurityGroupRules = [
  {
    name: 'RDP'
    properties: {
      priority: 300
      protocol: 'Tcp'
      access: 'Allow'
      direction: 'Inbound'
      sourceAddressPrefix: '*'
      sourcePortRange: '*'
      destinationAddressPrefix: '*'
      destinationPortRange: '3389'
    }
  }
]
var nsgId = sqlNetworkSecurityGroup.id

// jumpbox
param jumpName string

var jumpNetworkInterfaceName = '${jumpName}-nic'
var jumpNetworkSecurityGroupName = '${jumpName}-nsg'
var jumpPublicIpAddressName = '${jumpName}-publicip-${uniqueString(jumpName)}'
var jumpPublicIpAddressType = 'Dynamic'
var jumpPublicIpAddressSku = 'Basic'
var jumpsubnetId = resourceId('Microsoft.Network/virtualNetworks/subnets', VirtualNetworkName, jumpsubnetname)


// sql
var sqlNetworkInterfaceName = '${sqlName}-nic'
var sqlNetworkSecurityGroupName = '${sqlName}-nsg'
var sqlPublicIpAddressName = '${sqlName}-publicip-${uniqueString(sqlName)}'
var sqlPublicIpAddressType = 'Dynamic'
var sqlPublicIpAddressSku = 'Basic'
var diskConfigurationType = 'NEW'
var dataDisksLuns = range(0, sqlDataDisksCount)
var logDisksLuns = range(sqlDataDisksCount, sqlLogDisksCount)
var dataDisks = {
  createOption: 'Empty'
  caching: 'ReadOnly'
  writeAcceleratorEnabled: false
  storageAccountType: 'Premium_LRS'
  diskSizeGB: 1023
}
var tempDbPath = 'D:\\SQLTemp'
var sqlsubnetId = resourceId('Microsoft.Network/virtualNetworks/subnets', VirtualNetworkName, sqlsubnetname)

/////////////////////////////
//        RESOURCES        //
/////////////////////////////

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2019-11-01' = {
  name: VirtualNetworkName
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: sqlsubnetname
        properties: {
          addressPrefix: '10.0.0.0/24'
        }
      }
      {
        name: jumpsubnetname
        properties: {
          addressPrefix: '10.0.1.0/24'
        }
      }
    ]
  }
}


//jumpbox
resource jumpPublicIpAddress 'Microsoft.Network/publicIPAddresses@2022-01-01' = {
  name: jumpPublicIpAddressName
  location: location
  tags: tags
  sku: {
    name: jumpPublicIpAddressSku
  }
  properties: {
    publicIPAllocationMethod: jumpPublicIpAddressType
  }
}

resource jumpNetworkSecurityGroup 'Microsoft.Network/NetworkSecurityGroups@2022-01-01' = {
  name: jumpNetworkSecurityGroupName
  location: location
  tags: tags
  properties: {
    securityRules: networkSecurityGroupRules
  }
}

resource jumpNetworkInterface 'Microsoft.Network/networkInterfaces@2022-01-01' = {
  name: jumpNetworkInterfaceName
  location: location
  tags: tags
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: jumpsubnetId
          }
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: jumpPublicIpAddress.id
          }
        }
      }
    ]
    enableAcceleratedNetworking: true
    networkSecurityGroup: {
      id: nsgId
    }
  }
}

resource jumpVirtualMachine 'Microsoft.Compute/virtualMachines@2022-03-01' = {
  name: jumpName
  location: location
  tags: tags
  properties: {
    hardwareProfile: {
      vmSize: jumpVirtualMachineSize
    }
    storageProfile: {
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Premium_LRS'
        }
      }
      imageReference: {
        publisher: 'MicrosoftSQLServer'
        offer: imageOffer
        sku: sqlSku
        version: 'latest'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: jumpNetworkInterface.id
        }
      ]
    }
    osProfile: {
      computerName: jumpName
      adminUsername: adminUsername
      adminPassword: adminPassword
      windowsConfiguration: {
        enableAutomaticUpdates: true
        provisionVMAgent: true
      }
    }
  }
}

//SQLServer
resource sqlPublicIpAddress 'Microsoft.Network/publicIPAddresses@2022-01-01' = {
  name: sqlPublicIpAddressName
  location: location
  tags: tags
  sku: {
    name: sqlPublicIpAddressSku
  }
  properties: {
    publicIPAllocationMethod: sqlPublicIpAddressType
  }
}

resource sqlNetworkSecurityGroup 'Microsoft.Network/NetworkSecurityGroups@2022-01-01' = {
  name: sqlNetworkSecurityGroupName
  location: location
  tags: tags
  properties: {
    securityRules: networkSecurityGroupRules
  }
}

resource sqlNetworkInterface 'Microsoft.Network/networkInterfaces@2022-01-01' = {
  name: sqlNetworkInterfaceName
  location: location
  tags: tags
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: sqlsubnetId
          }
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: sqlPublicIpAddress.id
          }
        }
      }
    ]
    enableAcceleratedNetworking: true
    networkSecurityGroup: {
      id: nsgId
    }
  }
}

resource sqlVirtualMachine 'Microsoft.Compute/virtualMachines@2022-03-01' = {
  name: sqlName
  location: location
  tags: tags
  properties: {
    hardwareProfile: {
      vmSize: sqlVirtualMachineSize
    }
    storageProfile: {
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Premium_LRS'
        }
      }
      imageReference: {
        publisher: 'MicrosoftSQLServer'
        offer: imageOffer
        sku: sqlSku
        version: 'latest'
      }
      dataDisks: [for j in range(0, (sqlDataDisksCount + sqlLogDisksCount)): {
        lun: j
        createOption: dataDisks.createOption
        caching: ((j >= sqlDataDisksCount) ? 'None' : dataDisks.caching)
        writeAcceleratorEnabled: dataDisks.writeAcceleratorEnabled
        diskSizeGB: dataDisks.diskSizeGB
        managedDisk: {
          storageAccountType: dataDisks.storageAccountType
        }
      }]
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: sqlNetworkInterface.id
        }
      ]
    }
    osProfile: {
      computerName: sqlName
      adminUsername: adminUsername
      adminPassword: adminPassword
      windowsConfiguration: {
        enableAutomaticUpdates: true
        provisionVMAgent: true
      }
    }
  }
}

resource sqlVirtualMachineSql 'Microsoft.SqlVirtualMachine/sqlVirtualMachines@2022-07-01-preview' = {
  name: sqlName
  location: location
  tags: tags
  properties: {
    virtualMachineResourceId: sqlVirtualMachine.id
    sqlManagement: 'Full'
    sqlServerLicenseType: 'PAYG'
    storageConfigurationSettings: {
      diskConfigurationType: diskConfigurationType
      storageWorkloadType: storageWorkloadType
      sqlDataSettings: {
        luns: dataDisksLuns
        defaultFilePath: dataPath
      }
      sqlLogSettings: {
        luns: logDisksLuns
        defaultFilePath: logPath
      }
      sqlTempDbSettings: {
        defaultFilePath: tempDbPath
      }
    }
  }
}

output adminUsername string = adminUsername
