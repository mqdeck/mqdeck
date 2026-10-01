# Install Agent on Windows Server

Install IBM MQ Client 9.4 when the Agent observes IBM MQ, and ensure
`runmqsc.exe` is available to the service account.

Run PowerShell as Administrator:

```powershell
$url = "https://github.com/mqdeck/mqdeck/releases/download/v1.0.15/mqdeck-agent_1.0.15_windows_amd64.zip"
Invoke-WebRequest $url -OutFile mqdeck-agent.zip
Expand-Archive .\mqdeck-agent.zip -DestinationPath .\mqdeck-agent
Set-Location .\mqdeck-agent\mqdeck-agent_1.0.15_windows_amd64
[Environment]::SetEnvironmentVariable("MQDECK_AGENT_TOKEN", "replace-with-the-same-api-token", "Machine")
Set-ExecutionPolicy -Scope Process Bypass
.\install-agent-service.ps1
notepad "$env:ProgramData\MQDeck\agent.yaml"
Start-Service MQDeckAgent
Get-Service MQDeckAgent
```

Review `%ProgramData%\MQDeck\agent.yaml`, validate with
`mqdeck-agent.exe -config <path> -validate`, and restart the service after
changing configuration. Permit outbound TLS to the API and broker endpoints;
do not create an inbound Agent firewall rule. The installer defaults
`MQDECK_API_URL` to `http://127.0.0.1:8080`; replace it only when the API runs
on another machine.

## Inspect the Agent service

Check whether the service is running and review Service Control Manager events
from the last hour in an Administrator PowerShell session:

```powershell
Get-Service MQDeckAgent
Get-CimInstance Win32_Service -Filter "Name='MQDeckAgent'" |
  Select-Object Name, State, StartMode, ProcessId, ExitCode
Get-WinEvent -FilterHashtable @{
  LogName = "System"
  ProviderName = "Service Control Manager"
  StartTime = (Get-Date).AddHours(-1)
} | Where-Object Message -Match "MQDeckAgent" |
  Select-Object TimeCreated, LevelDisplayName, Message
```

These events show service start, stop, and launch failures. The Agent also
reports its current connection state in the MQDeck Agents screen. For a
foreground diagnostic, stop the service during a maintenance window and run
the installed executable directly; restore the service immediately afterward:

```powershell
Stop-Service MQDeckAgent
& "$env:ProgramFiles\MQDeck\Agent\mqdeck-agent.exe" -config "$env:ProgramData\MQDeck\agent.yaml"
# Press Ctrl+C after collecting the diagnostic output.
Start-Service MQDeckAgent
```

For an existing Windows service, follow the [upgrade and rollback
guide](upgrade.md). The installer stops the service and leaves it stopped until
the new binary has been validated.
