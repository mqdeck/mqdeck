# Install Agent on Windows Server

Install IBM MQ Client 9.4 when the Agent observes IBM MQ, and ensure
`runmqsc.exe` is available to the service account.

Run PowerShell as Administrator:

```powershell
$url = "https://mqdeck.github.io/mqdeck/downloads/1.0.10/mqdeck-agent_1.0.10_windows_amd64.zip"
Invoke-WebRequest $url -OutFile mqdeck-agent.zip
Expand-Archive .\mqdeck-agent.zip -DestinationPath .\mqdeck-agent
Set-Location .\mqdeck-agent\mqdeck-agent_1.0.10_windows_amd64
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
do not create an inbound Agent firewall rule.
