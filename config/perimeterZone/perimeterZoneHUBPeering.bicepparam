using '../../templates/network/perimeterZoneHUBConn.bicep'

param VWAN_RG_Name = 'AVNM-RG'
param vHUBName = 'vHUBv2'
param vHUBConnName = 'PLZvNET-to-vHUBv2'
param remoteVirtualNetworkId = '/subscriptions/f638c48a-5d9a-44cc-ae87-de50507a6090/resourceGroups/perimeter-network-rg/providers/Microsoft.Network/virtualNetworks/perimeter-zone-vnet'
