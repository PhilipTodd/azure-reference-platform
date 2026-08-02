targetScope = 'resourceGroup'

@description('Name of the Log Analytics workspace.')
param workspaceName string

@description('Azure region in which the workspace is deployed.')
param location string

@description('Log Analytics workspace data-retention period in days.')
@minValue(30)
@maxValue(730)
param retentionInDays int = 30

@description('Tags applied to the Log Analytics workspace.')
param tags object = {}

resource workspace 'Microsoft.OperationalInsights/workspaces@2025-07-01' = {
  name: workspaceName
  location: location
  tags: tags

  properties: {
    sku: {
      name: 'PerGB2018'
    }

    retentionInDays: retentionInDays

    features: {
      enableLogAccessUsingOnlyResourcePermissions: true
    }

    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

output workspaceId string = workspace.id
output workspaceName string = workspace.name
output workspaceCustomerId string = workspace.properties.customerId
