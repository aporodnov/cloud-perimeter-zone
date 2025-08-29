using '../../modules/TLSConfig.bicep'

param certDeploymentScriptName = 'set-appgw-cert-script'
param location = 'canadacentral'
param managedIdentityName = 'keyvaultAccess01'
param keyVaultName = 'kvlt231231'
param CertName = 'wafToday'
param AppGwName = 'appgw01'
param ResourceGroupName = 'AppGW01-rg'
