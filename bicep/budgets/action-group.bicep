targetScope = 'subscription'

@description('Resource group to deploy the action group into')
param resourceGroupName string = 'rg-governance-finops'

@description('Location for the resource group')
param location string = 'uksouth'

@description('Email address to receive budget and anomaly alerts')
param alertEmail string

resource rg 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: resourceGroupName
  location: location
  tags: {
    CostCenter: 'CC-001'
    Environment: 'Dev'
    Owner: 'oyeniffy'
  }
}

module actionGroupModule 'action-group-resource.bicep' = {
  name: 'deployActionGroup'
  scope: rg
  params: {
    alertEmail: alertEmail
  }
}

output resourceGroupId string = rg.id
