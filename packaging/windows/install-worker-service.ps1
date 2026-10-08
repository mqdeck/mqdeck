#Requires -RunAsAdministrator
param(
    [string]$InstallDirectory = "$env:ProgramFiles\MQDeck\Worker",
    [string]$DataDirectory = "$env:ProgramData\MQDeck",
    [string]$ServiceName = "MQDeckWorker"
)

$ErrorActionPreference = "Stop"
$sourceDirectory = Split-Path -Parent $MyInvocation.MyCommand.Path
$configPath = Join-Path $DataDirectory "worker.properties"
$existingService = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
if ($existingService) {
    Stop-Service -Name $ServiceName -Force -ErrorAction SilentlyContinue
}

New-Item -ItemType Directory -Force -Path $InstallDirectory, $DataDirectory | Out-Null
Copy-Item (Join-Path $sourceDirectory "mqdeck-worker.exe") $InstallDirectory -Force
if (-not (Test-Path $configPath)) {
    Copy-Item (Join-Path $sourceDirectory "worker.properties.example") $configPath
}

$binaryPath = '"{0}"' -f (Join-Path $InstallDirectory "mqdeck-worker.exe")
if ($existingService) {
    sc.exe config $ServiceName binPath= $binaryPath start= auto obj= "NT AUTHORITY\LocalService" | Out-Null
} else {
    sc.exe create $ServiceName binPath= $binaryPath start= auto obj= "NT AUTHORITY\LocalService" DisplayName= "MQDeck Worker" | Out-Null
}
sc.exe description $ServiceName "MQDeck read-only on-demand messaging worker" | Out-Null
Write-Host "MQDeck Worker service is created for the local API at http://127.0.0.1:8080. Review $configPath, then run Start-Service $ServiceName."
