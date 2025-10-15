targetScope = 'subscription'

param WAFRGName string
param location string
param tags object

resource WAFRG 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  name: WAFRGName
  location: location
  tags: tags
}

param afdWAFname string
param managedRules object
param customRules array

module frontDoorWebApplicationFirewallPolicy 'br/public:avm/res/network/front-door-web-application-firewall-policy:0.3.3'  = {
  name: 'Deploy_AFD_WAF_Policy'
  scope: WAFRG
  params: {
    name: afdWAFname
    sku: 'Premium_AzureFrontDoor'
    customRules: {
      rules: customRules
    }
    managedRules: managedRules
  }
}


