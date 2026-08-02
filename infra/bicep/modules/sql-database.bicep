@description('Name of the existing Azure SQL logical server.')
param serverName string

@description('Name of the Azure SQL database.')
param databaseName string

@description('Azure region in which the database will be deployed.')
param location string

@description('Azure SQL Database SKU name.')
param skuName string = 'Basic'

@description('Azure SQL Database SKU tier.')
param skuTier string = 'Basic'

@description('Maximum database size in bytes.')
param maxSizeBytes int = 2147483648

@description('Database collation.')
param collation string = 'SQL_Latin1_General_CP1_CI_AS'

@description('Tags applied to the database.')
param tags object = {}

resource sqlServer 'Microsoft.Sql/servers@2023-08-01' existing = {
  name: serverName
}

resource sqlDatabase 'Microsoft.Sql/servers/databases@2023-08-01' = {
  parent: sqlServer
  name: databaseName
  location: location

  sku: {
    name: skuName
    tier: skuTier
  }

  properties: {
    collation: collation
    maxSizeBytes: maxSizeBytes
    zoneRedundant: false
  }

  tags: tags
}

output databaseId string = sqlDatabase.id
output databaseName string = sqlDatabase.name
