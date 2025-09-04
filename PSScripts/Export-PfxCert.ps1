
<#
Please note, while Private Key Path is not required, certutil is expecting it to be in the same direction 
as certificate and be named exactly the same as certificate

Before running this script, execute the following in your PowerShell session:

$securePwd = Read-Host "Enter password for PFX" -AsSecureString
$CertPath = "C:\Users\aporodnov\Downloads\waf.today.crt"
$PfxPath  = "C:\Users\aporodnov\Downloads\wafToday.pfx"
#>

param (
    [Parameter(Mandatory = $true)]
    [string]$CertPath,

    [Parameter(Mandatory = $true)]
    [string]$PfxPath,

    [Parameter(Mandatory = $true)]
    [SecureString]$SecurePassword
)

# Convert SecureString to plain text for certutil
$BSTR     = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecurePassword)
$PlainPwd = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

# Merge certificate and key into PFX using certutil
certutil -mergePFX -p "$PlainPwd,$PlainPwd" $CertPath $PfxPath

Write-Host "PFX exported to: $PfxPath"
