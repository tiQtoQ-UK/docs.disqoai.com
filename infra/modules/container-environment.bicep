param location string

@allowed(['PROD', 'STAGING', 'DEV'])
@description('Name of the Environment to add in the managed identity name.')
param environment string

@description('ACR login server (e.g., a11ycontainers.azurecr.io).')
param acrRegistryName string = 'a11ycontainers'

@description('Resource group where ACR is located.')
param acrResourceGroup string

@description('Tag for the broker container image.')
param imageTag string = 'latest'

@description('Managed identity resource ID to attach to container apps for ACR auth.')
param managedIdentityResourceId string

var environmentLower = toLower(environment)

var containerAppEnvName = 'disqo-ai-docs-${environmentLower}'
var logAnalyticsName = 'disqo-ai-docs-logs-${environmentLower}'

var acrLoginServer = '${acrRegistryName}.azurecr.io'

var acrRegistryPassword = listCredentials(resourceId(subscription().subscriptionId, acrResourceGroup, 'Microsoft.ContainerRegistry/registries', acrRegistryName), '2023-01-01-preview').passwords[0].value

var clientCertificateMode = 'ignore'

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2022-10-01' existing = {
  name: logAnalyticsName
}

// Container Apps Environment
resource containerAppEnv 'Microsoft.App/managedEnvironments@2023-05-01' = {
  name: containerAppEnvName
  location: location
  properties: {
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: logAnalytics.properties.customerId
        sharedKey: logAnalytics.listKeys().primarySharedKey
      }
    }
    zoneRedundant: false
  }
}

resource docsContainerApp 'Microsoft.App/containerApps@2023-05-01' = {
  name: 'disqo-ai-docs-${environmentLower}'
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${managedIdentityResourceId}': {}
    }
  }
  properties: {
    managedEnvironmentId: containerAppEnv.id
    configuration: {
      ingress: {
        external: true
        targetPort: 3000
        transport: 'http'
        allowInsecure: true
        clientCertificateMode: clientCertificateMode
      }
      secrets: [
        {
          name: 'registry-password'
          value: acrRegistryPassword
        }
      ]
      registries: [
        {
          server: acrLoginServer
          username: acrRegistryName
          passwordSecretRef: 'registry-password'
        }
      ]
    }
    template: {
      containers: [
        {
          name: 'disqo-ai-docs'
          image: '${acrLoginServer}/disqo-ai-docs:${imageTag}'
          resources: {
            cpu: json('1.0')
            memory: '2Gi'
          }
          env: [
          ]
        }
      ]
      scale: {
        minReplicas: 0
        maxReplicas: 1
      }
    }
  }
}
