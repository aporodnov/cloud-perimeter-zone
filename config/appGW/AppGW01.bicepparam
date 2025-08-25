using '../../modules/applicationGateway.bicep'

param RGName = 'AppGW01-rg'
param location = 'canadacentral'
param PubIPName = 'appgw01-pip'
param AppGWName = 'appgw01'
param WAFPolicyResourceId = '/subscriptions/f638c48a-5d9a-44cc-ae87-de50507a6090/resourceGroups/AppGW01-rg/providers/Microsoft.Network/ApplicationGatewayWebApplicationFirewallPolicies/waf-policy01'

var varAppGWName = AppGWName
var varSubscriptionID = 'f638c48a-5d9a-44cc-ae87-de50507a6090'
var varRGName = RGName
var varAppGWExpectedResourceID = '/subscriptions/${varSubscriptionID}/resourceGroups/${varRGName}/providers/Microsoft.Network/applicationGateways/${varAppGWName}'

// Example: minimal configuration for required arrays
param gatewayIPConfigurations = [
  {
    name: 'appgw01-gwip'
    subnetResourceId: '/subscriptions/f638c48a-5d9a-44cc-ae87-de50507a6090/resourceGroups/perimeter-network-rg/providers/Microsoft.Network/virtualNetworks/perimeter-zone-vnet/subnets/appGateways-snet'
  }
]

param frontendPorts = [
  {
    name: 'appgw01-feport'
    port: 80
  }
]

param backendAddressPools = [
  {
    name: 'appgw01-bepool'
    // Example: backendAddresses can be omitted or filled as needed
    backendAddresses: []
  }
]

param backendHttpSettingsCollection = [
  {
    name: 'appgw01-behttpsetting'
    properties: {
      port: 80
      protocol: 'Http'
      cookieBasedAffinity: 'Disabled'
    }
  }
]

param requestRoutingRules = [
  {
    name: 'appgw01-rule'
    ruleType: 'Basic'
    priority: 200
    backendAddressPool: {
      id: '${varAppGWExpectedResourceID}/backendAddressPools/appgw01-bepool'
    }
    backendHttpSettings: {
      id: '${varAppGWExpectedResourceID}/backendHttpSettingsCollection/appgw01-behttpsetting'
    }
    httpListener: {
      id: '${varAppGWExpectedResourceID}/httpListeners/appgw01-listener'
    }
  }
]

param httpListeners = [
  {
    name: 'appgw01-listener'
    properties: {
      frontendIPConfiguration: {
        id: '${varAppGWExpectedResourceID}/frontendIPConfigurations/Public'
      }
      frontendPort: {
        id: '${varAppGWExpectedResourceID}/frontendPorts/appgw01-feport'
      } 
      protocol: 'Http'
      hostNames: []
    }
  }
]
