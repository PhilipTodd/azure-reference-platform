@description('Name of the Azure Service Bus namespace.')
param namespaceName string

@description('Azure region in which the Service Bus namespace is deployed.')
param location string

@description('Service Bus pricing tier.')
@allowed([
  'Standard'
  'Premium'
])
param skuName string = 'Standard'

@description('Controls whether public network access is permitted.')
@allowed([
  'Enabled'
  'Disabled'
])
param publicNetworkAccess string = 'Enabled'

@description('Disables SAS-based local authentication when true.')
param disableLocalAuth bool = false

@description('Resource tags.')
param tags object = {}

resource serviceBusNamespace 'Microsoft.ServiceBus/namespaces@2026-01-01' = {
  name: namespaceName
  location: location

  sku: {
    name: skuName
    tier: skuName
  }

  properties: {
    minimumTlsVersion: '1.2'
    publicNetworkAccess: publicNetworkAccess
    disableLocalAuth: disableLocalAuth
  }

  tags: tags
}

output namespaceId string = serviceBusNamespace.id
output namespaceName string = serviceBusNamespace.name
output serviceBusEndpoint string = serviceBusNamespace.properties.serviceBusEndpoint
