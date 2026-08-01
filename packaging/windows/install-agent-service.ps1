#Requires -RunAsAdministrator
param(
    [string]$InstallDirectory = "$env:ProgramFiles\MQDeck\Agent",
    [string]$DataDirectory = "$env:ProgramData\MQDeck",
    [string]$ServiceName = "MQDeckAgent"
)

$ErrorActionPreference = "Stop"
$sourceDirectory = Split-Path -Parent $MyInvocation.MyCommand.Path
$configPath = Join-Path $DataDirectory "agent.yaml"

New-Item -ItemType Directory -Force -Path $InstallDirectory, $DataDirectory | Out-Null
Copy-Item (Join-Path $sourceDirectory "mqdeck-agent.exe") $InstallDirectory -Force
if (-not (Test-Path $configPath)) {
    Copy-Item (Join-Path $sourceDirectory "mqdeck.yaml.example") $configPath
}

$binaryPath = '"{0}" -config "{1}"' -f (Join-Path $InstallDirectory "mqdeck-agent.exe"), $configPath
$existingService = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
if ($existingService) {
    Stop-Service -Name $ServiceName -Force -ErrorAction SilentlyContinue
    sc.exe config $ServiceName binPath= $binaryPath start= auto obj= "NT AUTHORITY\LocalService" | Out-Null
} else {
    sc.exe create $ServiceName binPath= $binaryPath start= auto obj= "NT AUTHORITY\LocalService" DisplayName= "MQDeck Agent" | Out-Null
}
sc.exe description $ServiceName "MQDeck read-only messaging observability agent" | Out-Null
Start-Service -Name $ServiceName
Write-Host "MQDeck Agent is installed. Configuration: $configPath"
