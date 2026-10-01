# Install Agent on Windows

Install IBM MQ client tools when observing IBM MQ, place `mqdeck-agent.exe` and
`agent.yaml` in the chosen program directory, and set the Agent token as a
machine or service-scoped environment variable.

```powershell
$env:MQDECK_AGENT_TOKEN = "replace-with-the-api-token"
& .\mqdeck-agent.exe -config .\agent.yaml -validate
```

Use the packaged PowerShell service installer after validation. Permit outbound
TLS to the API and broker endpoints; do not expose an inbound Agent port.
