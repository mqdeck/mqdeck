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

MQDeck limits broker interaction to read-only collection, explicit named-channel
operations, and the Queue Watch `MONQ` change:

- RabbitMQ HTTP checks use `GET`, and local checks use allowlisted diagnostic
  subcommands.
- IBM MQ collection uses one `DISPLAY` MQSC command per check. The other
  accepted MQSC commands are `START CHANNEL(name)` and
  `STOP CHANNEL(name) MODE(QUIESCE)`, only when an authorized operator confirms
  the action in Web, and `ALTER QLOCAL(name) MONQ(LOW)`, `MONQ(OFF)`, or
  `MONQ(QMGR)` for the queue in an active Queue Watch. The watch restores
  `OFF` or `QMGR` when it stops and does not change the queue manager `MONQ`.
- Adapter responses and WebSocket messages are size-bounded.
- Workers initiate authenticated outbound WebSocket connections; they expose no
  inbound command listener.
- The Worker revalidates every target before executing adapter checks.
- Credentials are never returned by inventory or report endpoints.
- Diagnostic results exist only for the request and are not persisted.
- Web enforces signed sessions and server-side permissions. The built-in
  Administrator profile can start and stop channels, use Watch Activity, and
  manage identity settings. The built-in User profile can only start inactive
  channels.
- Microsoft Entra ID SAML assertions are checked for signature, issuer,
  audience, expiry, and request correlation. Users without a mapped Entra group
  receive the configured default profile, which defaults to User.

These controls reduce risk but do not replace deployment hardening. Operators
remain responsible for TLS, identity and access management, network isolation,
secret storage, Worker-token rotation, and reverse-proxy WebSocket controls.

Verify downloaded artifacts against the release `SHA256SUMS` file and use only
explicit, immutable versions. Require TLS for every non-local Worker connection.

IBM and IBM MQ are trademarks or registered trademarks of International
Business Machines Corporation. References describe compatibility only. See
[Trademarks and product independence](TRADEMARKS.md).
