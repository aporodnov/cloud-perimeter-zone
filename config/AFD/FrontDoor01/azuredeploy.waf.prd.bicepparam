using '../../../templates/afd/afdWAFpolicy.bicep'

param WAFRGName = 'AFD-RG'
param location = 'canadacentral'

param tags = {
  SoluitonName: 'SolutionName'
}

//Name must begin with a letter and contain only letters and numbers.
param afdWAFname = 'AFDProfile01WAFPolicy'

param managedRules = {
    managedRuleSets: [
      {
        exclusions: []
        ruleGroupOverrides: []
        ruleSetAction: 'Block'
        ruleSetType: 'Microsoft_DefaultRuleSet'
        ruleSetVersion: '2.1'
      }
      {
        exclusions: []
        ruleGroupOverrides: []
        ruleSetType: 'Microsoft_BotManagerRuleSet'
        ruleSetVersion: '1.0'
      }
    ]
}
param customRules = [
  {
      action: 'Allow'
      enabledState: 'Enabled'
      matchConditions: [
        {
          matchValue: [
            'CA'
          ]
          matchVariable: 'RemoteAddr'
          negateCondition: false
          operator: 'GeoMatch'
          transforms: []
        }
      ]
      name: 'AllowCanadaOnly'
      priority: 1
      ruleType: 'MatchRule'
  }
]
