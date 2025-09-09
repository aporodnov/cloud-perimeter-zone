targetScope = 'subscription'

param keyVaultName string
param location string

param managedIdentityName string

param resourceGroupName string

param tags object

resource resourceGroup 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  name: resourceGroupName
  location: location
  tags: tags
}

module managedIdentity 'managedIdentity.bicep' = {
  name: 'DeployMI'
  scope: resourceGroup
  params: {
    location: location
    managedIdentityName: managedIdentityName
  }
}

param PrivateEndpointsubnetResourceId string

module keyVault 'br/public:avm/res/key-vault/vault:0.13.3' = {
  name: 'deploy_KeyVault'
  scope: resourceGroup
  params: {
    name: keyVaultName
    location: location
    sku: 'standard'
    enableRbacAuthorization: true
    enableVaultForDeployment: true
    enableVaultForTemplateDeployment: true
    publicNetworkAccess: 'Disabled'
    privateEndpoints: [
      { 
        service: 'vault'
        subnetResourceId: PrivateEndpointsubnetResourceId
      }
    ]
    roleAssignments: [
      {
        name:guid('msi-${managedIdentityName}-${keyVaultName}-KeyVaultAdmin-RoleAssignment')
        principalId: managedIdentity.outputs.managedIdentityPrincipalId
        roleDefinitionIdOrName: '00482a5a-887f-4fb3-b363-3b7fe8e74483'
        principalType: 'ServicePrincipal'
      }
    ]
  }
}
