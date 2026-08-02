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

output serverId string = sqlServer.id
output serverName string = sqlServer.name
output fullyQualifiedDomainName string = sqlServer.properties.fullyQualifiedDomainName
