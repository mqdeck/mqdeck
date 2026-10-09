#Requires -RunAsAdministrator
param(
    [string]$InstallDirectory = "$env:ProgramFiles\MQDeck\API",
    [string]$DataDirectory = "$env:ProgramData\MQDeck",
    [string]$ServiceName = "MQDeckAPI"
)

$ErrorActionPreference = "Stop"
$sourceDirectory = Split-Path -Parent $MyInvocation.MyCommand.Path
$existingService = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
if ($existingService) {
    Stop-Service -Name $ServiceName -Force -ErrorAction SilentlyContinue
}
New-Item -ItemType Directory -Force -Path $InstallDirectory, $DataDirectory | Out-Null
Copy-Item (Join-Path $sourceDirectory "mqdeck-api.exe") $InstallDirectory -Force
$inventoryPath = Join-Path $DataDirectory "inventory.yaml"
$auditLogPath = Join-Path $DataDirectory "audit.jsonl"
if (-not (Test-Path $inventoryPath)) {
    Copy-Item (Join-Path $sourceDirectory "inventory.example.yaml") $inventoryPath
}
[Environment]::SetEnvironmentVariable("MQDECK_INVENTORY_PATH", $inventoryPath, "Machine")
[Environment]::SetEnvironmentVariable("MQDECK_AUDIT_LOG_PATH", $auditLogPath, "Machine")
$binaryPath = '"{0}"' -f (Join-Path $InstallDirectory "mqdeck-api.exe")
if ($existingService) {
    sc.exe config $ServiceName binPath= $binaryPath start= auto obj= "NT AUTHORITY\LocalService" | Out-Null
} else {
    sc.exe create $ServiceName binPath= $binaryPath start= auto obj= "NT AUTHORITY\LocalService" DisplayName= "MQDeck API" | Out-Null
}
sc.exe description $ServiceName "MQDeck inventory and Worker control plane" | Out-Null
Write-Host "MQDeck API service is created. Review $inventoryPath and set matching machine-level MQDECK_MANAGEMENT_TOKEN values for API and Web, then run Start-Service $ServiceName."
