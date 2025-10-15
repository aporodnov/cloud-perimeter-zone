using '../../../templates/afd/privateLink.bicep'

param PLSRGName = 'AFD-RG'
param location = 'canadacentral'

param tags = {
  SoluitonName: 'SolutionName'
}

param PLSname = 'PrivateLB01-PLS'

param PLSipConfig = [
  {
    name: 'PrivateLB01-PE01'
    properties: {
      subnet: {
        id: '/subscriptions/ccf12f80-8b9f-4db9-a5d2-0e8e6b7785a9/resourceGroups/iPerf-RG/providers/Microsoft.Network/virtualNetworks/iperf-vnet/subnets/default'
      }
    }
  }
]

param PLSlbFrontEndIpConfig = [
  {
    id: '/subscriptions/ccf12f80-8b9f-4db9-a5d2-0e8e6b7785a9/resourceGroups/iPerf-RG/providers/Microsoft.Network/loadBalancers/PrivateLB/frontendIPConfigurations/PrivateLB-IP'
  }
]
