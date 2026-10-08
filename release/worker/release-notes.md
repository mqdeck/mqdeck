# MQDeck 1.0.14

MQDeck 1.0.14 makes the IBM MQ channel view faster to read during daily
operations while preserving the complete channel inventory introduced in
1.0.13.

## IBM MQ channel status

- Gives the state reported by IBM MQ its own prominent `MQ status` column.
- Distinguishes the MQ state from the presence of a current runtime instance.
- Uses clear visual treatments for running, inactive, and problem states.
- Keeps the access channel first and visually identifiable.
- Moves the authority visibility notice from a full-width banner into the
  access-channel row; an actual authority limitation receives warning emphasis.
- Reorganizes type, connection, transmission queue, and activity information
  into consistent columns without duplicating inactive-state messages.
- Uses neutral language when no endpoint or activity has been observed so an
  idle definition is not presented as a failure.

## Existing capabilities

- Retains the opt-in Queue Watch with automatic cleanup when disabled, when a
  different queue is opened, or when the operator leaves the screen.
- Retains application, `SYSTEM.*`, and `AMQ.*` queues in the graphical flow.
- Retains the 12 px general typography floor and compact workflow-specific
  labels.

## Distribution

- Independent API, Worker, and Web packages for Linux AMD64/ARM64, Windows
  AMD64, and supported macOS development hosts.
- Helm chart `mqdeck-1.0.14.tgz`.
- Component and aggregate SHA-256 checksum files.
- Normalized `root:root` TAR ownership, executable Linux install/uninstall
  scripts, and archives without macOS extended attributes.

No inventory or data migration is required. Upgrade API, Workers, then Web by
following the [upgrade guide](https://github.com/mqdeck/mqdeck/blob/main/docs/upgrade.md).
