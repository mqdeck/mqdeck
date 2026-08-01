#Requires -RunAsAdministrator
param([string]$ServiceName = "MQDeckAPI")

$ErrorActionPreference = "Stop"
$service = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
if ($service) {
    Stop-Service -Name $ServiceName -Force -ErrorAction SilentlyContinue
    sc.exe delete $ServiceName | Out-Null
    Write-Host "MQDeck API service removed. The binary was retained."
} else {
    Write-Host "MQDeck API service is not installed."
}
