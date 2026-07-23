@description('Email address to receive alerts')
param alertEmail string

resource actionGroup 'Microsoft.Insights/actionGroups@2023-01-01' = {
  name: 'ag-governance-finops-alerts'
  location: 'global'
  tags: {
    CostCenter: 'CC-001'
    Environment: 'Dev'
    Owner: 'oyeniffy'
  }
  properties: {
    groupShortName: 'GovFinOps'
    enabled: true
    emailReceivers: [
      {
        name: 'PrimaryOwnerEmail'
        emailAddress: alertEmail
        useCommonAlertSchema: true
      }
    ]
  }
}

output actionGroupId string = actionGroup.id
