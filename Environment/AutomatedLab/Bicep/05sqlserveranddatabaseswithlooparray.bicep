// this will deploy with modules

@minLength(1)
@maxLength(63)
@description('The name of the SQL server - Lowercase letters, numbers, and hyphens.Cant start or end with hyphen.')
param sqlserverName string

@description('The location for the SQL Server')
param location string = resourceGroup().location

@description('The name of the administrator login')
param administratorLogin string

@description('The password for the SQL Server Administratoe')
@secure()
param administratorLoginPassword string

@description('The name of databases to create ')
param databaseNames array

var tags = {
  BeKind: 'Always'
  role: 'Azure SQL'
  owner: 'Beardy McBeardFace'
  budget: 'Ben Weissman personal account'
  bicep: true
}

module sqlserver 'Data/sqlserver.bicep' = {
  name: 'Deploy_the_${sqlserverName}_SQL_Server'
  params: {
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorLoginPassword
    location: location
    name: sqlserverName
    tags: tags
  }
}

module sqldatabase 'Data/database.bicep' = [for databaseName in databaseNames: {
  name: 'Deploy_The_${databaseName}_Database'
  params: {
    sqlServerName: sqlserverName
    location: location
    name: databaseName
  }
  dependsOn: [
    sqlserver
  ]
}]
