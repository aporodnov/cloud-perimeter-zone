using '../../modules/RegionalWAFPolicy.bicep'

param AppGW_WAF_RGName = 'AppGW01-rg'
param location = 'canadacentral'
param WAFName = 'waf-policy01'
param managedRuleSets = [
  {
    ruleSetType: 'OWASP'
    ruleSetVersion: '3.2'
  }
]
param customRules = [
  // Example custom rule
  // {
  //   name: 'BlockBadBots'
  //   priority: 1
  //   ruleType: 'MatchRule'
  //   matchConditions: [
  //     {
  //       matchVariables: [
  //         {
  //           variableName: 'RequestHeaders'
  //           selector: 'User-Agent'
  //         }
  //       ]
  //       operator: 'Contains'
  //       matchValues: [
  //         'BadBot'
  //       ]
  //       negationConditon: false
  //     }
  //   ]
  //   action: 'Block'
  // }
]
param policySettings = {
  enabledState: 'Enabled'
  mode: 'Prevention'
}

