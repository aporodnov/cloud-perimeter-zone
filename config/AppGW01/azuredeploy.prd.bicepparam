using '../../templates/application-gateway/applicationGateway.bicep'

// Resource Group where Application Gateway, KeyVault, Managed Identity will be deployed. 
// Deployment stack will also manage RBAC assignments
param resourceGroupName = 'appgw01-rg'
param location = 'canadacentral'

param tags = {
  SoluitonName: 'SolutionName'
}

// Application Gateway Name.
param AppGWName = 'appgw01'

// Public IP for Front End load balancer configuration.
param PubIPName = 'appgw01-pip'

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

// ID of the subnet where private endpoint for a key vault will be configured
param PrivateEndpointsubnetResourceId = '/subscriptions/${varSubscriptionID}/resourceGroups/perimeter-network-rg/providers/Microsoft.Network/virtualNetworks/perimeter-zone-vnet/subnets/privateEndpoints-snet'

// THe main WAF Policy to be assosiated with an Application Gateway instance
var varWAFPolicyName = 'waf-policy01'

// This is a param for waf policy resource id, if it is in the same resource group as an app gateway, ignore this parameter.
param WAFPolicyResourceId = '/subscriptions/${varSubscriptionID}/resourceGroups/${varRGName}/providers/Microsoft.Network/ApplicationGatewayWebApplicationFirewallPolicies/${varWAFPolicyName}'

// Input subscription ID where stack will be deployed. This variable will be used to form some of the required resource IDs in this param file
var varSubscriptionID = 'f638c48a-5d9a-44cc-ae87-de50507a6090'

// do not modify those variables
var varAppGWName = AppGWName
var varRGName = resourceGroupName
var varPubIPName = PubIPName
var varAppGWExpectedResourceID = '/subscriptions/${varSubscriptionID}/resourceGroups/${varRGName}/providers/Microsoft.Network/applicationGateways/${varAppGWName}'

// main agw ip config and subnet where it will be deployed. Input both values
param gatewayIPConfigurations = [
  {
    name: 'appgw01-gwip'
    properties: {
      subnet: {
        id: '/subscriptions/${varSubscriptionID}/resourceGroups/perimeter-network-rg/providers/Microsoft.Network/virtualNetworks/perimeter-zone-vnet/subnets/appGateways-snet'
      }
    }
  }
]

// agw can have combination of two or one frontend ip configs.
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
        id: '${varAppGWExpectedResourceID}/probes/httpsSettingProbe'
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
      httpListener: {
        id: '${varAppGWExpectedResourceID}/httpListeners/appgw01-listener'
      }
      redirectConfiguration: {
        id: '${varAppGWExpectedResourceID}/redirectConfigurations/httpRedirect80'
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
        id: '${varAppGWExpectedResourceID}/backendHttpSettingsCollection/appgw01-behttp-setting'
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
  // End to End SSL encryption example:
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
    name: 'httpsSettingProbe'
    properties: {
      host: 'waf.today'
      interval: 60
      match: {
        statusCodes: [
          '200'
          '401'
        ]
      }
      path: '/'
      pickHostNameFromBackendHttpSettings: false
      protocol: 'Https'
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
      keyVaultSecretId: 'https://newkvlt231231.vault.azure.net/secrets/wafToday/c469dd9cd6744d518c108b147cddd224' 
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

param diagnosticSettings = []
