# Configuration reference

## API

| Variable | Default | Purpose |
| --- | --- | --- |
| `MQDECK_API_ADDRESS` | `:8080` | HTTP and WebSocket listener |
| `MQDECK_INVENTORY_PATH` | `./inventory.yaml` | Static broker inventory |
| `MQDECK_WORKER_TOKEN` | required | Bearer token shared with Workers |
| `MQDECK_DIAGNOSTIC_TIMEOUT` | `90s` | Maximum time the API waits for a Worker collect; raise for slow queue managers |
| `MQDECK_CORS_ORIGINS` | `http://localhost:3000` | Allowed Web origins |
| `MQDECK_QUEUE_WATCH_INTERVAL` | `5s` | Delay between shared queue-depth samples; allowed range is `1s` to `1m` |
| `MQDECK_QUEUE_WATCH_MAX_DURATION` | `10m` | Maximum duration of one browser watch session; allowed range is `1m` to `1h` |
| `MQDECK_QUEUE_WATCH_MAX_SAMPLERS` | `32` | Maximum distinct queue samplers per API instance |
| `MQDECK_QUEUE_WATCH_MAX_PER_WORKER` | `8` | Maximum distinct samplers routed through one Worker |
| `MQDECK_QUEUE_WATCH_MAX_PER_QUEUE_MANAGER` | `4` | Maximum distinct watched queues for one inventory host |
| `MQDECK_QUEUE_WATCH_MAX_CLIENTS` | `64` | Maximum simultaneous browser watch streams |
| `MQDECK_LLM_ENABLED` | `auto` | Optional local assistant: `auto`, `true`, or `false` |
| `MQDECK_MODEL_DIR` | `./models` | Directory of optional GGUF models |

The assistant is off unless you add a model. Setup, `llama-server`, and an
external OpenAI-compatible endpoint are covered in
[Local assistant and models](llm.md).

On Linux the API reads `/etc/mqdeck/api.properties`. Write each setting in dotted form, so `MQDECK_API_ADDRESS` becomes `mqdeck.api.address=:8080`. A container or a Windows service uses the environment variable `MQDECK_API_ADDRESS`. When both are present, the environment variable wins.

Opening the Queues tab uses
`DISPLAY QSTATUS(*) TYPE(QUEUE) CURDEPTH IPPROCS OPPROCS`. Expanding one local
IBM MQ queue performs one exact-name inquiry and does not start polling. The API
caches this detail for three seconds and coalesces simultaneous requests.

Queue Watch starts only after **Start watch** on an expanded IBM MQ queue.
Clients for the same Worker, inventory host, and queue share one sampler. Queue
detail and each watch sample use
`DISPLAY QSTATUS(name) TYPE(QUEUE) CURDEPTH IPPROCS OPPROCS MONQ LPUTDATE LPUTTIME LGETDATE LGETTIME MSGAGE`.
MQDeck does not turn `MONQ` or `STATQ` on. The UI reports `MONQ OFF` separately
from no observed put or destructive get since queue-manager start.
The default five-second interval is for a short diagnosis, not a permanent
collector. Use a one-second interval only for a brief troubleshooting session.

The inventory is one static, self-contained YAML file. List every IBM MQ queue
manager and RabbitMQ node that must appear in the overview, using final literal
values. The API does not expand environment variables and rejects `${...}`
placeholders. Protect the file with restricted filesystem permissions because
it contains the read-only broker credentials. Collection tests, transport,
timeouts, commands, and response limits are platform policy and are
therefore rejected if added to the inventory.

```yaml
version: 1
default_worker_id: network-zone-a
hosts:
  - id: payments-qm
    adapter: ibmmq
    platform: distributed
    tags: [production, payments]
    endpoint: mq01.example.net(1414)
    queue_manager: QM01
    channel: MQDECK.READONLY
    credentials:
      username: mqdeck_readonly
      password: replace-with-the-read-only-password
```

`id` and `adapter` are always required. IBM MQ also requires `queue_manager`,
`channel`, and either a direct `endpoint` or `ccdt_url`. `credentials` is
needed when the broker requires authentication. `name` is optional (IBM MQ
defaults to the queue-manager name), and `worker_id` is needed only to override
`default_worker_id` for that entry. Existing `default_worker` and `worker` keys
remain accepted as compatibility aliases.

`tags` is an optional list of short, literal identifiers such as `production`,
`payments`, or `mainframe`. Tags are returned by the API, displayed in the
inventory, and included in text search. `platform` accepts `distributed`
(default) or `zos` for IBM MQ.

### IBM MQ for z/OS and secure client connections

The Worker uses IBM MQ client mode (`runmqsc -c`) for both distributed and z/OS
queue managers. A direct mainframe connection needs only the listener endpoint,
queue-manager name, and a generic read-only `SVRCONN`. Credentials are optional
when CHLAUTH/MCAUSER maps the Worker without MQCSP authentication:

