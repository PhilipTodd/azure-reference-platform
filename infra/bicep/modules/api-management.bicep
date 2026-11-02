targetScope = 'resourceGroup'

@description('Shared Development API Management service name.')
@minLength(1)
@maxLength(50)
param serviceName string

@description('Azure region for the Development gateway.')
param location string

@description('Owner-approved publisher contact; not a secret.')
@minLength(3)
param publisherEmail string

@description('Publisher display name.')
@minLength(1)
param publisherName string

@description('Resource tags.')
param tags object = {}

resource gateway 'Microsoft.ApiManagement/service@2024-05-01' = {
  name: serviceName
  location: location
  sku: {
    name: 'Developer'
    capacity: 1
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    publisherEmail: publisherEmail
    publisherName: publisherName
    publicNetworkAccess: 'Enabled'
    virtualNetworkType: 'None'
    // Preserve the live disabled legacy portal during full-platform redeployments.
    legacyPortalStatus: 'Disabled'
    customProperties: {
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Protocols.Server.Http2': 'False'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TripleDes168': 'False'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Protocols.Tls10': 'false'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Protocols.Tls11': 'false'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Protocols.Ssl30': 'false'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Backend.Protocols.Tls10': 'false'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Backend.Protocols.Tls11': 'false'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Backend.Protocols.Ssl30': 'false'
    }
  }
  tags: tags
}

// No application API is ready yet. This guard also covers provider-created sample APIs.
// Replace only through a coordinated gateway-policy change with authentication verified.
resource bootstrapPolicy 'Microsoft.ApiManagement/service/policies@2024-05-01' = {
  parent: gateway
  name: 'policy'
  properties: {
    format: 'rawxml'
    value: '''
<policies>
  <inbound>
    <return-response>
      <set-status code="503" reason="Service Unavailable" />
      <set-header name="Content-Type" exists-action="override">
        <value>application/json</value>
      </set-header>
      <set-body>{"code":"gateway-not-configured"}</set-body>
    </return-response>
  </inbound>
  <backend><forward-request /></backend>
  <outbound />
  <on-error />
</policies>
'''
  }
}

output serviceId string = gateway.id
output serviceName string = gateway.name
output gatewayUrl string = gateway.properties.gatewayUrl
output publicIpAddresses array = gateway.properties.publicIPAddresses ?? []
output principalId string = gateway.identity.principalId
