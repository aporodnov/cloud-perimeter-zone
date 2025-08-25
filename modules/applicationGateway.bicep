targetScope = 'subscription'

param RGName string
param location string

resource RG 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  name: RGName
  location: location
}

param PubIPName string

module PublicIP 'publicIPaddress.bicep' = {
  scope: RG
  params: {
    location: location 
    PubIPName: PubIPName
  }
}

param AppGWName string
param WAFPolicyResourceId string
param gatewayIPConfigurations array
param frontendPorts array
param backendAddressPools array
param backendHttpSettingsCollection array
param requestRoutingRules array
param httpListeners array

module AppGW 'br/public:avm/res/network/application-gateway:0.7.1' = {
  scope: RG
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
    frontendIPConfigurations: [
      {
        name: 'Public'
        properties: {
          publicIPAddress: {
            id: PublicIP.outputs.publicIpId
          }
        }
      }
    ]
    frontendPorts: frontendPorts
    backendAddressPools: backendAddressPools
    backendHttpSettingsCollection: backendHttpSettingsCollection
    requestRoutingRules: requestRoutingRules
    httpListeners: httpListeners
  }
}
