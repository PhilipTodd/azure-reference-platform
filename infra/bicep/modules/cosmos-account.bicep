@description('Globally unique Azure Cosmos DB account name.')
param accountName string

@description('Azure region in which the Cosmos DB account will be deployed.')
param location string

@description('Default Cosmos DB consistency level.')
@allowed([
  'Strong'
  'BoundedStaleness'
  'Session'
  'ConsistentPrefix'
  'Eventual'
])
param consistencyLevel string = 'Session'

@description('Whether the Cosmos DB free tier is enabled.')
param enableFreeTier bool = false

@description('Tags applied to the Cosmos DB account.')
param tags object = {}

resource cosmosAccount 'Microsoft.DocumentDB/databaseAccounts@2025-10-15' = {
  name: accountName
  location: location
  kind: 'GlobalDocumentDB'

  properties: {
    databaseAccountOfferType: 'Standard'

    consistencyPolicy: {
      defaultConsistencyLevel: consistencyLevel
    }

    locations: [
      {
        locationName: location
        failoverPriority: 0
        isZoneRedundant: false
      }
    ]

    enableAutomaticFailover: false
    enableMultipleWriteLocations: false
    enableFreeTier: enableFreeTier

    publicNetworkAccess: 'Enabled'
    disableLocalAuth: false
    minimalTlsVersion: 'Tls12'

    isVirtualNetworkFilterEnabled: false
  }

  tags: tags
}

output accountId string = cosmosAccount.id
output accountName string = cosmosAccount.name
output documentEndpoint string = cosmosAccount.properties.documentEndpoint
