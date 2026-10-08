# Install Web

MQDeck Web is an independent standalone Node.js component. Install Node.js
20.20 or newer before installing the package.

Download packages from the public
[MQDeck releases](https://github.com/mqdeck/mqdeck/releases) page. Set
`MQDECK_VERSION` to the release tag and `WEB_VERSION` to the Web version listed
in that release's `COMPONENTS.md`.

## RHEL, Rocky Linux, AlmaLinux, or Oracle Linux

```bash
MQDECK_VERSION=1.0.10 # MQDECK_VERSION
WEB_VERSION=1.0.41 # MQDECK_WEB_VERSION
curl -fLO "https://github.com/mqdeck/mqdeck/releases/download/v${MQDECK_VERSION}/mqdeck-web_${WEB_VERSION}_standalone.tar.gz"
tar -xzf "mqdeck-web_${WEB_VERSION}_standalone.tar.gz"
cd "mqdeck-web_${WEB_VERSION}_standalone"
sudo ./install-web.sh
```

`wget` can be used instead of `curl -fLO` with the same URL. Review
`/etc/mqdeck/web.properties`, then enable the service:

```bash
sudo systemctl enable --now mqdeck-web
sudo systemctl status mqdeck-web --no-pager
curl --fail http://127.0.0.1:3000/login
```

The browser uses same-origin Web proxy routes. The service package points Web
to the local API at `http://127.0.0.1:8080`; change `mqdeck.api.url` only when
the API runs on another machine. Only Web needs operator login credentials; it
never connects directly to brokers or Workers.

## Windows Server

After installing Node.js 20.20 or newer, run PowerShell as Administrator:

```powershell
$MqdeckVersion = "1.0.10" # MQDECK_VERSION
$WebVersion = "1.0.41" # MQDECK_WEB_VERSION
$url = "https://github.com/mqdeck/mqdeck/releases/download/v$MqdeckVersion/mqdeck-web_${WebVersion}_standalone.zip"
Invoke-WebRequest $url -OutFile mqdeck-web.zip
Expand-Archive .\mqdeck-web.zip -DestinationPath .\mqdeck-web
Set-Location ".\mqdeck-web\mqdeck-web_${WebVersion}_standalone"
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
