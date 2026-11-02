targetScope = 'resourceGroup'

@description('Azure SQL logical server name.')
param serverName string

@description('Azure region.')
param location string

@description('Administrator login.')
param administratorLogin string

@secure()
@description('Administrator password.')
param administratorPassword string

@description('Verified Entra security group object ID. Empty skips administrator management.')
param entraAdminGroupObjectId string = ''
@description('Verified Entra administrator security group display name.')
param entraAdminGroupName string = ''

@description('Tags applied to the SQL Server.')
param tags object = {}

resource sqlServer 'Microsoft.Sql/servers@2023-08-01-preview' = {
  name: serverName
  location: location
  tags: tags

  properties: {
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorPassword
    version: '12.0'
    publicNetworkAccess: 'Enabled'
    minimalTlsVersion: '1.2'
  }
}

// Directory group creation/membership is a separate bootstrap step. This child
// configures SQL only; no firewall, directory grant or Entra-only auth change.
resource entraAdministrator 'Microsoft.Sql/servers/administrators@2023-08-01' = if (!empty(entraAdminGroupObjectId)) {
  parent: sqlServer
  name: 'ActiveDirectory'
  properties: {
    administratorType: 'ActiveDirectory'
    login: entraAdminGroupName
    sid: entraAdminGroupObjectId
    tenantId: tenant().tenantId
  }
}

output serverId string = sqlServer.id
output serverName string = sqlServer.name
output fullyQualifiedDomainName string = sqlServer.properties.fullyQualifiedDomainName
