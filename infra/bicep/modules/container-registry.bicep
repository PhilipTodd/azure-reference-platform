targetScope = 'resourceGroup'

@description('Globally unique shared registry name; letters/numbers only.')
@minLength(5)
@maxLength(50)
param registryName string

@description('Azure region for the shared registry.')
param location string

@description('Resource tags.')
param tags object = {}

resource registry 'Microsoft.ContainerRegistry/registries@2025-11-01' = {
  name: registryName
  location: location
  sku: {
    name: 'Basic'
  }
  properties: {
    adminUserEnabled: false
    anonymousPullEnabled: false
    publicNetworkAccess: 'Enabled'
    roleAssignmentMode: 'AbacRepositoryPermissions'
  }
  tags: tags
}

// No registry-wide or repository role assignments are created by this hosting module.
output registryId string = registry.id
output registryName string = registry.name
output loginServer string = registry.properties.loginServer
