<#
    .SYNOPSIS
    Loads and validates Azure deployment configuration settings from a specified JSON file.

    .DESCRIPTION
    This script reads Azure deployment configuration from a JSON file, validates it against a specified JSON schema,
    and outputs each configuration property as a key-value pair. Intended for use in CI/CD pipelines (e.g., GitHub Actions).

    .PARAMETER File
    The path to the Azure deployment configuration JSON file to load and validate.

    .PARAMETER SchemaFile
    The path to the JSON schema file used for validation.
    Defaults to './devops/templates/schemas/azuredeploy.config.schema.json' if not specified.

    .OUTPUTS
    Writes each configuration property as a key-value pair to the output stream.
    Also writes status messages to the host.
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory)] [string] $File,
    [Parameter(Mandatory = $false)] [string] $SchemaFile = "./templates/schemas/azuredeploy.config.schema.json"
)
process {
    # Check if the azuredeploy config file exists
    if (-not (Test-Path -Path $File -PathType Leaf)) {
        Write-Error "Error: File '$File' not found. Failing job."
        exit 1 # Exit with a non-zero status to indicate failure
    }

    Write-Host "File '$File' found. Validate schema." -ForegroundColor Blue

    # Validate the JSON schema of the config file
    $configJson = Get-Content -Path $File -Raw
    Test-Json -Json $configJson -SchemaFile $SchemaFile -ErrorAction Stop

    # Convert the JSON content to a PowerShell object
    $config = $configJson | ConvertFrom-Json

    # Output each property as a key-value pair
    foreach ($prop in $config.psobject.properties.name) {
        Write-Output "$prop=$($config.$prop)" >> $Env:GITHUB_OUTPUT
    }

    Write-Host "File '$File' is valid. Continuing job" -ForegroundColor Green
}