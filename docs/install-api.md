# Install API

Install the `mqdeck-api` binary and the complete, reviewed inventory file on
the same host. The inventory must contain every broker entry and final literal
connection value; it is not a template and receives no environment expansion.

```bash
install -m 0755 mqdeck-api /usr/local/bin/mqdeck-api
install -d -m 0750 /etc/mqdeck
install -m 0640 inventory.yaml /etc/mqdeck/inventory.yaml
```

Configure `MQDECK_INVENTORY_PATH`, `MQDECK_AGENT_TOKEN`, and optionally
`MQDECK_DIAGNOSTIC_TIMEOUT`. Run `mqdeck-api -validate` before every restart.
The API listener must support WebSocket upgrades at `/api/v1/agents/connect`.

The API does not require a database or Elasticsearch.
