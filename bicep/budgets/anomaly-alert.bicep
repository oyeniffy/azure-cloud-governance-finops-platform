targetScope = 'subscription'

@description('Email address to notify on detected cost anomalies')
param alertEmail string

resource anomalyAlert 'Microsoft.CostManagement/scheduledActions@2023-11-01' = {
  name: 'daily-anomaly-alert'
  kind: 'InsightAlert'
  properties: {
    displayName: 'Daily Cost Anomaly Alert'
    status: 'Enabled'
    viewId: '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.CostManagement/views/ms:DailyAnomalyByResourceGroup'
    notification: {
      to: [
        alertEmail
      ]
      subject: 'Azure Cost Anomaly Detected — Governance/FinOps Platform'
    }
    schedule: {
      frequency: 'Daily'
      startDate: '2026-07-23T00:00:00Z'
      endDate: '2027-07-23T00:00:00Z'
    }
  }
}

output anomalyAlertId string = anomalyAlert.id
