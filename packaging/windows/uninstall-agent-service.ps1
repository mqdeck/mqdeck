#Requires -RunAsAdministrator
param(
    [string]$ServiceName = "MQDeckAgent",
    [string]$InstallDirectory = "$env:ProgramFiles\MQDeck\Agent",
    [string]$DataDirectory = "$env:ProgramData\MQDeck",
    [switch]$PurgeBinaries,
    [switch]$PurgeConfiguration
)

$ErrorActionPreference = "Stop"
$service = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
if ($service) {
    Stop-Service -Name $ServiceName -Force -ErrorAction SilentlyContinue
    sc.exe delete $ServiceName | Out-Null
    Write-Host "MQDeck Agent service removed. Configuration and binaries were retained."
} else {
    Write-Host "MQDeck Agent service is not installed."
}
if ($PurgeBinaries -and (Test-Path $InstallDirectory)) {
    Remove-Item -Recurse -Force $InstallDirectory
    Write-Host "MQDeck Agent binaries removed from $InstallDirectory"
}
if ($PurgeConfiguration) {
    $configPath = Join-Path $DataDirectory "agent.yaml"
    if (Test-Path $configPath) {
        Remove-Item -Force $configPath
    }
    Write-Host "MQDeck Agent configuration removed from $configPath"
}
