# Security policy

## Supported versions

MQDeck has not published a stable release. Security fixes currently target the
latest commit on each repository's default branch.

## Report a vulnerability

Do not open a public issue for a suspected vulnerability.

Use **Report a vulnerability** on the Security tab of the affected GitHub
repository. Include:

- the affected component and commit or version;
- steps to reproduce the issue;
- the expected and observed impact;
- any suggested mitigation;
- whether the issue is already public or being actively exploited.

If the affected component is unclear, report it through the
[`mqdeck` repository](https://github.com/mqdeck/mqdeck/security/advisories/new).
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

These controls reduce risk but do not replace deployment hardening. Operators
remain responsible for TLS, identity and access management, network isolation,
secret storage, Elasticsearch authorization, and evidence retention.

The credentials and relaxed TLS configuration in `mqdeck-local` are disposable
development defaults and must not be used in production.
