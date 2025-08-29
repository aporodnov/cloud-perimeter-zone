targetScope = 'subscription'

param RGName string
param location string

resource RG 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  name: RGName
  location: location
}

param PubIPName string

module PublicIP 'publicIPaddress.bicep' = {
  name: 'DeployPubIP'
  scope: RG
  params: {
    location: location 
    PubIPName: PubIPName
  }
}

param PrivateEndpointsubnetResourceId string

param keyVaultName string
param managedIdentityName string
module keyVault 'keyVault.bicep' = {
  scope: RG
  params: {
    location: location
    keyVaultName: keyVaultName
    managedIdentityName: managedIdentityName
    PrivateEndpointsubnetResourceId: PrivateEndpointsubnetResourceId
  }
}

param AppGWName string
param WAFPolicyResourceId string
param gatewayIPConfigurations array
param frontendIPConfigurations array
param frontendPorts array
param backendAddressPools array
param backendHttpSettingsCollection array
param requestRoutingRules array
param httpListeners array

module ManagedIdentityRBAC 'br/public:avm/res/authorization/role-assignment/sub-scope:0.1.0' = {
  name: 'NetContributorRBACForMI'
  params: {
    name: guid('Network-Contributor-${managedIdentityName}')
    principalId: keyVault.outputs.managedIdentityPrincipalId
    roleDefinitionIdOrName: '4d97b98b-1d4f-4787-a291-c67834d212e7'
    principalType: 'ServicePrincipal'
  }
}

module AppGW 'br/public:avm/res/network/application-gateway:0.7.1' = {
  name: 'DeployAppGW'
  scope: RG
  dependsOn: [
    keyVault
  ]
  params: {
    name: AppGWName
    location: location
    firewallPolicyResourceId: WAFPolicyResourceId
    sku: 'WAF_v2'
    autoscaleMinCapacity: 0
    autoscaleMaxCapacity: 10
    enableHttp2: true
    availabilityZones: [
      1
      2
      3
    ]
    gatewayIPConfigurations: gatewayIPConfigurations
    frontendIPConfigurations: frontendIPConfigurations
    frontendPorts: frontendPorts
    backendAddressPools: backendAddressPools
    backendHttpSettingsCollection: backendHttpSettingsCollection
    requestRoutingRules: requestRoutingRules
    httpListeners: httpListeners
    managedIdentities: {
      userAssignedResourceIds: [
        keyVault.outputs.managedIdentityResourceId
      ]
    }
    roleAssignments: [
      {
        name: guid('Contributor ${keyVault.outputs.managedIdentityResourceId}')
        principalId: keyVault.outputs.managedIdentityPrincipalId
        roleDefinitionIdOrName: 'b24988ac-6180-42a0-ab88-20f7382dd24c'
        principalType: 'ServicePrincipal'
      }
    ]
  }
}
