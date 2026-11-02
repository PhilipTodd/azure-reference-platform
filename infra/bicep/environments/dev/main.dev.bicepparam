using '../../main.bicep'

param platformLocation = 'australiaeast'

// Shared gateway and image hosting.
param apiManagementName = 'apim-adt-platform-dev'
param apiManagementLocation = platformLocation
param apiManagementPublisherEmail = 'philip.todd@ausdatatech.com.au'
param apiManagementPublisherName = 'Aus Data Tech'
param containerRegistryName = 'acradtplatformdev'
param containerRegistryLocation = platformLocation

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

param sqlServerName = 'sql-adt-platform-dev'
param sqlAdministratorLogin = 'sqladmin'
param sqlAdministratorPassword = readEnvironmentVariable('SQL_ADMINISTRATOR_PASSWORD')
param sqlDatabaseName = 'ReferenceProjectsDb'
param sqlDatabaseSkuName = 'Basic'
param sqlDatabaseSkuTier = 'Basic'
param sqlDatabaseMaxSizeBytes = 2147483648
param sqlLocation = platformLocation

// Verified directory bootstrap group ID; no secret values.
param sqlEntraAdminGroupName = 'sg-adt-platform-sql-admins-dev'
param sqlEntraAdminGroupObjectId = '469d4226-c4a4-4cc1-8b99-58e1dfd595f7'

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
