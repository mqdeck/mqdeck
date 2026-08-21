# Security policy

## Supported versions

MQDeck 1.0 is the supported stable release line. Security fixes target the
latest published 1.0 patch release. Unsupported prerelease and older patch
artifacts may not receive fixes.

## Report a vulnerability

Do not open a public issue for a suspected vulnerability.

Use **Report a vulnerability** on the Security tab of the public
[`mqdeck` repository](https://github.com/mqdeck/mqdeck/security/advisories/new).
Include:

- the affected component and commit or version;
- steps to reproduce the issue;
- the expected and observed impact;
- any suggested mitigation;
- whether the issue is already public or being actively exploited.

Please avoid including real credentials, broker payloads, or sensitive
production evidence in the report.

## Security model

MQDeck limits broker interaction to read-only operations:

- RabbitMQ HTTP checks use `GET`, and local checks use allowlisted diagnostic
  subcommands.
- IBM MQ REST checks use `GET`, and local MQSC checks must begin with `DISPLAY`.
- Adapter responses are size-bounded before storage.
- The API exposes query operations only and is not part of evidence ingestion.
- Credentials are not included in host snapshots or evidence documents.
- The agent blocks ingestion until the configured Elasticsearch ILM retention
  policy is enforced. The default permanently removes MQDeck data after six
  hours, including when agents are offline.

These controls reduce risk but do not replace deployment hardening. Operators
remain responsible for TLS, identity and access management, network isolation,
secret storage, Elasticsearch authorization, and approval of the configured
evidence retention period.

Verify downloaded artifacts against the release `SHA256SUMS` file and use only
explicit, immutable versions. Do not expose Agent Test Flight endpoints without
authentication and network controls.
