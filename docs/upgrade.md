# Upgrade and rollback

Back up `inventory.yaml`, Agent YAML files, and Web authentication settings.
Validate the new binaries before switching services:

```bash
mqdeck-api -validate
mqdeck-agent -config /etc/mqdeck/agent.yaml -validate
```

Upgrade API, then Agents, then Web. Agents reconnect automatically. Existing
diagnostic results need no migration because they are not persisted.

Rollback by restoring the previous binaries and matching configuration files.
