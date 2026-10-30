targetScope = 'subscription'

@description('Default deployment location.')
param platformLocation string

@description('Deployment environment.')
@allowed([
  'dev'
  'test'
  'prod'
])
param environment string = 'dev'

@description('Globally unique prefix for shared platform resources.')
param globalNamePrefix string = 'adt'

// Shared gateway and image hosting, managed through this platform entry point.
@description('Shared classic APIM Developer service name.')
param apiManagementName string = 'apim-${globalNamePrefix}-platform-${environment}'
@description('APIM deployment region.')
param apiManagementLocation string = platformLocation
@description('Owner-approved APIM publisher contact; not a secret.')
param apiManagementPublisherEmail string
@description('APIM publisher display name.')
param apiManagementPublisherName string = 'Aus Data Tech'
@description('Globally unique shared ACR Basic name.')
param containerRegistryName string = 'acr${globalNamePrefix}platform${environment}'
@description('Container registry deployment region.')
param containerRegistryLocation string = platformLocation

@description('Platform resource group name.')
param platformResourceGroupName string = 'rg-platform-${environment}'

// app service plan
@description('Shared Linux App Service Plan name.')
param appServicePlanName string = 'asp-platform-${environment}'
@description('App Service Plan SKU.')
param appServicePlanSku string = 'B1'
@description('App Service Plan location.')
param appServicePlanLocation string


// Log analytics
@description('Log Analytics workspace name.')
param logAnalyticsWorkspaceName string = 'log-platform-${environment}'
@description('Log Analytics retention period in days.')
param logAnalyticsRetentionInDays int = 30
@description('Log Analytics location.')
param logAnalyticsLocation string

// Application insights
@description('Application Insights resource name.')
param applicationInsightsName string = 'appi-platform-${environment}'
@description('Application Insights location.')
param applicationInsightsLocation string

// Azure SQL Server
@description('Azure SQL logical server name.')
param sqlServerName string = 'sql-${globalNamePrefix}-platform-${environment}'
@description('Azure SQL administrator login.')
param sqlAdministratorLogin string
@secure()
@description('Azure SQL administrator password.')
param sqlAdministratorPassword string
@description('Azure SQL location.')
param sqlLocation string

@description('Entra SQL administrator group object ID. Empty leaves the existing administrator unmanaged; it does not remove one.')
param sqlEntraAdminGroupObjectId string = ''
@description('Verified display name of the dedicated Entra SQL administrator group.')
param sqlEntraAdminGroupName string = 'sg-adt-platform-sql-admins-${environment}'

// Azure SQL DB
@description('Name of the shared Azure SQL database.')
param sqlDatabaseName string
@description('Azure SQL Database SKU name.')
param sqlDatabaseSkuName string = 'Basic'
@description('Azure SQL Database SKU tier.')
param sqlDatabaseSkuTier string = 'Basic'
@description('Maximum Azure SQL Database size in bytes.')
param sqlDatabaseMaxSizeBytes int = 2147483648

// Azure Cosmos
@description('Cosmos account name.')
param cosmosAccountName string
@description('Cosmos database name.')
param cosmosDatabaseName string
@description('Database throughput.')
@minValue(400)
param cosmosDatabaseThroughput int = 400
@description('Cosmos location.')
param cosmosLocation string
@description('Default Cosmos DB consistency level.')
@allowed([
  'Strong'
  'BoundedStaleness'
  'Session'
  'ConsistentPrefix'
  'Eventual'
])
param cosmosConsistencyLevel string = 'Session'
@description('Enable the Azure Cosmos DB free tier.')
param cosmosEnableFreeTier bool = true

// Service bus
@description('Name of the shared Azure Service Bus namespace.')
param serviceBusNamespaceName string

@description('Service Bus pricing tier.')
@allowed([
  'Standard'
  'Premium'
])
param serviceBusSkuName string = 'Standard'
@description('Service Bus location.')
param serviceBusLocation string = platformLocation

// Tags
@description('Tags applied to all resources.')
param tags object = {
  environment: environment
  managedBy: 'bicep'
  platform: 'azure-reference-platform'
  purpose: 'reference-project'
}

// Create the platform resource group
resource platformResourceGroup 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  name: platformResourceGroupName
  location: platformLocation
  tags: tags
}

// run the sub-modules
module appServicePlan 'modules/app-service-plan.bicep' = {
  name: 'app-service-plan'
  scope: platformResourceGroup

  params: {
    location: appServicePlanLocation
    appServicePlanName: appServicePlanName
    skuName: appServicePlanSku
    tags: tags
  }
}

module logAnalytics 'modules/log-analytics.bicep' = {
  name: 'log-analytics'
  scope: platformResourceGroup

  params: {
    workspaceName: logAnalyticsWorkspaceName
    location: logAnalyticsLocation
    retentionInDays: logAnalyticsRetentionInDays
    tags: tags
  }
}

module applicationInsights 'modules/application-insights.bicep' = {
  name: 'application-insights'
  scope: platformResourceGroup

