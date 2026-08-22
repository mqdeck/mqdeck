# Configuration

MQDeck keeps deployment-specific endpoints and secrets outside binaries and
container images.

## Agent

The agent reads a YAML file, `mqdeck.yaml` by default. Environment-variable
references are expanded before strict decoding.

The main sections are:

| Section | Purpose |
| --- | --- |
| `agent` | Agent identity, timezone, startup behavior, and global concurrency |
| `storage` | Selects Elasticsearch or the bounded single-machine local file |
| `elasticsearch` | Storage URL, index names, credentials, and timeout |
| `test_runner` | Optional authenticated Test Flight listener and IBM MQ client settings |
| `hosts` | Broker, adapter, transport, endpoint, schedule, tests, and limits |

Each host can define:

- a standard five-field cron expression, an optional seconds field, or a
  descriptor such as `@every 30s`;
- frequent `tests` and slower `detail_tests`;
- `capture.detail_interval` and `capture.max_response_bytes`;
- HTTP, IBM MQ client, or local executable credentials and configuration;
- adapter-specific custom checks that still pass the adapter's read-only
  validation;
- labels for topology and report behavior.

For IBM MQ, use `transport: client` (the default when transport is omitted) to
run bounded read-only `runmqsc -c` commands through a `SVRCONN` channel. Set
`endpoint` to `host:port`, provide `queue_manager` and `channel`, and install the
IBM MQ client on the Agent host. This path works when `mqweb`, Administrative
REST, and Messaging REST are disabled. A comma-separated endpoint provides
multiple IBM MQ connection names.

Use `transport: command` only when running local `runmqsc` against a queue
manager on the same host. The legacy `transport: rest` remains supported.
With `transport: client`, Test Flight uses `dmpmqmsg` over `SVRCONN` for the
exact-correlation put/get and `runmqsc` for optional channel-state or
dead-letter depth observations. Neither IBM MQ web endpoint is required. Set
`test_runner.channel` when the active test credential must use a different
application channel from the read-only collection identity. The legacy
`transport: rest` keeps using `messaging_endpoint` and `admin_endpoint`, with
`endpoint` as its fallback.

Start with the public [`examples/agent.yaml`](../examples/agent.yaml) and adapt
its bounded capture, scheduling, and Elasticsearch settings to each broker.
For IBM MQ client preparation, including the required `runmqsc` and
`dmpmqmsg` tools, use
[`examples/ibmmq-svrconn.md`](../examples/ibmmq-svrconn.md). For Test Flight
without Administrative REST, use
[`examples/test-flight-ibmmq-no-admin-rest.yaml`](../examples/test-flight-ibmmq-no-admin-rest.yaml)
with a client-transport host and a dedicated `MQDECK.*` test queue.
Validate every change with
`mqdeck-agent -config agent.yaml -validate`.

For local demonstrations, `storage.mode: local` selects the shared file and
the Elasticsearch section is ignored. See [Local file mode](local-mode.md) for
the complete three-component configuration and limitations.

### Six hour Elasticsearch retention

The agent enables retention by default and will not write a document until it
has created or updated the configured ILM policy and index template. The
default policy permanently deletes MQDeck agent presence, host snapshots, and
collected data after six hours. Because Elasticsearch executes the policy,
expiration continues after all MQDeck processes stop.

```yaml
elasticsearch:
  url: ${MQDECK_ELASTICSEARCH_URL}
  agents_index: mqdeck-agents
  hosts_index: mqdeck-hosts
  data_index: mqdeck-data
  retention:
    enabled: true
    duration: 6h
    policy_name: mqdeck-retention-6h
```

The Elasticsearch bootstrap identity requires `manage_ilm` and
`manage_index_templates` cluster privileges, plus `manage` and write access to
the MQDeck index patterns. When a platform team manages retention centrally,
set `retention.enabled: false` only after an equivalent external policy has
been applied.

## API

| Variable | Default |
| --- | --- |
| `MQDECK_API_ADDRESS` | `:8080` |
| `MQDECK_STORAGE_MODE` | `elasticsearch` |
| `MQDECK_LOCAL_DATA_PATH` | `./mqdeck-local-data.json` |
| `MQDECK_LOCAL_MAX_FILE_BYTES` | `67108864` |
| `MQDECK_LOCAL_RETENTION` | `6h` |
| `MQDECK_ELASTICSEARCH_URL` | `http://localhost:9200` |
| `MQDECK_HOSTS_INDEX` | `mqdeck-hosts` |
| `MQDECK_DATA_INDEX` | `mqdeck-data` |
| `MQDECK_ELASTICSEARCH_TIMEOUT` | `10s` |
| `MQDECK_CORS_ORIGINS` | `http://localhost:3000` |
| `MQDECK_ELASTICSEARCH_USERNAME` | empty |
| `MQDECK_ELASTICSEARCH_PASSWORD` | empty |
| `MQDECK_ELASTICSEARCH_API_KEY` | empty |

Use a least-privilege Elasticsearch identity that can read only `mqdeck-hosts`
and `mqdeck-data`.

## Web interface

`MQDECK_API_URL` configures the server-side API target and defaults to
`http://localhost:8080`. The browser calls only same-origin proxy routes.

Set `MQDECK_STORAGE_MODE=local` when API and Agent use local file mode. Web
still communicates only with API and never reads the file directly.

`MQDECK_TEST_RUNNER_URL` and `MQDECK_TEST_RUNNER_TOKEN` enable real Test Flight
requests through a selected Agent. Leave both unset when Test Flight is not
used.

The Web login uses one static operator account configured only on the server:

| Variable | Development default | Purpose |
| --- | --- | --- |
| `MQDECK_AUTH_USERNAME` | `admin` | Login username |
| `MQDECK_AUTH_PASSWORD` | `mqdeck-demo` | Login password |
| `MQDECK_AUTH_DISPLAY_NAME` | `MQDeck Operator` | Name displayed in the top bar |
| `MQDECK_AUTH_SESSION_SECRET` | development-only value | Signs the eight-hour HTTP-only session cookie |

Set a strong password and a long random session secret in every non-development
installation. Web proxy routes reject unauthenticated requests with HTTP 401.

## Production guidance

- Store secrets in the deployment platform's secret manager and inject them as
  environment variables.
- Require certificate verification and trusted certificates for broker and
  Elasticsearch connections.
- Give the agent only the broker inspection permissions required by configured
  checks.
- Give the agent write access only to MQDeck indices and the API read access
  only to those indices.
- Restrict network paths between brokers, agents, Elasticsearch, the API, and
  the web application.
- Define retention and access policies for collected data before enabling collection.
