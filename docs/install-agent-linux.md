# Install Agent on Linux

Install an Agent at every network point that must reach brokers. IBM MQ targets
also require IBM MQ Client 9.4 with `runmqsc` available in `PATH`.

## RHEL, Rocky Linux, AlmaLinux, or Oracle Linux

```bash
curl -fLO https://github.com/mqdeck/mqdeck/releases/download/v1.0.11/mqdeck-agent_1.0.11_linux_amd64.tar.gz
tar -xzf mqdeck-agent_1.0.11_linux_amd64.tar.gz
cd mqdeck-agent_1.0.11_linux_amd64
sudo ./install-agent.sh
```

Use `linux_arm64` for ARM64. `wget` can be used instead of `curl -fLO` with the
same URL.

The installed environment points to the local API at
`http://127.0.0.1:8080`. Change `MQDECK_API_URL` in
`/etc/mqdeck/agent.env` only when the API runs on another machine. Review the
Agent token and configuration, then run:

```bash
sudo -u mqdeck bash -c 'set -a; . /etc/mqdeck/agent.env; set +a; /opt/mqdeck/agent/mqdeck-agent -config /etc/mqdeck/agent.yaml -validate'
sudo systemctl enable --now mqdeck-agent
sudo systemctl status mqdeck-agent --no-pager
sudo journalctl -u mqdeck-agent -n 100 --no-pager
```

The Agent opens an outbound HTTPS/WebSocket connection and listens on no
inbound port.

For an existing Agent, use the [upgrade and rollback guide](upgrade.md) so the
configuration is preserved and Agents are upgraded one network zone at a time.
