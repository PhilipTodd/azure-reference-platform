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
output sqlDatabaseId string = sqlDatabase.outputs.databaseId
output sqlDatabaseName string = sqlDatabase.outputs.databaseName

output cosmosAccountName string = cosmosAccount.outputs.accountName
output cosmosDatabaseName string = cosmosDatabase.outputs.databaseName
output cosmosEndpoint string = cosmosAccount.outputs.documentEndpoint

output serviceBusNamespaceId string = serviceBusNamespace.outputs.namespaceId
output serviceBusNamespaceName string = serviceBusNamespace.outputs.namespaceName
output serviceBusEndpoint string = serviceBusNamespace.outputs.serviceBusEndpoint
