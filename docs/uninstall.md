# Remove MQDeck

Remove components in reverse installation order: Agent, Web, and API. MQDeck
never removes Elasticsearch or broker data outside its configured indices.

## Linux packages

Every Linux artifact includes `uninstall.sh`. By default it removes the service
and installed application files while retaining configuration under
`/etc/mqdeck`:

```bash
sudo ./uninstall.sh
```

Use `--purge` only when the component configuration must also be permanently
removed:

```bash
sudo ./uninstall.sh --purge
```

The scripts remove only their own component paths:

| Component | Application path | Preserved configuration |
| --- | --- | --- |
| Agent | `/opt/mqdeck/agent` | `/etc/mqdeck/agent.yaml`, `/etc/mqdeck/agent.env` |
| API | `/opt/mqdeck/api` | `/etc/mqdeck/api.env` |
| Web | `/opt/mqdeck/web` | `/etc/mqdeck/web.env` |

The shared `mqdeck` operating-system account is retained because another
MQDeck component may still use it.

## Windows packages

Run the relevant script from an elevated PowerShell prompt. Safe removal keeps
binaries and configuration:

```powershell
.\uninstall-agent-service.ps1
.\uninstall-api-service.ps1
```

Explicitly remove Agent binaries or configuration when required:

```powershell
.\uninstall-agent-service.ps1 -PurgeBinaries
.\uninstall-agent-service.ps1 -PurgeBinaries -PurgeConfiguration
.\uninstall-api-service.ps1 -PurgeBinaries
```

Machine-level environment variables are intentionally retained and must be
reviewed separately by the administrator.

## Helm

```bash
helm uninstall mqdeck --namespace mqdeck
```

This removes Kubernetes resources created by the release. It does not remove
the external Elasticsearch deployment or MQDeck indices. Review those indices
and their retention policy separately.
