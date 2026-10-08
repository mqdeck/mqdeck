# Install Worker on Windows Server

Install IBM MQ Client 9.4 when the Worker observes IBM MQ. `mqdeck.worker.ibmmq.client` defaults to `/opt/mqm/bin`. On Windows, set it to the client bin directory, usually `C:\Program Files\IBM\MQ\bin`. The Worker runs `runmqsc`, `dmpmqmsg`, and the other client utilities from that directory.

Download packages from the public
[MQDeck releases](https://github.com/mqdeck/mqdeck/releases) page. Set
`$MqdeckVersion` to the release tag and `$WorkerVersion` to the Worker version
listed in that release's `COMPONENTS.md`.

Run PowerShell as Administrator:

```powershell
$MqdeckVersion = "1.0.8" # MQDECK_VERSION
$WorkerVersion = "1.0.34" # MQDECK_WORKER_VERSION
$url = "https://github.com/mqdeck/mqdeck/releases/download/v$MqdeckVersion/mqdeck-worker_${WorkerVersion}_windows_amd64.zip"
Invoke-WebRequest $url -OutFile mqdeck-worker.zip
Expand-Archive .\mqdeck-worker.zip -DestinationPath .\mqdeck-worker
Set-Location ".\mqdeck-worker\mqdeck-worker_${WorkerVersion}_windows_amd64"
Set-ExecutionPolicy -Scope Process Bypass
.\install-worker-service.ps1
notepad "$env:ProgramData\MQDeck\worker.properties"
Start-Service MQDeckWorker
Get-Service MQDeckWorker
```

Review `%ProgramData%\MQDeck\worker.properties`, validate with
`mqdeck-worker.exe -validate`, and restart the service after
changing configuration. Permit outbound TLS to the API and broker endpoints;
do not create an inbound Worker firewall rule. `mqdeck.api.url` defaults to
`http://127.0.0.1:8080`; replace it only when the API runs on another machine.

## Inspect the Worker service

Check whether the service is running and review Service Control Manager events
from the last hour in an Administrator PowerShell session:

```powershell
Get-Service MQDeckWorker
Get-CimInstance Win32_Service -Filter "Name='MQDeckWorker'" |
  Select-Object Name, State, StartMode, ProcessId, ExitCode
Get-WinEvent -FilterHashtable @{
  LogName = "System"
  ProviderName = "Service Control Manager"
  StartTime = (Get-Date).AddHours(-1)
} | Where-Object Message -Match "MQDeckWorker" |
  Select-Object TimeCreated, LevelDisplayName, Message
```

These events show service start, stop, and launch failures. The Worker also
reports its current connection state in the MQDeck Workers screen. For a
foreground diagnostic, stop the service during a maintenance window and run
the installed executable directly; restore the service immediately afterward:

```powershell
Stop-Service MQDeckWorker
& "$env:ProgramFiles\MQDeck\Worker\mqdeck-worker.exe"
# Press Ctrl+C after collecting the diagnostic output.
Start-Service MQDeckWorker
```

For an existing Windows service, follow the [upgrade and rollback
guide](upgrade.md). The installer stops the service and leaves it stopped until
the new binary has been validated.
