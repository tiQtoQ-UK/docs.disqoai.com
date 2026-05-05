param location string

@allowed(['PROD', 'STAGING', 'DEV'])
@description('Name of the Environment to add in the managed identity name.')
param environment string

var environmentLower = toLower(environment)
var logAnalyticsName = 'disqo-ai-docs-logs-${environmentLower}'

// Log Analytics Workspace
resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: logAnalyticsName
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30
  }
}
