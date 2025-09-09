using '../../templates/key-vault/keyVault.bicep'

// Resource Group where Application Gateway, KeyVault, Managed Identity will be deployed. 
// Deployment stack will also manage RBAC assignments
param resourceGroupName = 'appgw01-rg'
param location = 'canadacentral'

param tags = {
  SoluitonName: 'SolutionName'
}

// Managed Identity to managed load balancer and a key vault assosiated with it.
param managedIdentityName = 'CertManagerSPN'

//KeyVault prefix name that will be used to generate the actual name
//Sample of the actual name: 'keyvaultf4dw'
//KeyVault has to be a unique name and can only contain lower case letters and numbers
var keyVaultPrefix = 'kvlt'

//do not modify this part
var keyVaultUniqueString = uniqueString(keyVaultPrefix)
@maxLength(23)
param keyVaultName = '${keyVaultPrefix}${substring(keyVaultUniqueString, 0, 6)}'

// Input subscription ID where stack will be deployed. This variable will be used to form some of the required resource IDs in this param file
var varSubscriptionID = 'f638c48a-5d9a-44cc-ae87-de50507a6090'

// ID of the subnet where private endpoint for a key vault will be configured
param PrivateEndpointsubnetResourceId = '/subscriptions/${varSubscriptionID}/resourceGroups/perimeter-network-rg/providers/Microsoft.Network/virtualNetworks/perimeter-zone-vnet/subnets/privateEndpoints-snet'

