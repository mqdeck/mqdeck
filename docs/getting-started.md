# Getting started

This guide starts the complete MQDeck development topology: Elasticsearch, a
three-node RabbitMQ cluster, four IBM MQ queue managers, the collection agent,
the read-only API, and the web interface.

## Requirements

- Docker Desktop or Docker Engine with Docker Compose v2
- Go 1.25 or newer
- Node.js 22.13 or newer
- `curl` and `jq` for verification and the message simulator
- At least 10 GB of memory allocated to Docker is recommended

On Apple Silicon, Docker must support `linux/amd64` emulation because the IBM MQ
developer image used by the local environment does not publish an `arm64`
variant.

## Clone the repositories

The development scripts use sibling repository paths:

```text
mqdeck-workspace/
├── mqdeck-agent/
├── mqdeck-api/
├── mqdeck-local/
└── mqdeck-web/
```

Create that layout:

```bash
mkdir mqdeck-workspace
cd mqdeck-workspace
git clone https://github.com/mqdeck/mqdeck-agent.git
git clone https://github.com/mqdeck/mqdeck-api.git
git clone https://github.com/mqdeck/mqdeck-local.git
git clone https://github.com/mqdeck/mqdeck-web.git
```

The agent vendors the adapter modules, so cloning the adapter repositories is
only necessary when developing an adapter.

## Start the platform

From `mqdeck-local`, start the infrastructure:

```bash
make up
```

On the first run, the script creates an ignored `.env` from `.env.example`.
The included passwords are intentionally limited to local development. Replace
them before allowing access from another machine.

Wait for the infrastructure to become healthy, then start the application
processes in another terminal:

```bash
cd mqdeck-workspace/mqdeck-local
make dev
```

Open <http://localhost:3000> and run the end-to-end verification:

```bash
make verify
```

The supporting endpoints are:

| Service | Local endpoint |
| --- | --- |
| MQDeck web | <http://localhost:3000> |
| MQDeck API | <http://localhost:8080> |
| Elasticsearch | <http://localhost:9200> |
| RabbitMQ management, node 1 | <http://localhost:15672> |
| IBM MQ console, queue manager 1A | <https://localhost:9443> |

Additional broker ports are documented in the
[`mqdeck-local` README](https://github.com/mqdeck/mqdeck-local#endpoints).

## Generate message traffic

The local environment includes producers and consumers that generate queue
accumulation and drain cycles across both broker types:

```bash
make simulate-start
make simulate-status
make simulate-logs
```

Stop the workers without deleting queued messages:

```bash
make simulate-stop
```

## Stop or reset

Stop containers while retaining broker data:

```bash
make down
```

Delete the local containers and their persistent broker data:

```bash
make reset
```

`make reset` is destructive and is intended only for the disposable local
environment.

## Common issues

- **IBM MQ takes several minutes to become healthy:** this is expected on
  Apple Silicon because the containers run through CPU emulation.
- **The application repositories are not found:** confirm that `mqdeck-agent`,
  `mqdeck-api`, `mqdeck-web`, and `mqdeck-local` share the same parent directory.
- **A port is already in use:** edit the corresponding value in the ignored
  `mqdeck-local/.env` file and restart the environment.
- **The web interface has no hosts:** confirm that the agent is running, then
  check `make verify` and the application output from `make dev`.
