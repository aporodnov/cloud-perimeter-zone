using '../../modules/applicationGateway.bicep'

param RGName = 'appgw01-rg'
param location = 'canadacentral'
param PubIPName = 'appgw01-pip'
param AppGWName = 'appgw01'
param managedIdentityName = 'CertManagerSPN'
param keyVaultName = 'kvlt231231'
param WAFPolicyResourceId = '/subscriptions/f638c48a-5d9a-44cc-ae87-de50507a6090/resourceGroups/AppGW01-rg/providers/Microsoft.Network/ApplicationGatewayWebApplicationFirewallPolicies/waf-policy01'
param PrivateEndpointsubnetResourceId = '/subscriptions/f638c48a-5d9a-44cc-ae87-de50507a6090/resourceGroups/perimeter-network-rg/providers/Microsoft.Network/virtualNetworks/perimeter-zone-vnet/subnets/privateEndpoints-snet'

@description('storageNamePrefix should contain lowercase letters and numbers only, limit it to 15 chars')
var storageNamePrefix = 'myorgstorage'
var storageAccUniqueString = uniqueString(storageNamePrefix)

@maxLength(23)
param storageAccountName = '${storageNamePrefix}${substring(storageAccUniqueString, 0, 6)}'

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
  {
    name: 'appgw01-feport443'
    properties: {
      port: 443
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
        {
          ipAddress: '10.0.0.12'
        }
      ]
    }
  }
]

param backendHttpSettingsCollection = [
  {
    name: 'appgw01-behttp-setting'
    properties: {
      port: 80
      protocol: 'Http'
      cookieBasedAffinity: 'Disabled'
    }
  }
  {
    name: 'appgw01-behttps-setting'
    properties: {
      port: 443
      cookieBasedAffinity: 'Disabled'
      protocol: 'Https'
      pickHostNameFromBackendAddress: false
      hostname: 'waf.today'
      requestTimeout: 30
      probe: {
        id: '${varAppGWExpectedResourceID}/probes/privateVMhttpSettingProbe'
      }
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
        id: '${varAppGWExpectedResourceID}/backendHttpSettingsCollection/appgw01-behttp-setting'
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
        id: '${varAppGWExpectedResourceID}/backendHttpSettingsCollection/appgw01-behttps-setting'
      }
      httpListener: {
        id: '${varAppGWExpectedResourceID}/httpListeners/appgw01-listener-private'
      }
    }
  }
  //Only use this if you already have SSL certificate configured for App Gateway!
  //SSL encryption example:
  {
    name: 'appgw01-443-rule'
    properties: {
      ruleType: 'Basic'
      priority: 400
      backendAddressPool: {
        id: '${varAppGWExpectedResourceID}/backendAddressPools/appgw01-bepool'
      }
      backendHttpSettings: {
        id: '${varAppGWExpectedResourceID}/backendHttpSettingsCollection/appgw01-behttps-setting'
      }
      httpListener: {
        id: '${varAppGWExpectedResourceID}/httpListeners/appgw01-listener443-public'
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
      hostNames: [
        'waf.today'
        'www.waf.today'
      ]
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
  //Only use this if you already have SSL certificate configured for App Gateway!
  //End to End SSL encryption example:
    {
    name: 'appgw01-listener443-public'
    properties: {
      frontendIPConfiguration: {
        id: '${varAppGWExpectedResourceID}/frontendIPConfigurations/public'
      }
      frontendPort: {
        id: '${varAppGWExpectedResourceID}/frontendPorts/appgw01-feport443'
      } 
      protocol: 'Https'
      hostNames: [
        'waf.today'
        'www.waf.today'
      ]
      sslCertificate: {
        id: '${varAppGWExpectedResourceID}/sslCertificates/wafToday'
      }
    }
  }
]

param probes = [
  {
    name: 'privateVMhttpSettingProbe'
    properties: {
      host: '10.0.0.4'
      interval: 60
      match: {
        statusCodes: [
          '200'
          '401'
        ]
      }
      path: '/'
      pickHostNameFromBackendHttpSettings: false
      protocol: 'Http'
      timeout: 15
      unhealthyThreshold: 5
      minServers: 1
    }
  }
]

param sslCertificates = [
  {
    name: 'wafToday'
    properties: {
      keyVaultSecretId: 'https://kvlt231231.vault.azure.net/secrets/wafToday/0e8132aacdf147a2a02b730ee05b3e6a' 
    }
  }
]

param redirectConfigurations = [
  {
    name: 'httpRedirect80'
    properties: {
      includePath: true
      includeQueryString: true
      redirectType: 'Permanent'
      requestRoutingRules: [
        {
          id: '${varAppGWExpectedResourceID}/requestRoutingRules/appgw01-rule'
        }
      ]
      targetListener: {
        id: '${varAppGWExpectedResourceID}/httpListeners/appgw01-listener443-public'
      }
    }
  }
]
