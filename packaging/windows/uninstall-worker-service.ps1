#Requires -RunAsAdministrator
param(
    [string]$ServiceName = "MQDeckWorker",
    [string]$InstallDirectory = "$env:ProgramFiles\MQDeck\Worker",
    [string]$DataDirectory = "$env:ProgramData\MQDeck",
    [switch]$PurgeBinaries,
    [switch]$PurgeConfiguration
)

$ErrorActionPreference = "Stop"
$service = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
if ($service) {
    Stop-Service -Name $ServiceName -Force -ErrorAction SilentlyContinue
    sc.exe delete $ServiceName | Out-Null
    Write-Host "MQDeck Worker service removed. Configuration and binaries were retained."
} else {
    Write-Host "MQDeck Worker service is not installed."
}
if ($PurgeBinaries -and (Test-Path $InstallDirectory)) {
    Remove-Item -Recurse -Force $InstallDirectory
    Write-Host "MQDeck Worker binaries removed from $InstallDirectory"
}
if ($PurgeConfiguration) {
    $configPath = Join-Path $DataDirectory "worker.properties"
    if (Test-Path $configPath) {
        Remove-Item -Force $configPath
    }
    Write-Host "MQDeck Worker configuration removed from $configPath"
}
