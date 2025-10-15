targetScope = 'subscription'

param PLSRGName string
param location string
param tags object

resource PLSRG 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  name: PLSRGName
  location: location
  tags: tags
}

param PLSname string
param PLSipConfig array
param PLSlbFrontEndIpConfig array

module privateLinkService 'br/public:avm/res/network/private-link-service:0.3.1' = {
  name: 'privateLinkServiceDeployment'
  scope: PLSRG
  params: {
    // Required parameters
    ipConfigurations: PLSipConfig
    loadBalancerFrontendIpConfigurations: PLSlbFrontEndIpConfig
    name: PLSname
  }
}
