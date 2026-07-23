targetScope = 'subscription'

@description('Monthly budget amount in USD')
param budgetAmount int = 100

@description('Action group resource ID to notify on threshold breach')
param actionGroupId string

@description('Start date for the budget, first of current month, format YYYY-MM-01')
param startDate string

resource budget 'Microsoft.Consumption/budgets@2023-05-01' = {
  name: 'governance-finops-monthly-budget'
  properties: {
    category: 'Cost'
    amount: budgetAmount
    timeGrain: 'Monthly'
    timePeriod: {
      startDate: startDate
    }
    notifications: {
      Actual_50_Percent: {
        enabled: true
        operator: 'GreaterThanOrEqualTo'
        threshold: 50
        contactEmails: []
        contactGroups: [
          actionGroupId
        ]
        thresholdType: 'Actual'
      }
      Actual_80_Percent: {
        enabled: true
        operator: 'GreaterThanOrEqualTo'
        threshold: 80
        contactEmails: []
        contactGroups: [
          actionGroupId
        ]
        thresholdType: 'Actual'
      }
      Actual_100_Percent: {
        enabled: true
        operator: 'GreaterThanOrEqualTo'
        threshold: 100
        contactEmails: []
        contactGroups: [
          actionGroupId
        ]
        thresholdType: 'Actual'
      }
    }
  }
}

output budgetId string = budget.id
