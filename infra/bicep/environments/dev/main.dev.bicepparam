using '../../main.bicep'

param location = 'australiaeast'
param environment = 'dev'
param platformResourceGroupName = 'rg-platform-dev'

param tags = {
  environment: 'dev'
  managedBy: 'bicep'
  platform: 'azure-reference-platform'
  purpose: 'reference-project'
}
