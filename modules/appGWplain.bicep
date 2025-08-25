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

resource appGateway 'Microsoft.Network/applicationGateways@2024-07-01' = {
  name: AppGWName
  location: location
  properties: {
    sku: {
      family: 'Generation_2'
      tier: 'WAF_v2'
      name: 'WAF_v2'
    }
    gatewayIPConfigurations: gatewayIPConfigurations
    frontendIPConfigurations: frontendIPConfigurations
    frontendPorts: frontendPorts
    backendAddressPools: backendAddressPools
    backendHttpSettingsCollection: backendHttpSettingsCollection
    httpListeners: httpListeners
    requestRoutingRules: requestRoutingRules
    enableHttp2: true
    firewallPolicy: {
      id: WAFPolicyResourceId
    }

  }
  zones: [
    '1'
    '2'
    '3'
  ]
}

output appGatewayId string = appGateway.id
output appGatewayName string = appGateway.name
