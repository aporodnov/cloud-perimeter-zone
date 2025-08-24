targetScope = 'subscription'

param vHUBName string
param vHUBConnName string
param remoteVirtualNetworkId string
param VWAN_RG_Name string

resource vWANRG 'Microsoft.Resources/resourceGroups@2025-04-01' existing = {
  name: VWAN_RG_Name
}

module vHUBConn 'HUBConnection.bicep' = {
  scope: vWANRG
  params: {
    remoteVirtualNetworkId: remoteVirtualNetworkId
    vHUBConnName: vHUBConnName
    vHUBName: vHUBName
  }
}
