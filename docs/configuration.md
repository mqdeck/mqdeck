# Configuration reference

## API

| Variable | Default | Purpose |
| --- | --- | --- |
| `MQDECK_API_ADDRESS` | `:8080` | HTTP and WebSocket listener |
| `MQDECK_INVENTORY_PATH` | `./inventory.yaml` | Static broker inventory |
| `MQDECK_AGENT_TOKEN` | required | Bearer token shared with Agents |
| `MQDECK_DIAGNOSTIC_TIMEOUT` | `90s` | Maximum time the API waits for an Agent collect; raise for slow queue managers |
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
queue-manager name, and a generic read-only `SVRCONN`. Credentials are optional
when CHLAUTH/MCAUSER maps the Agent without MQCSP authentication:

```yaml
version: 1
default_agent_id: mainframe-network-agent
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
exist on the selected Agent. For a GSKit
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
  command_timeout: 60s
control_plane:
  url: ${MQDECK_API_URL}
  token: ${MQDECK_AGENT_TOKEN}
  reconnect_delay: 5s
  insecure_skip_verify: false
```

`agent.id` is the stable routing key. `agent.name` is the friendly name shown
in the control panel. `agent.command_timeout` (or env
`MQDECK_AGENT_COMMAND_TIMEOUT`) is a local floor for each on-demand broker
collect when the queue manager is slow to answer; keep it at or below
`MQDECK_DIAGNOSTIC_TIMEOUT` on the API so the control plane can still return a
clear timeout message. Use TLS in every non-local deployment.

## Web

| Variable | Purpose |
| --- | --- |
| `MQDECK_API_URL` | API base URL; defaults to `http://127.0.0.1:8080` in the service package |
| `MQDECK_AUTH_USERNAME` | Static operator username |
| `MQDECK_AUTH_PASSWORD` | Static operator password |
| `MQDECK_AUTH_DISPLAY_NAME` | Display name |
| `MQDECK_AUTH_SESSION_SECRET` | Signed session secret |

There are no Elasticsearch, storage-mode, schedule, or Test Flight settings.
