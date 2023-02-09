@minLength(1)
@maxLength(63)
@description('The name of the SQL server - Lowercase letters, numbers, and hyphens.Cant start or end with hyphen.')
param sqlServerName string

@minLength(1)
@maxLength(128)
@description('Name of the database - Cant use: <>*%&:\\/? or control characters Cant end with period or space')
param name string

var dbName = sqlServerName == '' ? name : name

@description('The location for the SQL Server')
param location string = resourceGroup().location

resource sqldatabase 'Microsoft.Sql/servers/databases@2021-05-01-preview' = {
  name: '${sqlServerName}/${dbName}'
  location: location
  sku: {
    name: 'GP_S_Gen5'
    tier: 'GeneralPurpose'
    family: 'Gen5'
    capacity: 2
  }
  properties: {
    autoPauseDelay: 60
  }
}

output dbname string = sqldatabase.name
