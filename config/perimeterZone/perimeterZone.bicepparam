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
	'8.8.8.8'
	'8.8.4.4'
]
param subnets = [
	{
		name: 'appGateways-snet'
		addressPrefix: '192.168.100.0/25'
	}
	{
		name: 'frontDoor-snet'
		addressPrefix: '192.168.100.128/26'
	}
  {
		name: 'privateEndpoints-snet'
		addressPrefix: '192.168.100.192/27'
	}
  {
		name: 'connectivityTest-snet'
		addressPrefix: '192.168.100.224/28'
	}
  // {
	// 	name: 'Reserved'
	// 	addressPrefix: '192.168.100.240/28'
	// }
]

