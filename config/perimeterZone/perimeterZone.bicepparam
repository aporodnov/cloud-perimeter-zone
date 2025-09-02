using '../../modules/perimeterZone.bicep'

param resourceGroupNetworkName = 'perimeter-network-rg'
param locationRegion = 'canadacentral'
param tags = {
	environment: 'dev'
	owner: 'example-owner'
}
param perimeterZoneVNETName = 'perimeter-zone-vnet'
param vNetAddressPrefixes = [
	'192.168.100.0/24'
]
param dnsServers = [
	// '192.168.0.55'
]
param subnets = [
	{
		name: 'appGateways-snet'
		addressPrefix: '192.168.100.0/25'
		privateEndpointNetworkPolicies: 'Enabled'
	}
	{
		name: 'frontDoor-snet'
		addressPrefix: '192.168.100.128/26'
		privateEndpointNetworkPolicies: 'Enabled'
	}
  {
		name: 'privateEndpoints-snet'
		addressPrefix: '192.168.100.192/27'
		privateEndpointNetworkPolicies: 'Enabled'
	}
  {
		name: 'nva-snet'
		addressPrefix: '192.168.100.224/28'
	}
	{
		name: 'containers-snet'
		addressPrefix: '192.168.100.240/29'
		delegation: 'Microsoft.ContainerInstance/containerGroups'

	}
	{
		name: 'test-snet'
		addressPrefix: '192.168.100.248/29'
	}
]

