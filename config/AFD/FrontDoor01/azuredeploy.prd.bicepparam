using '../../../templates/afd/afdProfile.bicep'

param ResourceGroupName = 'AFD-RG'

//This is a location for Resource Group only, since FrontDoor instance is a global resource
param location = 'canadacentral'

//The tags will be applied to resource group and inherited by the resources within the resource group.
param tags = {
  SoluitonName: 'SolutionName'
}

param frontDoorName = 'CDN-Org-01'

// CDN supports two tiers: Standard_AzureFrontDoor, Premium_AzureFrontDoor
// Use Premium if you need to hide backend sources behind private IP addresses or leverage WAF policies
param AFDTier = 'Premium_AzureFrontDoor'

param afdEndpoints = [
  {
    name: 'afd-endpoint-app1'
    routes: [
      {
        enabledState: 'Enabled'
        name: 'afd-endpoint-app1-route'
        originGroupName: 'afd-app1-origingroup'
        customDomainNames: [
          'afd-app1-waftoday'
          'afd-app1-www-waftoday'
        ]
        ruleSets: [
          'afdApp1Ruleset'
        ]
      }
    ]
  }
  {
    name: 'afd-endpoint-app2'
    routes: [
      {
        enabledState: 'Enabled'
        name: 'afd-endpoint-app2-route'
        originGroupName: 'afd-app2-origingroup'
        customDomainNames: [
          'afd-app2-lb-waftoday'
        ]
        httpsRedirect: 'Enabled'
        forwardingProtocol: 'HttpOnly'
        supportedProtocols: [
          'Http'
          'Https'
        ]
        patternsToMatch: [
          '/*'
        ]
        cacheConfiguration: {
          compressionSettings: {
            contentTypesToCompress: [
              'application/json'
              'application/xml'
              'text/xml'
            ]
            isCompressionEnabled: true
          }
          queryParameters: 'timestamp,nonce'
          queryStringCachingBehavior: 'IgnoreSpecifiedQueryStrings'
        }
        ruleSets: []
      }
    ]
  }
]

param customDomains = [
  {
    certificateType: 'ManagedCertificate'
    hostName: 'waf.today'
    name: 'afd-app1-waftoday'
  }
  {
    certificateType: 'ManagedCertificate'
    hostName: 'www.waf.today'
    name: 'afd-app1-www-waftoday'
  }
  {
    certificateType: 'ManagedCertificate'
    hostName: 'lb.waf.today'
    name: 'afd-app2-lb-waftoday'
  }
]

param originGroups = [
  {
    name: 'afd-app1-origingroup'
    origins: [
      {
        name: 'afd-app1-origin01'
        hostName: 'ddwebapp01-hadvawckf0eafgf5.canadacentral-01.azurewebsites.net'
      }
      {
        name: 'afd-app1-origin02'
        hostName: 'ddwebapp02-a3egeyhuegb6b9d5.canadacentral-01.azurewebsites.net'
      }
    ]
    loadBalancingSettings: {
      additionalLatencyInMilliseconds: 50
      sampleSize: 4
      successfulSamplesRequired: 3
    }
  }
  {
    name: 'afd-app2-origingroup'
    origins: [
      {
        enabledState: 'Enabled'
        name: 'afd-lb-origin'
        hostName: 'lb.waf.today'
        httpPort: 80
        httpsPort: 443
        priority: 1
        weight: 100
        enforceCertificateNameCheck: true
        sharedPrivateLinkResource: {
          privateLinkLocation: 'canadacentral'
          requestMessage: 'AFD-PrivateLB01-PLS'
          privateLink: {
            id: '/subscriptions/ccf12f80-8b9f-4db9-a5d2-0e8e6b7785a9/resourceGroups/PRivateLB-PLS-RG/providers/Microsoft.Network/privateLinkServices/PrivateLB01-PLS'
          }
        }
      }
    ]
    healthProbeSettings: {
      probeIntervalInSeconds: 100
      probePath: '/'
      probeProtocol: 'Http'
      probeRequestType: 'HEAD'
    }
    loadBalancingSettings: {
      additionalLatencyInMilliseconds: 50
      sampleSize: 4
      successfulSamplesRequired: 3
    }
  }
]

param originResponseTimeoutSeconds = 60

param ruleSets = [
  {
    name: 'afdApp1Ruleset'
    rules: [
      {
        name: 'afdApp1Rule1'
        order: 1
        actions: [
          {
            name: 'UrlRedirect'
            parameters: {
              typeName: 'DeliveryRuleUrlRedirectActionParameters'
              redirectType: 'Moved' // 301 Permanent Redirect
              destinationProtocol: 'MatchRequest'
              customHost: 'www.waf.today'
              preserveUnmatchedPath: true
              preserveQueryString: true
            }
          }
        ]
        conditions: [
            {
            name: 'RequestHeader'
            parameters: {
              typeName: 'DeliveryRuleRequestHeaderConditionParameters'
              selector: 'Host'
              operator: 'Equal'
              matchValues: [
                'waf.today'
              ]
              negateCondition: false
              transforms: []
            }
          }
        ]
      }
    ]
  }
]

param securityPolicies = [
  {
    name: 'PolicyForWebServers'
    wafPolicyResourceId: '/subscriptions/f638c48a-5d9a-44cc-ae87-de50507a6090/resourcegroups/AFD-RG/providers/Microsoft.Network/frontdoorwebapplicationfirewallpolicies/AFDProfile01WAFPolicy'
    associations: [
      {
        domains: [
          {
            id: '/subscriptions/f638c48a-5d9a-44cc-ae87-de50507a6090/resourceGroups/CDN-RG/providers/Microsoft.Cdn/profiles/CDN-Org-01/afdEndpoints/afd-endpoint-app2'
          }
        ]
        patternsToMatch: [
          '/*'
        ]
      }
    ]
  }
]



