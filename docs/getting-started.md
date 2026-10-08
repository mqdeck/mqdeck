# Getting started

MQDeck lets you look at an IBM MQ queue manager or a RabbitMQ node when you
ask, and stays quiet the rest of the time. The inventory is a local file. A
connected Agent, placed in the broker network, runs the read-only check and
returns the result. Nothing is stored after the page responds.

You install three small services. They do not need Elasticsearch, a scheduler,
or a telemetry database.

## How a request moves

This is the same picture as the repository README.

```mermaid
flowchart LR
    YAML["Local inventory.yaml"] --> API["MQDeck API"]
    WEB["MQDeck Web"] -->|"inventory, report, and queue-watch SSE"| API
    AGENT["MQDeck Agent"] -->|"outbound authenticated WebSocket"| API
    AGENT -->|"allowlisted read-only checks"| IBM["IBM MQ"]
    AGENT -->|"read-only HTTP diagnostics"| RMQ["RabbitMQ"]
    API -.->|"optional assistant"| MODEL["Local model"]
```

The Web page reads the inventory from the API without contacting a broker.
When you collect a host, the API sends that one request to the Agent named in
the inventory, the default Agent, or the Agent you pick on the page. The Agent
opens the connection outward. IBM MQ is reached with `runmqsc` over a
`SVRCONN`. RabbitMQ is reached with HTTP `GET`. The answer comes back on the
same WebSocket, is shown once, and is discarded.

Queue Watch, when you choose **Start watch**, reuses that Agent connection and
samples only `CURDEPTH` for the open queue. It does not enable monitoring or
statistics.

The dotted line is the optional local model. It runs on the API host, or at an
OpenAI-compatible URL you configure. The Agent does not load a model. Broker
data reaches the model only after you open **Show findings** and ask the
assistant. Inventory, collection, and Queue Watch work with no model installed.
See [Local assistant and models](llm.md).

## What you will use

| Piece | Where it runs | What it does |
| --- | --- | --- |
| [API](install-api.md) | A host the operators and Agents can reach | Holds `inventory.yaml` and routes each request |
| [Web](install-web.md) | Next to the API, or behind your reverse proxy | Login, inventory, and the host pages |
| [Agent](install-agent-linux.md) | Inside each broker network zone | Executes the read-only check. No inbound port |

Put the Agent on Linux or [Windows](install-agent-windows.md), wherever
`runmqsc` or the RabbitMQ management API is reachable. One Agent can serve
every queue manager in its zone. Use another Agent only when the network path
is different.

Packages come from [MQDeck releases](https://github.com/mqdeck/mqdeck/releases).
The download URL uses the public release tag (`MQDECK_VERSION`). The archive
name uses the component version in that release's `COMPONENTS.md`.

## Install

On RHEL-family Linux, download the package, run its installer as root, review
`/etc/mqdeck`, validate, and start the service. On Windows, the package
includes a PowerShell installer that creates the service.

Install in this order:

1. [API](install-api.md), then confirm `GET /healthz`.
2. [Web](install-web.md), then sign in.
3. [Agent on Linux](install-agent-linux.md) or [Agent on Windows](install-agent-windows.md), then confirm it appears in the Agent list.

Copy [examples/inventory.yaml](../examples/inventory.yaml) as the shape of the
API inventory and [examples/agent.yaml](../examples/agent.yaml) as the Agent
connection. Replace every example address and password with a literal value.
The API does not expand `${...}` placeholders.

## First look

1. Open the inventory. That page lists hosts from the file and does not contact a broker.
2. Open a host and choose **Collect data**. IBM MQ loads Overview first. Queues and Channels load when you open those tabs.
3. Expand a local queue to see depth and handles. Choose **Start watch** only when you want repeated depth samples.
4. On an inactive IBM MQ channel, **Start** sends `START CHANNEL` through the selected Agent. Collection itself stays on `DISPLAY`.
5. The [local assistant](llm.md) is optional. Reports and Queue Watch work without a model.

The [installation sequence](installation-sequence.md) is the short verification
path. Settings live in the [configuration reference](configuration.md). An
existing install follows [upgrade and rollback](upgrade.md). The design notes
are in [on-demand architecture](on-demand-architecture.md).
