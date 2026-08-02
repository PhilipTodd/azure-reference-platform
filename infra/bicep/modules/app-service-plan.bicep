targetScope = 'resourceGroup'

@description('Azure region for the App Service Plan.')
param location string

@description('Name of the App Service Plan.')
param appServicePlanName string

@description('App Service Plan SKU.')
@allowed([
  'B1'
  'B2'
  'B3'
])
param skuName string = 'B1'

@description('Number of App Service Plan workers.')
@minValue(1)
param workerCount int = 1

@description('Whether Azure may provision workers asynchronously when capacity is constrained.')
param asyncScalingEnabled bool = true

@description('Tags applied to the App Service Plan.')
param tags object = {}

resource appServicePlan 'Microsoft.Web/serverfarms@2024-11-01' = {
  name: appServicePlanName
  location: location
  kind: 'linux'

  sku: {
    name: skuName
    tier: 'Basic'
    size: skuName
    capacity: workerCount
  }

  properties: {
    reserved: true
    asyncScalingEnabled: asyncScalingEnabled
  }

  tags: tags
}

output appServicePlanId string = appServicePlan.id
output appServicePlanName string = appServicePlan.name
output appServicePlanSku string = appServicePlan.sku.name
