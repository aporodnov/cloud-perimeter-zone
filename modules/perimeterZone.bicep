targetScope = 'subscription'

param resourceGroupNetworkName string
param locationRegion string
param tags object

resource subscriptionTags 'Microsoft.Resources/tags@2025-04-01' = {
  name: 'default'
  scope: subscription()
  properties: {
    tags: tags
  }
}

resource resourceGroupNetwork 'Microsoft.Resources/resourceGroups@2025-04-01' = {
    name: resourceGroupNetworkName
    location: locationRegion
    tags: tags
}

param perimeterZoneVNETName string
param vNetAddressPrefixes array
param dnsServers array
param subnets array

module perimeterZoneVNET 'br/public:avm/res/network/virtual-network:0.7.0' = {
  name: 'create_Perimeter_VNET'
  scope: resourceGroupNetwork
  params: {
    name: perimeterZoneVNETName
    location: locationRegion
    addressPrefixes: vNetAddressPrefixes
    dnsServers: dnsServers
    subnets: subnets
  }
}
