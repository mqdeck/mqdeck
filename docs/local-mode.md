# Local file mode

Local file mode runs MQDeck Agent, API, and Web on one machine without
Elasticsearch. It is intended for demonstrations, short experiments, and
proofs of concept. Production and distributed installations should use
Elasticsearch.

## Data flow

1. The Agent collects read-only broker observations.
2. The Agent writes a bounded JSON data file using an interprocess lock and
   atomic replacement.
3. The API reads that same file without modifying it.
4. Web continues to communicate only with the API.

Use one local Agent and a local filesystem. Network filesystems, multiple Agent
writers, shared container replicas, and Kubernetes deployments are not
supported in this mode.

## Shared location

Create one directory that the `mqdeck` service account can access:

```bash
sudo install -d -o mqdeck -g mqdeck -m 0750 /var/lib/mqdeck
```

The Linux installers create this directory automatically. The examples below
use `/var/lib/mqdeck/mqdeck-local-data.json`.

## 1. Configure API

Edit `/etc/mqdeck/api.env`:

```properties
MQDECK_STORAGE_MODE=local
MQDECK_LOCAL_DATA_PATH=/var/lib/mqdeck/mqdeck-local-data.json
MQDECK_LOCAL_MAX_FILE_BYTES=67108864
MQDECK_LOCAL_RETENTION=6h
```

The Elasticsearch URL and credentials are ignored in local mode. Start or
restart the API after saving the file.

## 2. Configure Web

Edit `/etc/mqdeck/web.env`:

```properties
MQDECK_STORAGE_MODE=local
MQDECK_API_URL=http://127.0.0.1:8080
```

Web never opens the shared file and never connects to Elasticsearch. The mode
property keeps the three component configurations explicit and consistent.

## 3. Configure Agent last

Edit `/etc/mqdeck/agent.env`:

```properties
MQDECK_STORAGE_MODE=local
MQDECK_LOCAL_DATA_PATH=/var/lib/mqdeck/mqdeck-local-data.json
MQDECK_LOCAL_RETENTION=6h
```

Ensure `/etc/mqdeck/agent.yaml` contains:

```yaml
storage:
  mode: ${MQDECK_STORAGE_MODE}
  local_path: ${MQDECK_LOCAL_DATA_PATH}
  retention: ${MQDECK_LOCAL_RETENTION}
  max_records: 10000
  max_file_bytes: 67108864
```

Validate and start the Agent:

```bash
sudo -u mqdeck /opt/mqdeck/agent/mqdeck-agent \
  -config /etc/mqdeck/agent.yaml -validate
sudo systemctl enable --now mqdeck-agent
```

## Verify

```bash
curl --fail http://127.0.0.1:8080/healthz
curl --fail http://127.0.0.1:8080/api/v1/agents
curl --fail http://127.0.0.1:8080/api/v1/hosts
sudo stat /var/lib/mqdeck/mqdeck-local-data.json
```

The Agent removes expired records during writes. The API also stops serving
records older than the configured retention window without writing to the
file. Record count and file size limits prevent unbounded local growth.

## Return to Elasticsearch

Stop the Agent first so that the storage destination cannot change during a
collection:

```bash
sudo systemctl stop mqdeck-agent
```

Set `MQDECK_STORAGE_MODE=elasticsearch` in the Agent, API, and Web properties.
Configure the Elasticsearch URL and credentials, then restart in this order:

```bash
sudo systemctl restart mqdeck-api
sudo systemctl restart mqdeck-web
sudo systemctl start mqdeck-agent
```

The local file is not imported into Elasticsearch automatically. Remove it
only after confirming that it is no longer needed:

```bash
sudo rm /var/lib/mqdeck/mqdeck-local-data.json
```
