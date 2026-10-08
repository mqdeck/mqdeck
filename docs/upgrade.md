# Upgrade and rollback

API, Worker, and Web have independent versions. Upgrade only the component named
by its release notes; unchanged components keep their installed versions.

Public packages are always downloaded from the
[MQDeck releases](https://github.com/mqdeck/mqdeck/releases) page. Use the
public release tag for the download URL and the component versions listed in
that release's `COMPONENTS.md` for the archive names. Private component
repositories are not download sources for operators.

## Record installed versions

Before changing anything, record each installed version independently:

```bash
/opt/mqdeck/api/mqdeck-api -version 2>/dev/null || true
/opt/mqdeck/worker/mqdeck-worker -version 2>/dev/null || true
node -p "require('/opt/mqdeck/web/package.json').version" 2>/dev/null || true
```

Back up configuration and keep the previous package for every component being
changed:

```bash
sudo install -d -m 0700 /var/backups/mqdeck
sudo cp -a /etc/mqdeck/. /var/backups/mqdeck/
```

Do not copy configuration from a package over `/etc/mqdeck`. The installers
preserve the existing inventory and the component properties files.

## Verify a component package

Every public release includes component checksum files. Download the checksum
from the same public release as the binary:

```bash
MQDECK_VERSION=1.0.8 # MQDECK_VERSION
WORKER_VERSION=1.0.34 # MQDECK_WORKER_VERSION
curl -fLO "https://github.com/mqdeck/mqdeck/releases/download/v${MQDECK_VERSION}/mqdeck-worker_${WORKER_VERSION}_SHA256SUMS"
sha256sum --check "mqdeck-worker_${WORKER_VERSION}_SHA256SUMS" --ignore-missing
```

On Windows:

```powershell
$MqdeckVersion = "1.0.8" # MQDECK_VERSION
$WorkerVersion = "1.0.34" # MQDECK_WORKER_VERSION
Invoke-WebRequest "https://github.com/mqdeck/mqdeck/releases/download/v$MqdeckVersion/mqdeck-worker_${WorkerVersion}_SHA256SUMS" -OutFile "mqdeck-worker_${WorkerVersion}_SHA256SUMS"
(Get-FileHash ".\mqdeck-worker_${WorkerVersion}_windows_amd64.zip" -Algorithm SHA256).Hash.ToLower()
Select-String -Path ".\mqdeck-worker_${WorkerVersion}_SHA256SUMS" -Pattern "windows_amd64.zip"
```

Do not mix a checksum from one public release with an asset from another.

## Upgrade API on Linux

Set the public release tag and the API version from that release's
`COMPONENTS.md`:

```bash
MQDECK_VERSION=1.0.8 # MQDECK_VERSION
API_VERSION=1.0.38 # MQDECK_API_VERSION
curl -fLO "https://github.com/mqdeck/mqdeck/releases/download/v${MQDECK_VERSION}/mqdeck-api_${API_VERSION}_linux_amd64.tar.gz"
tar -xzf "mqdeck-api_${API_VERSION}_linux_amd64.tar.gz"
cd "mqdeck-api_${API_VERSION}_linux_amd64"
./mqdeck-api -version
sudo -u mqdeck ./mqdeck-api -validate
sudo ./install-api.sh
curl --fail http://127.0.0.1:8080/healthz
```

The API installer replaces the API binary and the service unit. It leaves `/etc/mqdeck/api.properties` in place.

## Upgrade Workers on Linux

Upgrade one network zone at a time and confirm that each Worker reconnects
before continuing:

```bash
MQDECK_VERSION=1.0.8 # MQDECK_VERSION
WORKER_VERSION=1.0.34 # MQDECK_WORKER_VERSION
curl -fLO "https://github.com/mqdeck/mqdeck/releases/download/v${MQDECK_VERSION}/mqdeck-worker_${WORKER_VERSION}_linux_amd64.tar.gz"
tar -xzf "mqdeck-worker_${WORKER_VERSION}_linux_amd64.tar.gz"
cd "mqdeck-worker_${WORKER_VERSION}_linux_amd64"
./mqdeck-worker -version
sudo -u mqdeck ./mqdeck-worker -validate
sudo ./install-worker.sh
sudo systemctl status mqdeck-worker --no-pager
sudo journalctl -u mqdeck-worker -n 50 --no-pager
```

A Worker upgrade does not require upgrading API or Web unless its release notes
explicitly identify a protocol compatibility requirement. The installer leaves `/etc/mqdeck/worker.properties` in place.

## Upgrade Web on Linux

```bash
MQDECK_VERSION=1.0.8 # MQDECK_VERSION
WEB_VERSION=1.0.41 # MQDECK_WEB_VERSION
curl -fLO "https://github.com/mqdeck/mqdeck/releases/download/v${MQDECK_VERSION}/mqdeck-web_${WEB_VERSION}_standalone.tar.gz"
tar -xzf "mqdeck-web_${WEB_VERSION}_standalone.tar.gz"
cd "mqdeck-web_${WEB_VERSION}_standalone"
node --version
sudo ./install-web.sh
curl --fail http://127.0.0.1:3000/login
```

The Web installer preserves `/etc/mqdeck/web.properties`. The replaced application remains at `/opt/mqdeck/web.previous`.

## Windows Server

Use the same public release tag and independent component variables from
`COMPONENTS.md`:

```powershell
$MqdeckVersion = "1.0.8" # MQDECK_VERSION
$ApiVersion = "1.0.38" # MQDECK_API_VERSION
$WorkerVersion = "1.0.34" # MQDECK_WORKER_VERSION
$WebVersion = "1.0.41" # MQDECK_WEB_VERSION
```

Download and extract only the components being upgraded into new directories
from `https://github.com/mqdeck/mqdeck/releases/download/v$MqdeckVersion/`.
Run the corresponding `install-*-service.ps1` as Administrator, validate the
installed executable, and then start that service. Existing files under
`%ProgramData%\MQDeck` and machine-level `MQDECK_*` variables are preserved.

## Verification

Verify the component that changed, then run one end-to-end broker check:

1. API: confirm `/healthz` and the static inventory.
2. Worker: confirm presence in Workers, open a broker, and inspect its service
   log for collection errors.
3. Web: confirm login, inventory layout, and one broker detail page.
4. For IBM MQ, verify queues, channel definitions, current channel state, and
   Queue Watch with the authority available to the configured identity.

## Rollback

Reinstall the retained previous package for only the affected component. On
Linux, run that package's installer again. On Windows, extract the retained ZIP
into a clean directory and run its service installer. Restore configuration
only when the failed change included an intentional configuration migration.

Rollback order is the reverse of the components changed in that deployment;
there is no requirement for API, Worker, and Web version numbers to match.