```yaml
version: 1
default_worker_id: mainframe-network-worker
hosts:
  - id: zos-payments
    name: Mainframe payments MQ
    adapter: ibmmq
    platform: zos
    tags: [production, mainframe, payments]
    endpoint: mainframe.example.net(1414)
    queue_manager: CSQ1
    channel: MQDECK.READONLY
    credentials:
      username: MQDECK
      password: replace-with-the-read-only-password
```

This direct mode sets `MQSERVER` only for the bounded `runmqsc -c` process and
does not require a CCDT. MQDeck does not query z/OS listener objects because
those listeners are managed by CHINIT; it collects queue-manager, queue, and
channel definitions and status.

Use `ccdt_url` instead of `endpoint` only if the `SVRCONN` requires TLS, channel
exits, or a managed connection list. The CCDT file and key repository must
exist on the selected Worker. For a GSKit
repository, `key_repository` can omit the `.kdb` suffix. `endpoint` and
`ccdt_url` are mutually exclusive so the active connection path remains clear.
The Worker removes inherited IBM MQ connection variables and sets `MQCCDTURL`
and optional `MQSSLKEYR` only for the read-only command process.

The API applies IBM MQ client mode. Overview collects queue-manager status.
Queues and Channels collect those objects when the operator opens the tab.
Distributed queue managers also collect listener status; z/OS does not, because
those listeners belong to CHINIT. RabbitMQ uses the Management API. The direct
endpoint host is used as the machine label, so several queue managers can share a machine without
repeating metadata in YAML. CCDT entries are labeled `CCDT`. Cluster and
repository roles are read live from IBM MQ.

For IBM MQ, the configured `channel` is also returned as the access channel in
every report. Object inventories are authority-scoped: missing channels or
queues may indicate insufficient `DISPLAY`/`INQUIRE` authority rather than
absence. MQDeck reports recognized authorization failures as a
partial-visibility warning. System queues are included in the queue view by
default.

## Worker

When API, Worker, and Web are installed on the same machine, the component
packages use the following local communication defaults:

| Connection | Default |
| --- | --- |
| Web to API | `http://127.0.0.1:8080` |
| Worker to API | `http://127.0.0.1:8080` |
| Browser to Web | `http://127.0.0.1:3000` |

Only replace these addresses when a component runs on another machine. Broker
addresses remain those declared in `inventory.yaml`; they are not assumed to
be local.

```properties
mqdeck.worker.id=network-zone-a
mqdeck.worker.name=Worker Sao Paulo
mqdeck.worker.location=sa-east-1
mqdeck.worker.timezone=America/Sao_Paulo
mqdeck.worker.max.concurrency=4
mqdeck.worker.command.timeout=60s
mqdeck.worker.ibmmq.client=/opt/mqm/bin
mqdeck.api.url=http://127.0.0.1:8080
mqdeck.worker.token=replace-with-the-same-api-token
mqdeck.worker.reconnect.delay=5s
mqdeck.worker.insecure.skip.verify=false
```

`mqdeck.worker.id` is the stable routing key. `mqdeck.worker.name` is the friendly name shown
in the control panel. `mqdeck.worker.ibmmq.client` is the IBM MQ client bin directory. The default is `/opt/mqm/bin`. The Worker runs `runmqsc`, `dmpmqmsg`, and the other client utilities from that directory. `mqdeck.worker.command.timeout` is a local floor for each on-demand broker
collect when the queue manager is slow to answer; keep it at or below
`mqdeck.diagnostic.timeout` on the API so the control plane can still return a
clear timeout message. Use TLS in every non-local deployment.

On Linux the Worker reads `/etc/mqdeck/worker.properties`. A container sets `MQDECK_WORKER_ID`, `MQDECK_API_URL`, and `MQDECK_WORKER_TOKEN`. When a property and an environment variable are both present, the environment variable wins.

## Web

| Variable | Purpose |
| --- | --- |
| `MQDECK_WEB_PORT` | Listen port. The properties key is `mqdeck.web.port`. Default is `3000` |
| `MQDECK_API_URL` | API base URL; defaults to `http://127.0.0.1:8080` in the service package |
| `MQDECK_AUTH_USERNAME` | Static operator username |
| `MQDECK_AUTH_PASSWORD` | Static operator password |
| `MQDECK_AUTH_DISPLAY_NAME` | Display name |
| `MQDECK_AUTH_SESSION_SECRET` | Signed session secret |

On Linux, write these in `/etc/mqdeck/web.properties`. `mqdeck.web.port=3000` is the listen port. A container sets `PORT` or `MQDECK_WEB_PORT`. When both a property and an environment variable are present, the environment variable wins. An explicit `PORT` is the listen port.

There are no Elasticsearch, storage-mode, schedule, or Test Flight settings.
Assistant settings belong on the API, not on Web or the Worker. See
[Local assistant and models](llm.md).
