# Install Web

MQDeck Web is an independent standalone Node.js component. Install Node.js
20.20 or newer before installing the package.

## RHEL, Rocky Linux, AlmaLinux, or Oracle Linux

```bash
curl -fLO https://github.com/mqdeck/mqdeck/releases/download/v1.0.18/mqdeck-web_1.0.18_standalone.tar.gz
tar -xzf mqdeck-web_1.0.18_standalone.tar.gz
cd mqdeck-web_1.0.18_standalone
sudo ./install-web.sh
```

`wget` can be used instead of `curl -fLO` with the same URL. Review
`/etc/mqdeck/web.env`, then enable the service:

```bash
sudo systemctl enable --now mqdeck-web
sudo systemctl status mqdeck-web --no-pager
curl --fail http://127.0.0.1:3000/login
```

The browser uses same-origin Web proxy routes. The service package points Web
to the local API at `http://127.0.0.1:8080`; change `MQDECK_API_URL` only when
the API runs on another machine. Only Web needs operator login credentials; it
never connects directly to brokers or Agents.

## Windows Server

After installing Node.js 20.20 or newer, run PowerShell as Administrator:

```powershell
$url = "https://github.com/mqdeck/mqdeck/releases/download/v1.0.18/mqdeck-web_1.0.18_standalone.zip"
Invoke-WebRequest $url -OutFile mqdeck-web.zip
Expand-Archive .\mqdeck-web.zip -DestinationPath .\mqdeck-web
Set-Location .\mqdeck-web\mqdeck-web_1.0.18_standalone
[Environment]::SetEnvironmentVariable("MQDECK_AUTH_USERNAME", "admin", "Machine")
[Environment]::SetEnvironmentVariable("MQDECK_AUTH_PASSWORD", "replace-with-a-strong-password", "Machine")
[Environment]::SetEnvironmentVariable("MQDECK_AUTH_SESSION_SECRET", "replace-with-a-long-random-secret", "Machine")
Set-ExecutionPolicy -Scope Process Bypass
.\install-web-service.ps1
Start-Service MQDeckWeb
Get-Service MQDeckWeb
```

The Windows installer also defaults `MQDECK_API_URL` to
`http://127.0.0.1:8080` when the variable has not already been configured.

For an existing Web service, follow the [upgrade and rollback
guide](upgrade.md). Authentication and API settings are preserved.
