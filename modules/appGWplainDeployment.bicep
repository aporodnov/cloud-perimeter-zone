targetScope = 'subscription'

param RGName string

resource RG 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  name: RGName
  location: location
}

@description('Name of the Application Gateway')
param AppGWName string

@description('Location for the Application Gateway')
param location string

@description('Firewall Policy Resource ID')
param WAFPolicyResourceId string

@description('Gateway IP Configurations')
param gatewayIPConfigurations array

@description('Frontend IP Configurations')
param frontendIPConfigurations array

@description('Frontend Ports')
param frontendPorts array

@description('Backend Address Pools')
param backendAddressPools array

@description('Backend HTTP Settings Collection')
param backendHttpSettingsCollection array

@description('Request Routing Rules')
param requestRoutingRules array

@description('HTTP Listeners')
param httpListeners array

param PubIPName string

module PubIP 'publicIPaddress.bicep' = {
  scope: RG
  params: {
    location: location 
    PubIPName: PubIPName
  }
}

module AppGW 'appGWplain.bicep' = {
  name: 'deployAppGW'
  scope: RG
  params: {
    location: location
    AppGWName: AppGWName
    WAFPolicyResourceId: WAFPolicyResourceId
    backendAddressPools: backendAddressPools
    backendHttpSettingsCollection: backendHttpSettingsCollection
    frontendIPConfigurations: frontendIPConfigurations
    frontendPorts: frontendPorts
    gatewayIPConfigurations: gatewayIPConfigurations
    httpListeners: httpListeners
    requestRoutingRules: requestRoutingRules
  }
}
