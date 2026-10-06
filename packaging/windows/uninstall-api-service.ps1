#Requires -RunAsAdministrator
param(
    [string]$ServiceName = "MQDeckAPI",
    [string]$InstallDirectory = "$env:ProgramFiles\MQDeck\API",
    [switch]$PurgeBinaries
)

$ErrorActionPreference = "Stop"
$service = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
if ($service) {
    Stop-Service -Name $ServiceName -Force -ErrorAction SilentlyContinue
    sc.exe delete $ServiceName | Out-Null
    Write-Host "MQDeck API service removed. The binary was retained."
} else {
    Write-Host "MQDeck API service is not installed."
}
if ($PurgeBinaries -and (Test-Path $InstallDirectory)) {
    Remove-Item -Recurse -Force $InstallDirectory
    Write-Host "MQDeck API binaries removed from $InstallDirectory"
}
