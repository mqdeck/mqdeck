# Install Web

MQDeck Web is an independent standalone Node.js component. Install Node.js
20.20 or newer before installing the package.

## RHEL, Rocky Linux, AlmaLinux, or Oracle Linux

```bash
curl -fLO https://github.com/mqdeck/mqdeck/releases/download/v1.0.10/mqdeck-web_1.0.10_standalone.tar.gz
tar -xzf mqdeck-web_1.0.10_standalone.tar.gz
cd mqdeck-web_1.0.10_standalone
sudo ./install-web.sh
```

`wget` can be used instead of `curl -fLO` with the same URL. Review
`/etc/mqdeck/web.env`, then enable the service:

```bash
sudo systemctl enable --now mqdeck-web
sudo systemctl status mqdeck-web --no-pager
curl --fail http://127.0.0.1:3000/login
```

The browser uses same-origin Web proxy routes. Only Web needs operator login
credentials; it never connects directly to brokers or Agents.

## Windows Server

After installing Node.js 20.20 or newer, run PowerShell as Administrator:

```powershell
$url = "https://github.com/mqdeck/mqdeck/releases/download/v1.0.10/mqdeck-web_1.0.10_standalone.zip"
Invoke-WebRequest $url -OutFile mqdeck-web.zip
Expand-Archive .\mqdeck-web.zip -DestinationPath .\mqdeck-web
Set-Location .\mqdeck-web\mqdeck-web_1.0.10_standalone
[Environment]::SetEnvironmentVariable("MQDECK_API_URL", "https://api.mqdeck.example.com", "Machine")
[Environment]::SetEnvironmentVariable("MQDECK_AUTH_USERNAME", "admin", "Machine")
[Environment]::SetEnvironmentVariable("MQDECK_AUTH_PASSWORD", "replace-with-a-strong-password", "Machine")
[Environment]::SetEnvironmentVariable("MQDECK_AUTH_SESSION_SECRET", "replace-with-a-long-random-secret", "Machine")
Set-ExecutionPolicy -Scope Process Bypass
.\install-web-service.ps1
Start-Service MQDeckWeb
Get-Service MQDeckWeb
```
