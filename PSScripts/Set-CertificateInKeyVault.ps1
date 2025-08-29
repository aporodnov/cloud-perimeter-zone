<#
.SYNOPSIS
Fetch an existing Key Vault certificate's secret reference and assign it to an Application Gateway.

.PARAMETER KeyVaultName
Mandatory. The name of the Key Vault.

.PARAMETER CertName
Mandatory. The name of the certificate in Key Vault.

.PARAMETER AppGwName
Mandatory. The name of the Application Gateway.

.PARAMETER ResourceGroupName
Mandatory. The resource group of the Application Gateway.

.PARAMETER ManagedIdentityResourceId
Mandatory. The resource ID of the user-assigned managed identity.

.EXAMPLE
./Set-CertificateInKeyVault.ps1 -KeyVaultName 'myVault' -CertName 'myCert' -AppGwName 'myAppGw' -ResourceGroupName 'myRG' -ManagedIdentityResourceId '/subscriptions/xxxx/resourceGroups/xxxx/providers/Microsoft.ManagedIdentity/userAssignedIdentities/xxxx'
#>
param(
    [Parameter(Mandatory = $true)]
    [string] $KeyVaultName,

    [Parameter(Mandatory = $true)]
    [string] $CertName,

    [Parameter(Mandatory = $true)]
    [string] $AppGwName,

    [Parameter(Mandatory = $true)]
    [string] $ResourceGroupName,

    [Parameter(Mandatory = $true)]
    [string] $ManagedIdentityResourceId
)

# Get the Application Gateway
$appgw = Get-AzApplicationGateway -Name $AppGwName -ResourceGroupName $ResourceGroupName

# Set the user-assigned managed identity
Set-AzApplicationGatewayIdentity -ApplicationGateway $appgw -UserAssignedIdentityId $ManagedIdentityResourceId

# Get the secret ID from Key Vault (remove version for future syncs)
$secret = Get-AzKeyVaultSecret -VaultName $KeyVaultName -Name $CertName
$secretId = $secret.Id.Replace($secret.Version, "")

# Add the SSL certificate to the Application Gateway
Add-AzApplicationGatewaySslCertificate -KeyVaultSecretId $secretId -ApplicationGateway $appgw -Name $CertName

# Commit the changes to the Application Gateway
Set-AzApplicationGateway -ApplicationGateway $appgw