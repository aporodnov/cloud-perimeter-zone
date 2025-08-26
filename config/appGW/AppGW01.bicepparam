using '../../modules/applicationGateway.bicep'

param RGName = 'AppGW01-rg'
param location = 'canadacentral'
param PubIPName = 'appgw01-pip'
param AppGWName = 'appgw01'
param WAFPolicyResourceId = '/subscriptions/f638c48a-5d9a-44cc-ae87-de50507a6090/resourceGroups/AppGW01-rg/providers/Microsoft.Network/ApplicationGatewayWebApplicationFirewallPolicies/waf-policy01'

var varAppGWName = AppGWName
var varSubscriptionID = 'f638c48a-5d9a-44cc-ae87-de50507a6090'
var varRGName = RGName
var varPubIPName = PubIPName
var varAppGWExpectedResourceID = '/subscriptions/${varSubscriptionID}/resourceGroups/${varRGName}/providers/Microsoft.Network/applicationGateways/${varAppGWName}'

param gatewayIPConfigurations = [
  {
    name: 'appgw01-gwip'
    properties: {
      subnet: {
        id: '/subscriptions/f638c48a-5d9a-44cc-ae87-de50507a6090/resourceGroups/perimeter-network-rg/providers/Microsoft.Network/virtualNetworks/perimeter-zone-vnet/subnets/appGateways-snet'
      }
    }
  }
]

param frontendIPConfigurations = [
  {
    name: 'public'
    properties: {
      publicIPAddress: {
        id: '/subscriptions/${varSubscriptionID}/resourceGroups/${varRGName}/providers/Microsoft.Network/publicIPAddresses/${varPubIPName}'
      }
    }
  }
  {
    name: 'private'
    properties: {
      privateIPAddress: '192.168.100.15'
      privateIPAllocationMethod: 'Static'
      subnet: {
        id: '/subscriptions/f638c48a-5d9a-44cc-ae87-de50507a6090/resourceGroups/perimeter-network-rg/providers/Microsoft.Network/virtualNetworks/perimeter-zone-vnet/subnets/appGateways-snet'
      }
    }
  }
]

param frontendPorts = [
  {
    name: 'appgw01-feport80'
    properties: {
      port: 80
    }
  }
]

param backendAddressPools = [
  {
    name: 'appgw01-bepool'
    properties: {
      backendAddresses: [
        {
          ipAddress: '10.0.0.4'
        }
      ]
    }
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
    properties: {
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
  }
  {
    name: 'appgw01-rule-private'
    properties: {
      ruleType: 'Basic'
      priority: 300
      backendAddressPool: {
        id: '${varAppGWExpectedResourceID}/backendAddressPools/appgw01-bepool'
      }
      backendHttpSettings: {
        id: '${varAppGWExpectedResourceID}/backendHttpSettingsCollection/appgw01-behttpsetting'
      }
      httpListener: {
        id: '${varAppGWExpectedResourceID}/httpListeners/appgw01-listener-private'
      }
    }
  }
]

param httpListeners = [
  {
    name: 'appgw01-listener'
    properties: {
      frontendIPConfiguration: {
        id: '${varAppGWExpectedResourceID}/frontendIPConfigurations/public'
      }
      frontendPort: {
        id: '${varAppGWExpectedResourceID}/frontendPorts/appgw01-feport80'
      } 
      protocol: 'Http'
      hostNames: []
    }
  }
  {
    name: 'appgw01-listener-private'
    properties: {
      frontendIPConfiguration: {
        id: '${varAppGWExpectedResourceID}/frontendIPConfigurations/private'
      }
      frontendPort: {
        id: '${varAppGWExpectedResourceID}/frontendPorts/appgw01-feport80'
      } 
      protocol: 'Http'
      hostNames: []
    }
  }
]
