param certDeploymentScriptName string
param location string

param managedIdentityName string

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2024-11-30' existing = {
  name: managedIdentityName
}

param keyVaultName string

resource keyVault 'Microsoft.KeyVault/vaults@2024-11-01' existing = {
  name: keyVaultName
}

param CertName string
param AppGwName string
param ResourceGroupName string

resource certDeploymentScript 'Microsoft.Resources/deploymentScripts@2023-08-01' = {
  name: certDeploymentScriptName
  location: location
  kind: 'AzurePowerShell'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${managedIdentity.id}': {}
    }
  }
  properties: {
    azPowerShellVersion: '11.0'
    retentionInterval: 'P1D'
    arguments: '-KeyVaultName "${keyVault.name}" -CertName "${CertName}" -AppGwName "${AppGwName}" -ResourceGroupName "${ResourceGroupName}" -ManagedIdentityResourceId "${managedIdentity.id}"'
    scriptContent: loadTextContent('../PSScripts/Set-CertificateInKeyVault.ps1')
    // containerSettings: {
    //   subnetIds:
    // }
  }
}
