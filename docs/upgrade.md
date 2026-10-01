# Upgrade and rollback

MQDeck is upgraded one component at a time. The API, Agent, and Web packages
are independent; there is no monolithic upgrade package and no database or
Elasticsearch migration.

This guide uses version `1.0.12`. Replace the version in filenames and URLs
when upgrading to a later release.

## Upgrade order and availability

For an installation with all components, use this order:

1. API
2. Agents
3. Web

Upgrade Agents one network zone at a time. An Agent is unavailable for
on-demand collection only while its service is being replaced and restarted.
The inventory overview remains available because it is read from the API's
static YAML inventory.

On Linux, an installer detects an active service, stops it, replaces only that
component, and starts it again. A service that was already stopped remains
stopped. On Windows, the installer stops an existing service and leaves it
stopped so that the new binary can be validated before it is started.

## Before upgrading

Read the release notes and download the package for each component and
architecture from the [MQDeck release](https://github.com/mqdeck/mqdeck/releases/tag/v1.0.12).
Keep the previous packages until the upgrade has been verified.

Back up the configuration. The component installers preserve these files, but
the backup provides an explicit rollback point.

### Linux

```bash
sudo install -d -m 0700 /var/backups/mqdeck
sudo cp -a /etc/mqdeck/. /var/backups/mqdeck/
sudo systemctl status mqdeck-api mqdeck-agent mqdeck-web --no-pager
```

Only the files that exist on that host are copied. If the components use a
secret manager or systemd override, back that configuration up separately.

Download the checksums beside the packages and verify them before extracting:

```bash
curl -fLO https://github.com/mqdeck/mqdeck/releases/download/v1.0.12/SHA256SUMS
sha256sum --check SHA256SUMS --ignore-missing
```

The result must report `OK` for every downloaded package. Do not install a
package that fails verification.

### Windows Server

Run PowerShell as Administrator and back up the shared data directory and the
machine-level MQDeck settings:

```powershell
$backup = "C:\MQDeck-backup-$(Get-Date -Format yyyyMMdd-HHmmss)"
New-Item -ItemType Directory -Path $backup | Out-Null
Copy-Item "$env:ProgramData\MQDeck" "$backup\ProgramData-MQDeck" -Recurse -ErrorAction SilentlyContinue
Get-ChildItem Env:MQDECK_* | Sort-Object Name | Format-Table -AutoSize | Out-File "$backup\mqdeck-environment.txt"
Get-Service MQDeckAPI, MQDeckAgent, MQDeckWeb -ErrorAction SilentlyContinue
```

Download `SHA256SUMS` and compare a package with its published value:

```powershell
(Get-FileHash .\mqdeck-api_1.0.12_windows_amd64.zip -Algorithm SHA256).Hash.ToLower()
Select-String -Path .\SHA256SUMS -Pattern "mqdeck-api_1.0.12_windows_amd64.zip"
```

The two hashes must be identical.

## Upgrade on Linux with systemd

The examples use x86-64 packages. Use `linux_arm64` on ARM64 hosts. Extract
each component into its own directory and run the installer from that
directory.

### 1. API

```bash
curl -fLO https://github.com/mqdeck/mqdeck/releases/download/v1.0.12/mqdeck-api_1.0.12_linux_amd64.tar.gz
tar -xzf mqdeck-api_1.0.12_linux_amd64.tar.gz
cd mqdeck-api_1.0.12_linux_amd64
./mqdeck-api -version
sudo bash -c 'set -a; . /etc/mqdeck/api.env; set +a; MQDECK_INVENTORY_PATH=/etc/mqdeck/inventory.yaml ./mqdeck-api -validate'
sudo ./install-api.sh
sudo systemctl status mqdeck-api --no-pager
curl --fail http://127.0.0.1:8080/healthz
```

The installer replaces `/opt/mqdeck/api/mqdeck-api` and the systemd unit. It
does not overwrite `/etc/mqdeck/inventory.yaml` or `/etc/mqdeck/api.env`.

### 2. Agent

Repeat this procedure for each Agent host:

```bash
curl -fLO https://github.com/mqdeck/mqdeck/releases/download/v1.0.12/mqdeck-agent_1.0.12_linux_amd64.tar.gz
tar -xzf mqdeck-agent_1.0.12_linux_amd64.tar.gz
cd mqdeck-agent_1.0.12_linux_amd64
./mqdeck-agent -version
sudo bash -c 'set -a; . /etc/mqdeck/agent.env; set +a; ./mqdeck-agent -config /etc/mqdeck/agent.yaml -validate'
sudo ./install-agent.sh
sudo systemctl status mqdeck-agent --no-pager
sudo journalctl -u mqdeck-agent -n 50 --no-pager
```

The installer preserves `/etc/mqdeck/agent.yaml` and
`/etc/mqdeck/agent.env`. Confirm in the API or Web control panel that the Agent
has reconnected before proceeding to the next Agent. See [View Agent
logs](install-agent-linux.md#view-agent-logs) for live and historical
`journalctl` commands.

### 3. Web

Node.js 20.20 or newer must already be installed:

```bash
curl -fLO https://github.com/mqdeck/mqdeck/releases/download/v1.0.12/mqdeck-web_1.0.12_standalone.tar.gz
tar -xzf mqdeck-web_1.0.12_standalone.tar.gz
cd mqdeck-web_1.0.12_standalone
node --version
sudo ./install-web.sh
sudo systemctl status mqdeck-web --no-pager
curl --fail http://127.0.0.1:3000/login
```

The installer preserves `/etc/mqdeck/web.env` and retains the replaced Web
application at `/opt/mqdeck/web.previous`.

If a component was intentionally stopped before the upgrade, validate it and
start it explicitly with `sudo systemctl start <service>`. Do not use
`enable --now` during a routine upgrade unless the service should also be
enabled at boot.

## Upgrade on Windows Server

Use a new extraction directory for every version. Do not extract a new package
over the files from an older release. Run PowerShell as Administrator.

### 1. API

```powershell
$url = "https://github.com/mqdeck/mqdeck/releases/download/v1.0.12/mqdeck-api_1.0.12_windows_amd64.zip"
Invoke-WebRequest $url -OutFile .\mqdeck-api_1.0.12_windows_amd64.zip
Expand-Archive .\mqdeck-api_1.0.12_windows_amd64.zip -DestinationPath .\mqdeck-api-1.0.12
Set-Location .\mqdeck-api-1.0.12\mqdeck-api_1.0.12_windows_amd64
.\mqdeck-api.exe -version
Set-ExecutionPolicy -Scope Process Bypass
.\install-api-service.ps1
$env:MQDECK_INVENTORY_PATH = "$env:ProgramData\MQDeck\inventory.yaml"
& "$env:ProgramFiles\MQDeck\API\mqdeck-api.exe" -validate
Start-Service MQDeckAPI
Get-Service MQDeckAPI
Invoke-WebRequest http://127.0.0.1:8080/healthz -UseBasicParsing
```

The installer preserves `%ProgramData%\MQDeck\inventory.yaml` and the
machine-level `MQDECK_*` variables.

### 2. Agent

```powershell
$url = "https://github.com/mqdeck/mqdeck/releases/download/v1.0.12/mqdeck-agent_1.0.12_windows_amd64.zip"
Invoke-WebRequest $url -OutFile .\mqdeck-agent_1.0.12_windows_amd64.zip
Expand-Archive .\mqdeck-agent_1.0.12_windows_amd64.zip -DestinationPath .\mqdeck-agent-1.0.12
Set-Location .\mqdeck-agent-1.0.12\mqdeck-agent_1.0.12_windows_amd64
.\mqdeck-agent.exe -version
Set-ExecutionPolicy -Scope Process Bypass
.\install-agent-service.ps1
& "$env:ProgramFiles\MQDeck\Agent\mqdeck-agent.exe" -config "$env:ProgramData\MQDeck\agent.yaml" -validate
Start-Service MQDeckAgent
Get-Service MQDeckAgent
```

The installer preserves `%ProgramData%\MQDeck\agent.yaml` and existing
machine-level settings such as `MQDECK_API_URL` and `MQDECK_AGENT_TOKEN`.

### 3. Web

```powershell
$url = "https://github.com/mqdeck/mqdeck/releases/download/v1.0.12/mqdeck-web_1.0.12_standalone.zip"
Invoke-WebRequest $url -OutFile .\mqdeck-web_1.0.12_standalone.zip
Expand-Archive .\mqdeck-web_1.0.12_standalone.zip -DestinationPath .\mqdeck-web-1.0.12
Set-Location .\mqdeck-web-1.0.12\mqdeck-web_1.0.12_standalone
node --version
Set-ExecutionPolicy -Scope Process Bypass
.\install-web-service.ps1
Start-Service MQDeckWeb
Get-Service MQDeckWeb
Invoke-WebRequest http://127.0.0.1:3000/login -UseBasicParsing
```

The Web installer preserves the machine-level `MQDECK_API_URL` and
`MQDECK_AUTH_*` settings. Windows does not create a `web.previous` directory;
keep the previous ZIP for rollback.

## Verify version 1.0.12

After all components are healthy:

1. Confirm all expected Agents are connected.
2. Open a queue manager and request its current details.
3. Confirm that the access channel is shown.
4. Expand Channels and confirm that application, client/server connection, and
   `SYSTEM.*` definitions visible to the MQ identity are listed. A defined
   channel without a current `CHSTATUS` instance must appear as defined, not as
   failed.
5. Confirm that system queues are included in the queue flow.
6. If the MQ user has limited authority, confirm that Web shows a visibility
   warning instead of reporting an unhealthy queue manager solely because
   some `DISPLAY` commands were not permitted.

MQDeck can display only the IBM MQ objects that the connected user is allowed
to inquire. The access channel remains visible because it comes from the
static inventory, even when the user cannot list all channel objects.

## Helm upgrade

For Kubernetes installations, keep the existing values and upgrade the chart:

```bash
helm upgrade mqdeck oci://ghcr.io/mqdeck/charts/mqdeck \
  --version 1.0.12 \
  --namespace mqdeck \
  --reuse-values \
  --wait
```

Review rendered changes before production upgrades when values or secrets also
change. See [Install with Helm](install-helm.md) for the initial installation
and image configuration.

## Rollback

Rollback in reverse order: Web, Agents, then API.

On Linux, extract the retained package for the previous version and run that
component's installer again. On Windows, extract the retained previous ZIP
into a clean directory, run its service installer, validate, and start the
service. Restore the configuration backup only if configuration was also
changed during the upgrade.

Version `1.0.12` does not require an inventory schema migration, so existing
minimal inventories and Agent configurations remain valid. After rollback,
repeat the health, Agent connection, and broker-detail checks above.
