# Configuration

MQDeck keeps deployment-specific endpoints and secrets outside source code.
The following overview links each configuration surface to its authoritative
repository.

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

See the versioned
[`mqdeck.yaml`](https://github.com/mqdeck/mqdeck-agent/blob/main/mqdeck.yaml) for
a complete multi-broker example.

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

## Local environment

`mqdeck-local/.env.example` pins the development image versions, host ports,
and disposable local credentials. `make up` copies it to the ignored `.env`
file on first use.

The example IBM MQ settings accept the developer image license and the local
agent disables TLS verification for the self-signed development endpoints.
Review the IBM license and replace these settings for any non-local deployment.

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
