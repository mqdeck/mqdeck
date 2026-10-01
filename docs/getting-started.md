# Getting started

MQDeck is a read-only, on-demand diagnostic console for IBM MQ and RabbitMQ.
It needs three components and no external datastore:

1. API with a local `inventory.yaml`.
2. One or more Agents with outbound HTTPS access to the API and network access to brokers.
3. Web connected to the API.

For local development from the workspace root:

```bash
./start.sh
```

The launcher starts local brokers, API, Agent, and Web; validates each process;
then executes one real diagnostic through the complete path. Open
<http://localhost:3000> and sign in with the local credentials from `.env`.

Stop everything with:

```bash
./stop.sh
```

For a deployed environment, continue with the
[installation sequence](installation-sequence.md) and
[configuration reference](configuration.md).
