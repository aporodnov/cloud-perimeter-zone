param PubIPName string
param location string

resource publicIPAddress 'Microsoft.Network/publicIPAddresses@2024-07-01' = {
  name: PubIPName
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
  }
  zones: [
    '1'
    '2'
    '3'
  ]
}

output publicIpId string = publicIPAddress.id
output publicIpName string = publicIPAddress.name
