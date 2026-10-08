# Installation sequence

## 1. API component

Download the API release for the target operating system, install its service,
and review the static inventory. Confirm `GET /healthz` before continuing.
The API version is selected independently from Agent and Web versions.

## 2. Web component

Install the Web standalone release as its own service. Configure the API URL,
operator credentials, and session secret. Confirm the login page through the
production reverse proxy.
Do not assume the Web version must match the installed API version.

## 3. Broker identities

Grant display authority for collection. IBM MQ uses a dedicated `SVRCONN`
channel and one `DISPLAY` command per check. If operators will use **Start**
on the Channels tab, that same identity also needs permission to run
`START CHANNEL`. RabbitMQ uses HTTP `GET` against the Management API. Confirm
the identity can display every object type the operator expects to observe.
MQDeck identifies the access channel and warns when IBM MQ explicitly rejects
a collection for insufficient authority; objects hidden by authority must not
be interpreted as nonexistent.

## 4. Agent components

Install one Agent service per required network zone. Its ID must match an
inventory `agent_id` value or `default_agent_id`. Confirm it appears in
`GET /api/v1/agents`, then open a host, collect Overview, and open Queues and
Channels. Expand a queue to see depth and open handles.

For IBM MQ for z/OS, install the IBM MQ client and `runmqsc` on that Agent. If
the inventory uses `ccdt_url`, place the CCDT and optional TLS key repository at
the literal paths declared in the inventory and grant the Agent service account
read access before opening the queue manager.

Each component is downloaded, configured, started, stopped, upgraded, and
rolled back independently through the operating-system service manager.