  params: {
    applicationInsightsName: applicationInsightsName
    location: applicationInsightsLocation
    logAnalyticsWorkspaceId: logAnalytics.outputs.workspaceId
    tags: tags
  }
}

module sqlServer 'modules/sql-server.bicep' = {
  name: 'sql-server'
  scope: platformResourceGroup

  params: {
    serverName: sqlServerName
    location: sqlLocation
    administratorLogin: sqlAdministratorLogin
    administratorPassword: sqlAdministratorPassword
    entraAdminGroupObjectId: sqlEntraAdminGroupObjectId
    entraAdminGroupName: sqlEntraAdminGroupName
    tags: tags
  }
}

module sqlDatabase 'modules/sql-database.bicep' = {
  name: 'sql-database'
  scope: platformResourceGroup

  params: {
    serverName: sqlServer.outputs.serverName
    databaseName: sqlDatabaseName
    location: sqlLocation
    skuName: sqlDatabaseSkuName
    skuTier: sqlDatabaseSkuTier
    maxSizeBytes: sqlDatabaseMaxSizeBytes
    tags: tags
  }
}

module cosmosAccount 'modules/cosmos-account.bicep' = {
  name: 'cosmos-account'
  scope: platformResourceGroup
  params: {
    accountName: cosmosAccountName
    location: cosmosLocation
    consistencyLevel: cosmosConsistencyLevel
    enableFreeTier: cosmosEnableFreeTier
    tags: tags
  }
}

module cosmosDatabase 'modules/cosmos-database.bicep' = {
  name: 'cosmos-database'
  scope: platformResourceGroup
  params: {
    accountName: cosmosAccount.outputs.accountName
    databaseName: cosmosDatabaseName
    location: cosmosLocation
    throughput: cosmosDatabaseThroughput
    tags: tags
  }
}

module serviceBusNamespace 'modules/service-bus-namespace.bicep' = {
  name: 'service-bus-namespace'
  scope: platformResourceGroup

  params: {
    namespaceName: serviceBusNamespaceName
    location: serviceBusLocation
    skuName: serviceBusSkuName
    publicNetworkAccess: 'Enabled'
    disableLocalAuth: false
    tags: tags
  }
}
// End sub-modules

module apiManagement 'modules/api-management.bicep' = {
  name: 'platform-api-management'
  scope: platformResourceGroup
  params: {
    serviceName: apiManagementName
    location: apiManagementLocation
    publisherEmail: apiManagementPublisherEmail
    publisherName: apiManagementPublisherName
    tags: tags
  }
}

module containerRegistry 'modules/container-registry.bicep' = {
  name: 'platform-container-registry'
  scope: platformResourceGroup
  params: {
    registryName: containerRegistryName
    location: containerRegistryLocation
    tags: tags
  }
}

// Output values from sub-modules
output resourceGroupName string = platformResourceGroup.name

output appServicePlanName string = appServicePlan.outputs.appServicePlanName
output appServicePlanId string = appServicePlan.outputs.appServicePlanId

output logAnalyticsWorkspaceName string = logAnalytics.outputs.workspaceName
output logAnalyticsWorkspaceId string = logAnalytics.outputs.workspaceId

output applicationInsightsName string = applicationInsights.outputs.applicationInsightsName
output applicationInsightsId string = applicationInsights.outputs.applicationInsightsId
output applicationInsightsConnectionString string = applicationInsights.outputs.connectionString

output sqlServerName string = sqlServer.outputs.serverName
output sqlServerId string = sqlServer.outputs.serverId
output sqlServerFqdn string = sqlServer.outputs.fullyQualifiedDomainName
output sqlEntraAdminGroupObjectId string = sqlEntraAdminGroupObjectId
output sqlDatabaseId string = sqlDatabase.outputs.databaseId
output sqlDatabaseName string = sqlDatabase.outputs.databaseName

output cosmosAccountName string = cosmosAccount.outputs.accountName
output cosmosDatabaseName string = cosmosDatabase.outputs.databaseName
output cosmosEndpoint string = cosmosAccount.outputs.documentEndpoint

output serviceBusNamespaceId string = serviceBusNamespace.outputs.namespaceId
output serviceBusNamespaceName string = serviceBusNamespace.outputs.namespaceName
output serviceBusEndpoint string = serviceBusNamespace.outputs.serviceBusEndpoint

output apiManagementId string = apiManagement.outputs.serviceId
output apiManagementName string = apiManagement.outputs.serviceName
output apiManagementGatewayUrl string = apiManagement.outputs.gatewayUrl
output apiManagementPublicIpAddresses array = apiManagement.outputs.publicIpAddresses
output apiManagementPrincipalId string = apiManagement.outputs.principalId
output containerRegistryId string = containerRegistry.outputs.registryId
output containerRegistryName string = containerRegistry.outputs.registryName
output containerRegistryLoginServer string = containerRegistry.outputs.loginServer
