param(
    [string]$CertFilePath = "C:\Users\aporodnov\Downloads\certificate.crt",
    [string]$KeyFilePath  = "C:\Users\aporodnov\Downloads\private.key",
    [string]$PfxFilePath  = "C:\Users\aporodnov\Downloads\wafToday.pfx",
    [string]$Password
)

# Read certificate (assumes PEM .crt)
$certPem   = Get-Content -Raw -Path $CertFilePath
$certBytes = [Convert]::FromBase64String(($certPem -replace '-----.*?-----','').Trim())
$cert      = [System.Security.Cryptography.X509Certificates.X509Certificate2]::new($certBytes)

# Read private key (PKCS#8 PEM)
$keyPem   = Get-Content -Raw -Path $KeyFilePath
$keyBytes = [Convert]::FromBase64String(($keyPem -replace '-----.*?-----','').Trim())

$rsa = [System.Security.Cryptography.RSA]::Create()
[void]$rsa.ImportPkcs8PrivateKey($keyBytes, [ref]0)   # <-- FIXED: no ReadOnlySpan, works in PowerShell

# Attach key to cert
$certWithKey = $cert.CopyWithPrivateKey($rsa)

# Export to PFX
$pfxBytes = $certWithKey.Export(
    [System.Security.Cryptography.X509Certificates.X509ContentType]::Pfx,
    $Password
)
[System.IO.File]::WriteAllBytes($PfxFilePath, $pfxBytes)

Write-Host "✅ PFX successfully created at $PfxFilePath"
