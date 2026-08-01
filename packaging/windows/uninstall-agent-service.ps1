#Requires -RunAsAdministrator
param([string]$ServiceName = "MQDeckAgent")

$ErrorActionPreference = "Stop"
$service = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
if ($service) {
    Stop-Service -Name $ServiceName -Force -ErrorAction SilentlyContinue
    sc.exe delete $ServiceName | Out-Null
    Write-Host "MQDeck Agent service removed. Configuration and binaries were retained."
} else {
    Write-Host "MQDeck Agent service is not installed."
}
