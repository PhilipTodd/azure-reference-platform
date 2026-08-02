@description('Name of the existing Azure Cosmos DB account.')
param accountName string

@description('Name of the Cosmos DB for NoSQL database.')
param databaseName string

@description('Azure region in which the database resource will be deployed.')
param location string

@description('Shared provisioned throughput for the database in request units per second.')
@minValue(400)
param throughput int = 400

@description('Tags applied to the Cosmos DB database.')
param tags object = {}

resource cosmosAccount 'Microsoft.DocumentDB/databaseAccounts@2025-10-15' existing = {
  name: accountName
}

resource cosmosDatabase 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2025-10-15' = {
  parent: cosmosAccount
  name: databaseName
  location: location

  properties: {
    resource: {
      id: databaseName
    }

    options: {
      throughput: throughput
    }
  }

  tags: tags
}

output databaseId string = cosmosDatabase.id
output databaseName string = cosmosDatabase.name
