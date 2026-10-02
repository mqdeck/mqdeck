# Upgrade and rollback

API, Agent, and Web have independent versions and release histories. Upgrade
only the component named by its release notes; unchanged components keep their
installed versions. A component bundle in the main repository is a convenience
collection and its tag is not a shared product version.

Component releases:

- [MQDeck API](https://github.com/mqdeck/mqdeck-api/releases)
- [MQDeck Agent](https://github.com/mqdeck/mqdeck-agent/releases)
- [MQDeck Web](https://github.com/mqdeck/mqdeck-web/releases)

## Record installed versions

Before changing anything, record each installed version independently:

```bash
/opt/mqdeck/api/mqdeck-api -version 2>/dev/null || true
/opt/mqdeck/agent/mqdeck-agent -version 2>/dev/null || true
node -p "require('/opt/mqdeck/web/package.json').version" 2>/dev/null || true
```

Back up configuration and keep the previous package for every component being
changed:

```bash
sudo install -d -m 0700 /var/backups/mqdeck
sudo cp -a /etc/mqdeck/. /var/backups/mqdeck/
```

Do not copy configuration from a package over `/etc/mqdeck`. The installers
preserve the existing inventory, Agent configuration, Web environment, and
component secrets.

## Verify a component package

Every component release includes its own checksum file. Download the checksum
from the same component release as the binary:

```bash
sha256sum --check mqdeck-agent_X.Y.Z_SHA256SUMS --ignore-missing
```

On Windows:

```powershell
(Get-FileHash .\mqdeck-agent_X.Y.Z_windows_amd64.zip -Algorithm SHA256).Hash.ToLower()
Select-String -Path .\mqdeck-agent_X.Y.Z_SHA256SUMS -Pattern "windows_amd64.zip"
```

Do not mix a checksum from an API, Agent, Web, or bundle release with an asset
from another release.

## Upgrade API on Linux

Set only the API version selected from the API repository:

```bash
API_VERSION=X.Y.Z
curl -fLO "https://github.com/mqdeck/mqdeck-api/releases/download/v${API_VERSION}/mqdeck-api_${API_VERSION}_linux_amd64.tar.gz"
tar -xzf "mqdeck-api_${API_VERSION}_linux_amd64.tar.gz"
cd "mqdeck-api_${API_VERSION}_linux_amd64"
./mqdeck-api -version
sudo bash -c 'set -a; . /etc/mqdeck/api.env; set +a; MQDECK_INVENTORY_PATH=/etc/mqdeck/inventory.yaml ./mqdeck-api -validate'
sudo ./install-api.sh
curl --fail http://127.0.0.1:8080/healthz
```

The API installer replaces only the API binary and service definition.

## Upgrade Agents on Linux

Upgrade one network zone at a time and confirm that each Agent reconnects
before continuing:

```bash
AGENT_VERSION=X.Y.Z
curl -fLO "https://github.com/mqdeck/mqdeck-agent/releases/download/v${AGENT_VERSION}/mqdeck-agent_${AGENT_VERSION}_linux_amd64.tar.gz"
tar -xzf "mqdeck-agent_${AGENT_VERSION}_linux_amd64.tar.gz"
cd "mqdeck-agent_${AGENT_VERSION}_linux_amd64"
./mqdeck-agent -version
sudo bash -c 'set -a; . /etc/mqdeck/agent.env; set +a; ./mqdeck-agent -config /etc/mqdeck/agent.yaml -validate'
sudo ./install-agent.sh
sudo systemctl status mqdeck-agent --no-pager
sudo journalctl -u mqdeck-agent -n 50 --no-pager
```

An Agent upgrade does not require upgrading API or Web unless its release notes
explicitly identify a protocol compatibility requirement.

## Upgrade Web on Linux

```bash
WEB_VERSION=X.Y.Z
curl -fLO "https://github.com/mqdeck/mqdeck-web/releases/download/v${WEB_VERSION}/mqdeck-web_${WEB_VERSION}_standalone.tar.gz"
tar -xzf "mqdeck-web_${WEB_VERSION}_standalone.tar.gz"
cd "mqdeck-web_${WEB_VERSION}_standalone"
node --version
sudo ./install-web.sh
curl --fail http://127.0.0.1:3000/login
```

The Web installer preserves `/etc/mqdeck/web.env` and retains the replaced
application at `/opt/mqdeck/web.previous`.

## Windows Server

Use the same component-specific release links and independent variables:

```powershell
$ApiVersion = "X.Y.Z"
$AgentVersion = "X.Y.Z"
$WebVersion = "X.Y.Z"
```

Download and extract only the components being upgraded into new directories.
Run the corresponding `install-*-service.ps1` as Administrator, validate the
installed executable, and then start that service. Existing files under
`%ProgramData%\MQDeck` and machine-level `MQDECK_*` variables are preserved.

## Verification

Verify the component that changed, then run one end-to-end broker check:

1. API: confirm `/healthz` and the static inventory.
2. Agent: confirm presence in Agents, open a broker, and inspect its service
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
there is no requirement for API, Agent, and Web version numbers to match.
