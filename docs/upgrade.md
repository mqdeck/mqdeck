# Upgrade and rollback

Back up `inventory.yaml`, Agent YAML files, and Web authentication settings.
Validate the new binaries before switching services:

```bash
mqdeck-api -validate
mqdeck-agent -config /etc/mqdeck/agent.yaml -validate
```

Upgrade API, then Agents, then Web. Replace only that component's files and use
its operating-system service manager:

```bash
sudo systemctl restart mqdeck-api
sudo systemctl restart mqdeck-agent
sudo systemctl restart mqdeck-web
```

Agents reconnect automatically. Existing observations need no migration because
they are not persisted.

Rollback one component by restoring its previous package and configuration,
then restarting only its service.
