#Requires -RunAsAdministrator
param(
    [string]$InstallDirectory = "$env:ProgramFiles\MQDeck\API",
    [string]$ServiceName = "MQDeckAPI"
)

$ErrorActionPreference = "Stop"
$sourceDirectory = Split-Path -Parent $MyInvocation.MyCommand.Path
New-Item -ItemType Directory -Force -Path $InstallDirectory | Out-Null
Copy-Item (Join-Path $sourceDirectory "mqdeck-api.exe") $InstallDirectory -Force
$binaryPath = '"{0}"' -f (Join-Path $InstallDirectory "mqdeck-api.exe")
$existingService = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
if ($existingService) {
    Stop-Service -Name $ServiceName -Force -ErrorAction SilentlyContinue
    sc.exe config $ServiceName binPath= $binaryPath start= auto obj= "NT AUTHORITY\LocalService" | Out-Null
} else {
    sc.exe create $ServiceName binPath= $binaryPath start= auto obj= "NT AUTHORITY\LocalService" DisplayName= "MQDeck API" | Out-Null
}
sc.exe description $ServiceName "MQDeck read-only query API" | Out-Null
Start-Service -Name $ServiceName
Write-Host "MQDeck API is installed. Configure machine-level MQDECK_* environment variables and restart the service."
