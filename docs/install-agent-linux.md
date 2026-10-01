# Install Agent on Linux

Install an Agent at every network point that must reach brokers. IBM MQ targets
also require IBM MQ Client 9.4 with `runmqsc` available in `PATH`.

## RHEL, Rocky Linux, AlmaLinux, or Oracle Linux

```bash
curl -fLO https://mqdeck.github.io/mqdeck/downloads/1.0.10/mqdeck-agent_1.0.10_linux_amd64.tar.gz
tar -xzf mqdeck-agent_1.0.10_linux_amd64.tar.gz
cd mqdeck-agent_1.0.10_linux_amd64
sudo ./install-agent.sh
```

Use `linux_arm64` for ARM64. `wget` can be used instead of `curl -fLO` with the
same URL.

Review `/etc/mqdeck/agent.yaml` and `/etc/mqdeck/agent.env`, then run:

```bash
sudo -u mqdeck bash -c 'set -a; . /etc/mqdeck/agent.env; set +a; /opt/mqdeck/agent/mqdeck-agent -config /etc/mqdeck/agent.yaml -validate'
sudo systemctl enable --now mqdeck-agent
sudo systemctl status mqdeck-agent --no-pager
sudo journalctl -u mqdeck-agent -n 100 --no-pager
```

The Agent opens an outbound HTTPS/WebSocket connection and listens on no
inbound port.
