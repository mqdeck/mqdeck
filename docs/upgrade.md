# Upgrade and rollback

Upgrade components in the same order used for installation: API, Web, and
Agent last. Download every artifact from one release version and verify it
against that release's `SHA256SUMS` file.

## Linux packages

The included `install.sh` is also the upgrade installer. It detects an active
service, stops it before replacing files, preserves `/etc/mqdeck`, and restarts
the service only when it was already active.

For each component:

1. Download and verify the new artifact.
2. Back up `/etc/mqdeck` and keep the previous artifact.
3. Extract the new package.
4. Run `sudo ./install.sh` from the extracted directory.
5. Verify the component before upgrading the next one.

Upgrade API first:

```bash
sudo ./install.sh
/opt/mqdeck/api/mqdeck-api -version
curl --fail http://127.0.0.1:8080/healthz
```

Upgrade Web second. Node.js 20.20 or newer is required. The installer retains
the previous application directory at `/opt/mqdeck/web.previous`:

```bash
node --version
sudo ./install.sh
curl --fail http://127.0.0.1:3000/
```

Upgrade Agent last:

```bash
sudo ./install.sh
/opt/mqdeck/agent/mqdeck-agent -version
sudo -u mqdeck /opt/mqdeck/agent/mqdeck-agent \
  -config /etc/mqdeck/agent.yaml -validate
sudo systemctl status mqdeck-agent
```

Configuration examples inside a new artifact are not copied over existing
configuration. Compare them manually when release notes introduce new options.

## Windows packages

Extract the new ZIP to a temporary directory and rerun the relevant installer
from an elevated PowerShell prompt:

```powershell
.\install-api-service.ps1
.\install-agent-service.ps1
```

The scripts stop an existing service before replacing its executable and then
start it again. Agent configuration under `C:\ProgramData\MQDeck` is preserved.

Verify the installed versions:

```powershell
& "$env:ProgramFiles\MQDeck\API\mqdeck-api.exe" -version
& "$env:ProgramFiles\MQDeck\Agent\mqdeck-agent.exe" -version
Get-Service MQDeckAPI, MQDeckAgent
```

## Binary rollback

Stop the affected service, run the previous release installer, and start the
service again. For Web, `/opt/mqdeck/web.previous` contains the immediately
preceding application directory, but using the previous signed artifact is the
recommended repeatable rollback method.

## Helm installations

Review the proposed change:

```bash
helm template mqdeck ./mqdeck-NEW_VERSION.tgz -f production-values.yaml
helm upgrade mqdeck ./mqdeck-NEW_VERSION.tgz \
  --namespace mqdeck --reuse-values --atomic --timeout 10m
```

List revisions and roll back:

```bash
helm history mqdeck --namespace mqdeck
helm rollback mqdeck REVISION --namespace mqdeck --wait
```

Always pin explicit image and chart versions. Configuration compatibility and
known changes are documented in each GitHub release.

See [Remove MQDeck](uninstall.md) for safe removal and optional configuration
purging.
