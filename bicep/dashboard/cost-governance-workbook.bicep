targetScope = 'resourceGroup'

@description('Location for the workbook resource')
param location string = resourceGroup().location

@description('Unique identifier for the workbook')
param workbookId string = guid(resourceGroup().id, 'cost-governance-workbook')

var tags = {
  CostCenter: 'CC-001'
  Environment: 'Dev'
  Owner: 'oyeniffy'
}

var workbookContent = {
  version: 'Notebook/1.0'
  items: [
    {
      type: 1
      content: {
        json: '# Governance & FinOps Dashboard\n\nCost and compliance data for the governed subscription.'
      }
    }
    {
      type: 3
      content: {
        version: 'KqlItem/1.0'
        query: 'PolicyResources | where type == \'microsoft.policyinsights/policystates\' | summarize count() by tostring(properties.complianceState)'
        queryType: 1
        resourceType: 'microsoft.resourcegraph/resources'
        visualization: 'piechart'
      }
    }
    {
      type: 3
      content: {
        version: 'KqlItem/1.0'
        query: 'Resources | where type == \'microsoft.insights/actiongroups\' | project name, enabled = properties.enabled, notificationEmail = properties.emailReceivers[0].emailAddress, tags'
        queryType: 1
        resourceType: 'microsoft.resourcegraph/resources'
        visualization: 'table'
      }
    }
  ]
}

resource costGovernanceWorkbook 'Microsoft.Insights/workbooks@2022-04-01' = {
  name: workbookId
  location: location
  tags: tags
  kind: 'shared'
  properties: {
    displayName: 'Governance & FinOps Dashboard'
    serializedData: string(workbookContent)
    category: 'workbook'
    sourceId: resourceGroup().id
  }
}

output workbookId string = costGovernanceWorkbook.id
