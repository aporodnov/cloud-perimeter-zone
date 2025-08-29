param keyVaultName string
param location string

param managedIdentityName string

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2024-11-30' = {
  name: managedIdentityName
  location: location
}

resource managedIdentityRBAC 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(managedIdentityName)
  properties: {
    principalId: managedIdentity.properties.principalId
    roleDefinitionId: 'f1a07417-d97a-45cb-824c-7a7467783830'
  }
}

param PrivateEndpointsubnetResourceId string

module keyVault 'br/public:avm/res/key-vault/vault:0.13.3' = {
  name: 'deploy_KeyVault'
  params: {
    name: keyVaultName
    location: location
    sku: 'standard'
    enableRbacAuthorization: true
    enableVaultForDeployment: true
    enableVaultForTemplateDeployment: true
    // publicNetworkAccess: 'Disabled'
    // privateEndpoints: [
    //   { 
    //     service: 'vault'
    //     subnetResourceId: PrivateEndpointsubnetResourceId
    //   }
    // ]
    roleAssignments: [
      {
        name:guid('msi-${managedIdentityName}-${keyVaultName}-KeyVaultAdmin-RoleAssignment')
        principalId: managedIdentity.properties.principalId
        roleDefinitionIdOrName: '00482a5a-887f-4fb3-b363-3b7fe8e74483'
        principalType: 'ServicePrincipal'
      }
    ]
  }
}

@description('The name of the created Key Vault.')
output keyVaultName string = keyVault.name

@description('The resource ID of the created Managed Identity.')
output managedIdentityResourceId string = managedIdentity.id

@description('The principal ID of the created Managed Identity.')
output managedIdentityPrincipalId string = managedIdentity.properties.principalId
