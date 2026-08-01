# Upgrade and rollback

## Binary installations

1. Download the new artifact and verify its SHA-256 checksum.
2. Stop the component service.
3. Back up `/etc/mqdeck`.
4. Replace the executable or Web standalone directory.
5. Run `-version` and validate Agent configuration with `-validate`.
6. Start the service and inspect health and logs.

Keep the previous artifact until validation completes. Roll back by restoring
the previous binary or directory and restarting the service.

## Helm installations

Review the proposed change:

```bash
helm template mqdeck ./mqdeck-NEW_VERSION.tgz -f production-values.yaml
helm upgrade mqdeck ./mqdeck-NEW_VERSION.tgz \
  --namespace mqdeck --reuse-values --atomic --timeout 10m
```

List revisions and roll back:

```bash
helm history mqdeck --namespace mqdeck
helm rollback mqdeck REVISION --namespace mqdeck --wait
```

Always pin explicit image and chart versions. Configuration compatibility and
known changes are documented in each GitHub release.
