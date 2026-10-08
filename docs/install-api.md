# Install API

The API package contains only `mqdeck-api`, a minimal inventory example, its
properties template, installer, and service definition.

Download packages from the public
[MQDeck releases](https://github.com/mqdeck/mqdeck/releases) page. Set
`MQDECK_VERSION` to the release tag and `API_VERSION` to the API version listed
in that release's `COMPONENTS.md`.

## RHEL, Rocky Linux, AlmaLinux, or Oracle Linux

The commands below install the x86-64 build. Replace `linux_amd64` with
`linux_arm64` on ARM64 hosts.

```bash
MQDECK_VERSION=1.0.11 # MQDECK_VERSION
API_VERSION=1.0.40 # MQDECK_API_VERSION
curl -fLO "https://github.com/mqdeck/mqdeck/releases/download/v${MQDECK_VERSION}/mqdeck-api_${API_VERSION}_linux_amd64.tar.gz"
tar -xzf "mqdeck-api_${API_VERSION}_linux_amd64.tar.gz"
cd "mqdeck-api_${API_VERSION}_linux_amd64"
sudo ./install-api.sh
```

With `wget`, replace the first download command with:

```bash
wget "https://github.com/mqdeck/mqdeck/releases/download/v${MQDECK_VERSION}/mqdeck-api_${API_VERSION}_linux_amd64.tar.gz"
```

Review `/etc/mqdeck/inventory.yaml` and `/etc/mqdeck/api.properties`. Then validate and
start the component:

```bash
sudo -u mqdeck /opt/mqdeck/api/mqdeck-api -validate
sudo systemctl enable --now mqdeck-api
sudo systemctl status mqdeck-api --no-pager
curl --fail http://127.0.0.1:8080/healthz
```

Allow WebSocket upgrades for `/api/v1/workers/connect` in the reverse proxy.
For Queue Watch routes under `/api/v1/hosts/*/queues/*/watch`, preserve
`text/event-stream`, disable response buffering, and use a streaming timeout
appropriate for an operator-controlled session. The API sets
`X-Accel-Buffering: no`. The API needs no database or Elasticsearch.

The local assistant is optional and stays disabled until you add a GGUF model
or an OpenAI-compatible endpoint. See
[Local assistant and models](llm.md).

## Windows Server

Use the current public release and API version from `COMPONENTS.md`:

```powershell
$MqdeckVersion = "1.0.11" # MQDECK_VERSION
$ApiVersion = "1.0.40" # MQDECK_API_VERSION
$url = "https://github.com/mqdeck/mqdeck/releases/download/v$MqdeckVersion/mqdeck-api_${ApiVersion}_windows_amd64.zip"
Invoke-WebRequest $url -OutFile mqdeck-api.zip
Expand-Archive .\mqdeck-api.zip -DestinationPath .\mqdeck-api
Set-Location ".\mqdeck-api\mqdeck-api_${ApiVersion}_windows_amd64"
```

Verify its component checksum from the same public release, then run PowerShell
as Administrator:

```powershell
[Environment]::SetEnvironmentVariable("MQDECK_WORKER_TOKEN", "replace-with-a-long-random-secret", "Machine")
[Environment]::SetEnvironmentVariable("MQDECK_CORS_ORIGINS", "http://localhost:3000,http://127.0.0.1:3000", "Machine")
Set-ExecutionPolicy -Scope Process Bypass
.\install-api-service.ps1
notepad "$env:ProgramData\MQDeck\inventory.yaml"
Start-Service MQDeckAPI
Get-Service MQDeckAPI
```

Validate the executable before starting, and restart `MQDeckAPI` after changing
the inventory or machine-level environment variables.

To replace an existing API without overwriting its inventory or environment,
follow the [upgrade and rollback guide](upgrade.md).
