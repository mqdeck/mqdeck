#Requires -RunAsAdministrator
param(
    [string]$ServiceName = "MQDeckWeb",
    [string]$InstallDirectory = "$env:ProgramFiles\MQDeck\Web",
    [switch]$PurgeBinaries
)

$ErrorActionPreference = "Stop"
$service = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
if ($service) {
    Stop-Service -Name $ServiceName -Force -ErrorAction SilentlyContinue
    sc.exe delete $ServiceName | Out-Null
    Write-Host "MQDeck Web service removed."
}
if ($PurgeBinaries -and (Test-Path $InstallDirectory)) {
    Remove-Item -Recurse -Force $InstallDirectory
}
