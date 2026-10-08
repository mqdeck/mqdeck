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
production data in the report.

## Security model

MQDeck limits broker interaction to read-only collection, plus one explicit channel start:

- RabbitMQ HTTP checks use `GET`, and local checks use allowlisted diagnostic
  subcommands.
- IBM MQ collection uses one `DISPLAY` MQSC command per check. The only other
  accepted MQSC command is `START CHANNEL(name)`, and only when an operator
  confirms it in Web.
- Adapter responses and WebSocket messages are size-bounded.
- Agents initiate authenticated outbound WebSocket connections; they expose no
  inbound command listener.
- The Agent revalidates every target before executing adapter checks.
- Credentials are never returned by inventory or report endpoints.
- Diagnostic results exist only for the request and are not persisted.

These controls reduce risk but do not replace deployment hardening. Operators
remain responsible for TLS, identity and access management, network isolation,
secret storage, Agent-token rotation, and reverse-proxy WebSocket controls.

Verify downloaded artifacts against the release `SHA256SUMS` file and use only
explicit, immutable versions. Require TLS for every non-local Agent connection.
