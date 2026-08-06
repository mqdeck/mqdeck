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
| `elasticsearch` | Storage URL, index names, credentials, and timeout |
| `hosts` | Broker, adapter, transport, endpoint, schedule, tests, and limits |

Each host can define:

- a standard five-field cron expression, an optional seconds field, or a
  descriptor such as `@every 30s`;
- frequent `tests` and slower `detail_tests`;
- `capture.detail_interval` and `capture.max_response_bytes`;
- HTTP/REST credentials or a local executable configuration;
- adapter-specific custom checks that still pass the adapter's read-only
  validation;
- labels for topology and report behavior.

For IBM MQ, Administrative REST is optional when the Agent runs beside the
queue manager. Use `transport: command` for bounded read-only `runmqsc DISPLAY`
collection and set `messaging_endpoint` only if Test Flight should use Messaging
REST v3. Set `admin_endpoint` only when optional channel-state or dead-letter
depth assertions are required. Existing `transport: rest` configurations keep
using `endpoint` as the backward-compatible default for both REST surfaces.

Start with the public [`examples/agent.yaml`](../examples/agent.yaml) and adapt
its bounded capture, scheduling, and Elasticsearch settings to each broker.
For IBM MQ Test Flight without Administrative REST, use
[`examples/test-flight-ibmmq-no-admin-rest.yaml`](../examples/test-flight-ibmmq-no-admin-rest.yaml)
with a command-transport host that defines `messaging_endpoint`. Validate every
change with
`mqdeck-agent -config agent.yaml -validate`.

## API

| Variable | Default |
| --- | --- |
| `MQDECK_API_ADDRESS` | `:8080` |
| `MQDECK_ELASTICSEARCH_URL` | `http://localhost:9200` |
| `MQDECK_HOSTS_INDEX` | `mqdeck-hosts` |
| `MQDECK_EVIDENCE_INDEX_PREFIX` | `mqdeck-evidence` |
| `MQDECK_ELASTICSEARCH_TIMEOUT` | `10s` |
| `MQDECK_CORS_ORIGINS` | `http://localhost:3000` |
| `MQDECK_ELASTICSEARCH_USERNAME` | empty |
| `MQDECK_ELASTICSEARCH_PASSWORD` | empty |
| `MQDECK_ELASTICSEARCH_API_KEY` | empty |

Use a least-privilege Elasticsearch identity that can read only the MQDeck host
and evidence indices.

## Web interface

`MQDECK_API_URL` configures the server-side API target and defaults to
`http://localhost:8080`. The browser calls only same-origin proxy routes.

`MQDECK_TEST_RUNNER_URL` and `MQDECK_TEST_RUNNER_TOKEN` enable real Test Flight
requests through a selected Agent. Leave both unset when Test Flight is not
used.

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
- Define retention and access policies for evidence before enabling collection.
