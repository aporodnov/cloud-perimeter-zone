targetScope = 'subscription'

param AppGW_WAF_RGName string
param location string

resource AppGW_WAF_RG 'Microsoft.Resources/resourceGroups@2025-04-01' = {
    name: AppGW_WAF_RGName
    location: location
}

param WAFName string
param managedRuleSets array
param customRules array
param policySettings object

module WAF 'br/public:avm/res/network/application-gateway-web-application-firewall-policy:0.2.0' = {
  scope: AppGW_WAF_RG
  params: {
    name: WAFName
    location: location
    managedRules: {
      managedRuleSets: managedRuleSets
    }
    policySettings: policySettings
    customRules: customRules
  }
}
