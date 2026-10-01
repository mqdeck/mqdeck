# Local development mode

Local development is the normal lightweight architecture, not a separate
storage mode. From the workspace root:

```bash
./start.sh
```

The launcher starts RabbitMQ and IBM MQ without Elasticsearch, then API, Agent,
and Web. It uses `mqdeck-api/inventory.local.yaml` and runs the complete
verification script automatically. Set `MQDECK_START_SIMULATOR=true` to add
message traffic.

```bash
./stop.sh
```

No observation file or database is created.
