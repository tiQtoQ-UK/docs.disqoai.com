var environment = 'STAGING'
var location = resourceGroup().location

module managedIdentity '../../modules/managed-identity.bicep' = {
  name: 'Managed-Identity'
  params: {
    environment: environment
    location: location
  }
}

module logging '../../modules/logging.bicep' = {
  name: 'Logging'
  params: {
    environment: environment
    location: location
  }
}

module containerEnvironment '../../modules/container-environment.bicep' = {
  name: 'Container-Environment'
  params: {
    environment: environment
    location: location
    acrResourceGroup: 'disqo.ai-DEV'
    managedIdentityResourceId: managedIdentity.outputs.managedIdentityResourceId
    imageTag: 'latest'
  }
}
