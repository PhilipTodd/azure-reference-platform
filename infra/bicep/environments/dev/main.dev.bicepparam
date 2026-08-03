using '../../main.bicep'

param platformLocation = 'australiaeast'

param environment = 'dev'

param platformResourceGroupName = 'rg-platform-dev'

param appServicePlanName = 'asp-platform-dev'
param appServicePlanSku = 'B1'
param appServicePlanLocation = platformLocation

param logAnalyticsWorkspaceName = 'log-platform-dev'
param logAnalyticsRetentionInDays = 30
param logAnalyticsLocation = platformLocation

param applicationInsightsName = 'appi-platform-dev'
param applicationInsightsLocation = platformLocation

param sqlServerName = 'sb-adt-platform-dev'
param sqlAdministratorLogin = 'sqladmin'
param sqlAdministratorPassword = readEnvironmentVariable('SQL_ADMINISTRATOR_PASSWORD')
param sqlDatabaseName = 'ReferenceProjectsDb'
param sqlDatabaseSkuName = 'Basic'
param sqlDatabaseSkuTier = 'Basic'
param sqlDatabaseMaxSizeBytes = 2147483648
param sqlLocation = platformLocation

param cosmosAccountName = 'cosmos-adt-platform-dev'
param cosmosDatabaseName = 'ReferenceProjects'
param cosmosConsistencyLevel = 'Session'
param cosmosEnableFreeTier = true
param cosmosDatabaseThroughput = 400
param cosmosLocation = platformLocation

// Service Bus
param serviceBusNamespaceName = 'sb-adt-platform-dev'
param serviceBusSkuName = 'Standard'

param tags = {
  environment: 'dev'
  managedBy: 'bicep'
  platform: 'azure-reference-platform'
  purpose: 'reference-project'
}
