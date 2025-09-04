param keyVaultName string
param location string

param managedIdentityName string

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2024-11-30' = {
  name: managedIdentityName
  location: location
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
        principalId: managedIdentity.properties.principalId
        roleDefinitionIdOrName: '00482a5a-887f-4fb3-b363-3b7fe8e74483'
        principalType: 'ServicePrincipal'
      }
    ]
  }
}

// param storageAccountName string = 'scripts-stg-${uniqueString(location)}'

// module FileStorage 'br/public:avm/res/storage/storage-account:0.26.2' = {
//   name: 'Deploy_StorageAccountForDeploymentScripts'
//   params: {
//     name: storageAccountName
//     kind: 'StorageV2'
//     location: location
//     skuName: 'Standard_LRS'
//     publicNetworkAccess: 'Disabled'
//     networkAcls: {
//       defaultAction: 'Deny'
//       bypass: 'AzureServices, Logging, Metrics'
//     }
//     privateEndpoints: [
//       {
//         service: 'file'
//         subnetResourceId: PrivateEndpointsubnetResourceId
//       }
//     ]
//     roleAssignments: [
//         {
//         name:guid('msi-${managedIdentityName}-${storageAccountName}-StorageFileDataPrivilegedContributor')
//         principalId: managedIdentity.properties.principalId
//         roleDefinitionIdOrName: '69566ab7-960f-475b-8e7c-b3118f30c6bd'
//         principalType: 'ServicePrincipal'
//       }
//     ]
//   }
// }

@description('The name of the created Key Vault.')
output keyVaultName string = keyVault.name

// @description('The name of the created Storage Account Name.')
// output storageAccountName string = FileStorage.name

@description('The resource ID of the created Managed Identity.')
output managedIdentityResourceId string = managedIdentity.id

@description('The principal ID of the created Managed Identity.')
output managedIdentityPrincipalId string = managedIdentity.properties.principalId
