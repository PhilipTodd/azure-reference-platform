targetScope = 'subscription'

@description('Azure region used for the shared platform resources.')
param location string = 'australiaeast'

@description('Deployment environment.')
@allowed([
  'dev'
  'test'
  'prod'
])
param environment string = 'dev'

@description('Name of the shared platform resource group.')
param platformResourceGroupName string = 'rg-platform-${environment}'

@description('Tags applied to the platform resource group.')
param tags object = {
  environment: environment
  managedBy: 'bicep'
  platform: 'azure-reference-platform'
  purpose: 'reference-project'
}

resource platformResourceGroup 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  name: platformResourceGroupName
  location: location
  tags: tags
}

output resourceGroupName string = platformResourceGroup.name
output resourceGroupId string = platformResourceGroup.id
output resourceGroupLocation string = platformResourceGroup.location
