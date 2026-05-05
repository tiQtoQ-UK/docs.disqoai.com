@allowed(['PROD', 'STAGING', 'DEV'])
@description('Name of the Environment to add in the managed identity name.')
param environment string

@description('Location of the Resource Group where resources are deployed')
param location string

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: 'disqo-ai-docs-${environment}-identity'
  location: location
}

output managedIdentityId string = managedIdentity.properties.principalId
output managedIdentityClientId string = managedIdentity.properties.clientId
output managedIdentityName string = managedIdentity.name
output managedIdentityResourceId string = managedIdentity.id
