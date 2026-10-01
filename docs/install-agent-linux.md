# Install Agent on Linux

Requirements:

- Outbound HTTPS/WebSocket access to the MQDeck API.
- Network access to assigned brokers.
- IBM MQ client tools including `runmqsc` for IBM MQ client transport.

Install the binary and configuration:

```bash
install -m 0755 mqdeck-agent /usr/local/bin/mqdeck-agent
install -d -m 0750 /etc/mqdeck
install -m 0640 agent.yaml /etc/mqdeck/agent.yaml
mqdeck-agent -config /etc/mqdeck/agent.yaml -validate
```

Run it under systemd using the packaged service file. Put
`MQDECK_AGENT_TOKEN` in the protected environment file. No inbound Agent port
or local datastore is required.
