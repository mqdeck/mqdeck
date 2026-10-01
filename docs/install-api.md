# Install API

The API package contains only `mqdeck-api`, a minimal inventory example, its
environment template, installer, and service definition.

## RHEL, Rocky Linux, AlmaLinux, or Oracle Linux

The commands below install the x86-64 build. Replace `linux_amd64` with
`linux_arm64` on ARM64 hosts.

```bash
curl -fLO https://github.com/mqdeck/mqdeck/releases/download/v1.0.12/mqdeck-api_1.0.12_linux_amd64.tar.gz
tar -xzf mqdeck-api_1.0.12_linux_amd64.tar.gz
cd mqdeck-api_1.0.12_linux_amd64
sudo ./install-api.sh
```

With `wget`, replace the first command with:

```bash
wget https://github.com/mqdeck/mqdeck/releases/download/v1.0.12/mqdeck-api_1.0.12_linux_amd64.tar.gz
```

Review `/etc/mqdeck/inventory.yaml` and `/etc/mqdeck/api.env`. Then validate and
start the component:

```bash
sudo -u mqdeck bash -c 'set -a; . /etc/mqdeck/api.env; set +a; /opt/mqdeck/api/mqdeck-api -validate'
sudo systemctl enable --now mqdeck-api
sudo systemctl status mqdeck-api --no-pager
curl --fail http://127.0.0.1:8080/healthz
```

Allow WebSocket upgrades for `/api/v1/agents/connect` in the reverse proxy.
The API needs no database or Elasticsearch.

## Windows Server

Download `mqdeck-api_1.0.12_windows_amd64.zip`, verify its checksum, extract it,
and run PowerShell as Administrator:

```powershell
[Environment]::SetEnvironmentVariable("MQDECK_AGENT_TOKEN", "replace-with-a-long-random-secret", "Machine")
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
