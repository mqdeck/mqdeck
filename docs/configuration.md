# Configuration reference

## API

| Variable | Default | Purpose |
| --- | --- | --- |
| `MQDECK_API_ADDRESS` | `:8080` | HTTP and WebSocket listener |
| `MQDECK_INVENTORY_PATH` | `./inventory.yaml` | Static broker inventory |
| `MQDECK_AGENT_TOKEN` | required | Bearer token shared with Agents |
| `MQDECK_DIAGNOSTIC_TIMEOUT` | `45s` | Maximum correlated request duration |
| `MQDECK_CORS_ORIGINS` | `http://localhost:3000` | Allowed Web origins |

The inventory is one static, self-contained YAML file. List every IBM MQ queue
manager and RabbitMQ node that must appear in the overview, using final literal
values. The API does not expand environment variables and rejects `${...}`
placeholders. Protect the file with restricted filesystem permissions because
it contains the read-only broker credentials. Collection tests, transport,
timeouts, commands, and response limits are platform policy and are
therefore rejected if added to the inventory.

```yaml
version: 1
default_agent_id: network-zone-a
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
defaults to the queue-manager name), and `agent_id` is needed only to override
`default_agent_id` for that entry. Existing `default_agent` and `agent` keys
remain accepted as compatibility aliases.

`tags` is an optional list of short, literal identifiers such as `production`,
`payments`, or `mainframe`. Tags are returned by the API, displayed in the
inventory, and included in text search. `platform` accepts `distributed`
(default) or `zos` for IBM MQ.

### IBM MQ for z/OS and secure client connections

The Agent uses IBM MQ client mode (`runmqsc -c`) for both distributed and z/OS
queue managers. A direct mainframe connection needs only the listener endpoint,
queue-manager name, read-only `SVRCONN`, and credentials. For TLS or other
enterprise client policies, use a CCDT:

```yaml
version: 1
default_agent_id: mainframe-network-agent
hosts:
  - id: zos-payments
    name: Mainframe payments MQ
    adapter: ibmmq
    platform: zos
    tags: [production, mainframe, payments]
    ccdt_url: file:///etc/mqdeck/zos-payments-ccdt.json
    queue_manager: CSQ1
    channel: MQDECK.READONLY
    credentials:
      username: MQDECK
      password: replace-with-the-read-only-password
    tls:
      key_repository: /etc/mqdeck/tls/mqdeck
```

The CCDT file and key repository must exist on the selected Agent. For a GSKit
repository, `key_repository` can omit the `.kdb` suffix. `endpoint` and
`ccdt_url` are mutually exclusive so the active connection path remains clear.
The Agent removes inherited IBM MQ connection variables and sets `MQCCDTURL`
and optional `MQSSLKEYR` only for the read-only command process.

The API derives `client` transport and the complete read-only IBM MQ view, or
HTTP transport and the complete RabbitMQ view. The direct endpoint host is used
as the machine label, so several queue managers can share a machine without
repeating metadata in YAML. CCDT entries are labeled `CCDT`. Cluster and
repository roles are read live from IBM MQ.

For IBM MQ, the configured `channel` is also returned as the access channel in
every report. Object inventories are authority-scoped: missing channels,
queues, or listeners may indicate insufficient `DISPLAY`/`INQUIRE` authority
rather than absence. MQDeck reports recognized authorization failures as a
partial-visibility warning. System queues are included in the queue view by
default.

## Agent

When API, Agent, and Web are installed on the same machine, the component
packages use the following local communication defaults:

| Connection | Default |
| --- | --- |
| Web to API | `http://127.0.0.1:8080` |
| Agent to API | `http://127.0.0.1:8080` |
| Browser to Web | `http://127.0.0.1:3000` |

Only replace these addresses when a component runs on another machine. Broker
addresses remain those declared in `inventory.yaml`; they are not assumed to
be local.

```yaml
version: 1
agent:
  id: network-zone-a
  name: Agent Sao Paulo
  location: sa-east-1
  timezone: America/Sao_Paulo
  max_concurrency: 4
control_plane:
  url: ${MQDECK_API_URL}
  token: ${MQDECK_AGENT_TOKEN}
  reconnect_delay: 5s
  insecure_skip_verify: false
```

`agent.id` is the stable routing key. `agent.name` is the friendly name shown
in the control panel. Use TLS in every non-local deployment.

## Web

| Variable | Purpose |
| --- | --- |
| `MQDECK_API_URL` | API base URL; defaults to `http://127.0.0.1:8080` in the service package |
| `MQDECK_AUTH_USERNAME` | Static operator username |
| `MQDECK_AUTH_PASSWORD` | Static operator password |
| `MQDECK_AUTH_DISPLAY_NAME` | Display name |
| `MQDECK_AUTH_SESSION_SECRET` | Signed session secret |

There are no Elasticsearch, storage-mode, schedule, or Test Flight settings.
