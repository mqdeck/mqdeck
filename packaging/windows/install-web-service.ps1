#Requires -RunAsAdministrator
param(
    [string]$InstallDirectory = "$env:ProgramFiles\MQDeck\Web",
    [string]$ServiceName = "MQDeckWeb"
)

$ErrorActionPreference = "Stop"
$sourceDirectory = Split-Path -Parent $MyInvocation.MyCommand.Path
$nodePath = (Get-Command node.exe -ErrorAction Stop).Source
$existingService = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
if ($existingService) {
    Stop-Service -Name $ServiceName -Force -ErrorAction SilentlyContinue
}

New-Item -ItemType Directory -Force -Path $InstallDirectory | Out-Null
Copy-Item (Join-Path $sourceDirectory "app\*") $InstallDirectory -Recurse -Force
if (-not [Environment]::GetEnvironmentVariable("MQDECK_API_URL", "Machine")) {
    [Environment]::SetEnvironmentVariable("MQDECK_API_URL", "http://127.0.0.1:8080", "Machine")
}
$serverPath = Join-Path $InstallDirectory "server.js"
$binaryPath = '"{0}" "{1}"' -f $nodePath, $serverPath
if ($existingService) {
    sc.exe config $ServiceName binPath= $binaryPath start= auto obj= "NT AUTHORITY\LocalService" | Out-Null
} else {
    sc.exe create $ServiceName binPath= $binaryPath start= auto obj= "NT AUTHORITY\LocalService" DisplayName= "MQDeck Web" | Out-Null
}
sc.exe description $ServiceName "MQDeck Web interface" | Out-Null
Write-Host "MQDeck Web service is created for the local API at http://127.0.0.1:8080. Review the machine-level MQDECK_AUTH_* variables, then run Start-Service $ServiceName."
