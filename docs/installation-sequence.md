# Installation sequence

## 1. API component

Download the API release for the target operating system, install its service,
and review the static inventory. Confirm `GET /healthz` before continuing.

## 2. Web component

Install the Web standalone release as its own service. Configure the API URL,
operator credentials, and session secret. Confirm the login page through the
production reverse proxy.

## 3. Broker identities

Grant only read authorities. IBM MQ uses a dedicated `SVRCONN` channel and
allowlisted `DISPLAY` commands. RabbitMQ uses HTTP `GET` against the Management
API. Confirm the identity can display every object type the operator expects to
observe. MQDeck identifies the access channel and warns when IBM MQ explicitly
rejects a collection for insufficient authority; objects hidden by authority
must not be interpreted as nonexistent.

## 4. Agent components

Install one Agent service per required network zone. Its ID must match an
inventory `agent_id` value or `default_agent_id`. Confirm it appears in
`GET /api/v1/agents`, then open a broker detail page and verify the current
queue, channel, publisher, and consumer view.

For IBM MQ for z/OS, install the IBM MQ client and `runmqsc` on that Agent. If
the inventory uses `ccdt_url`, place the CCDT and optional TLS key repository at
the literal paths declared in the inventory and grant the Agent service account
read access before opening the queue manager.

Each component is downloaded, configured, started, stopped, upgraded, and
rolled back independently through the operating-system service manager.
