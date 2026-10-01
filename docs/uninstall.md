# Uninstall

Remove each component independently with its operating-system service manager.
For example on RHEL-family systems:

```bash
sudo systemctl disable --now mqdeck-web
sudo systemctl disable --now mqdeck-agent
sudo systemctl disable --now mqdeck-api
```

Then run the matching `uninstall-web.sh`, `uninstall-agent.sh`, or
`uninstall-api.sh` from that component package. Preserve inventory and
credentials when they must be reused.

MQDeck owns no broker objects, messages, Elasticsearch indices, or diagnostic
history. Uninstalling it therefore requires no data migration or purge step.
