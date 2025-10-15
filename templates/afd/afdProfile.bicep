targetScope = 'subscription'

param ResourceGroupName string
param location string
param tags object

resource RG 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  name: ResourceGroupName
  location: location
  tags: tags
}

param frontDoorName string

@description('Available values are: Standard_AzureFrontDoor, Premium_AzureFrontDoor')
param AFDTier string

param afdEndpoints array
param customDomains array
param originGroups array
param originResponseTimeoutSeconds int
param ruleSets array
param securityPolicies array

module CDN 'br/public:avm/res/cdn/profile:0.16.0' = {
  name: 'Deploy-CDN-Profile'
  scope: RG
  params: {
    name: frontDoorName
    sku: AFDTier
    location: 'global'
    afdEndpoints: afdEndpoints
    customDomains: customDomains
    originGroups: originGroups
    originResponseTimeoutSeconds: originResponseTimeoutSeconds
    ruleSets: ruleSets
    securityPolicies: securityPolicies
  }
}
