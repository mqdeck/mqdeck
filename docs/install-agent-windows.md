# Install the Agent on Windows

The Windows package contains `mqdeck-agent.exe`, a configuration example, and
PowerShell helpers. The user remains responsible for reviewing and creating
the Windows service; the included script is an auditable convenience wrapper.

## Download and verify

Download `mqdeck-agent-1.0.7-windows-amd64.zip` and `SHA256SUMS` from the
[1.0.7 release](https://github.com/mqdeck/mqdeck/releases/tag/v1.0.7).

In PowerShell:

```powershell
$Version = "1.0.7"
$File = "mqdeck-agent-$Version-windows-amd64.zip"
Invoke-WebRequest "https://github.com/mqdeck/mqdeck/releases/download/v$Version/$File" -OutFile $File
Invoke-WebRequest "https://github.com/mqdeck/mqdeck/releases/download/v$Version/SHA256SUMS" -OutFile SHA256SUMS
$Expected = (Select-String -Path SHA256SUMS -Pattern " $File$").Line.Split()[0]
$Actual = (Get-FileHash $File -Algorithm SHA256).Hash.ToLowerInvariant()
if ($Actual -ne $Expected) { throw "Checksum verification failed" }
Expand-Archive $File -DestinationPath . -Force
```

## Configure and create the service

Open an elevated PowerShell prompt in the extracted directory:

```powershell
.\install-agent-service.ps1
notepad "$env:ProgramData\MQDeck\agent.yaml"
```

Set secrets as machine-level environment variables referenced by the YAML:

```powershell
[Environment]::SetEnvironmentVariable("MQDECK_ELASTICSEARCH_URL", "https://elastic.example.com:9200", "Machine")
[Environment]::SetEnvironmentVariable("MQDECK_ELASTICSEARCH_API_KEY", "replace-me", "Machine")
Restart-Service MQDeckAgent
```

The service runs as `LocalService`, starts automatically, and reads
`C:\ProgramData\MQDeck\agent.yaml`. Review whether that identity has the
minimum filesystem and local broker permissions required in your environment.

IBM MQ `client` transport requires an IBM MQ Client 9.4 installation with
`runmqsc.exe` available to the service. If it is not on the system `PATH`, set
`command.executable` in the host definition to its absolute path. The service
identity must be able to execute the client and reach the configured
`SVRCONN` listener. Normal collection does not require the IBM MQ web server.

## Operate

```powershell
Get-Service MQDeckAgent
Get-WinEvent -LogName Application -MaxEvents 100 | Where-Object ProviderName -Like "*MQDeck*"
& "$env:ProgramFiles\MQDeck\Agent\mqdeck-agent.exe" -version
```

The executable logs structured JSON to standard output. For centralized
Windows logging, configure your service wrapper or log collector to capture
service output.

## Remove the service

```powershell
.\uninstall-agent-service.ps1
```

The removal script retains binaries and configuration so they can be backed up
or reused.

Remove the installed executable or configuration only when explicitly needed:

```powershell
.\uninstall-agent-service.ps1 -PurgeBinaries
.\uninstall-agent-service.ps1 -PurgeBinaries -PurgeConfiguration
```

## Upgrade

Download and verify the new ZIP, extract it to a temporary directory, and rerun
the installer from an elevated PowerShell prompt:

```powershell
.\install-agent-service.ps1
```

The installer stops the existing service before replacing the executable,
preserves `C:\ProgramData\MQDeck\agent.yaml`, and starts the service again.
