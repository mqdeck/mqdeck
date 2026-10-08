# Observe IBM MQ through a client SVRCONN

MQDeck can collect IBM MQ definitions and runtime status when `mqweb`,
Administrative REST, and Messaging REST are disabled. The Worker runs the IBM
MQ Client `runmqsc -c` utility through a dedicated `SVRCONN` channel.
Collection accepts one `DISPLAY` statement per check. The Channels tab can
also send `START CHANNEL` for one channel after the operator confirms it.
Queue Watch can send `ALTER QLOCAL(name) MONQ(LOW)`, then restore `MONQ(OFF)`
or `MONQ(QMGR)`, for the queue being watched.

## Requirements

- IBM MQ Client 9.4, including `runmqsc`, on the Worker machine.
- TCP access from the Worker to the queue manager listener.
- A dedicated `SVRCONN` channel and least-privilege IBM MQ identity.
- Permission to connect, display the configured object types, and use the IBM
  MQ remote MQSC command/reply queues.

The target queue manager can run on a distributed platform or IBM MQ for z/OS.
Client mode does not require a local queue manager on the Worker host.

Ask the IBM MQ administrator to create the channel and map the authenticated
identity according to the site's TLS, CONNAUTH, and CHLAUTH standards. Do not
use an administrative principal for production observation. The exact OAM
records depend on the enabled checks and local security policy.

MQDeck always identifies the configured SVRCONN channel used for the current
collection. Queue, channel, and status lists still reflect the
`DISPLAY`/`INQUIRE` authority granted to the connected identity. An empty list
therefore does not prove that an object type is absent. When IBM MQ reports an
authority failure, the broker view is marked as **Visibility limited** and
explains that the snapshot is partial.

System queues (`SYSTEM.*` and `AMQ.*`) are collected and displayed alongside
application queues. Their presence does not imply that the identity can see
every system object; normal IBM MQ authority rules still apply.

## Inventory definition

```yaml
- id: ibmmq-production-qm1
  adapter: ibmmq
  platform: distributed
  tags: [production, payments]
  endpoint: mq1.example.com:1414
  queue_manager: QM1
  channel: MQDECK.READONLY
  credentials:
    username: mqdeck_readonly
    password: replace-with-the-read-only-password
```

MQDeck automatically applies the fixed read-only IBM MQ collection profile,
timeout, output limit, and `runmqsc` client transport. Those operational fields
are intentionally not configurable in the inventory.

Use `mq-a.example.com:1414,mq-b.example.com:1414` when the client should try
multiple IBM MQ connection names.

For IBM MQ for z/OS, use the same direct definition. The channel can be a
generic, read-only SVRCONN shared according to the site's security policy:

```yaml
- id: ibmmq-zos-csq1
  name: Mainframe payments MQ
  adapter: ibmmq
  platform: zos
  tags: [production, mainframe, payments]
  worker_id: mainframe-network-worker
  endpoint: mainframe.example.net(1414)
  queue_manager: CSQ1
  channel: MQDECK.READONLY
  credentials:
    username: MQDECK
    password: replace-with-the-read-only-password
```

This path does not require a CCDT. MQDeck does not request listener objects from
z/OS because those listeners are managed by CHINIT rather than as distributed
MQ listener objects.

Only replace `endpoint` with `ccdt_url` when the channel requires TLS, channel
exits, or a managed connection list. In that case, the CCDT and optional
`tls.key_repository` files must be readable by the Worker service account; the
CCDT owns connection names, TLS CipherSpecs, and client channel policy.

## Validate the connection

Linux:

```bash
export MQSERVER='MQDECK.READONLY/TCP/mq1.example.com(1414)'
runmqsc -c -u "$IBMMQ_QM1_USERNAME" QM1
```

Windows PowerShell:

```powershell
$env:MQSERVER = "MQDECK.READONLY/TCP/mq1.example.com(1414)"
runmqsc.exe -c -u $env:IBMMQ_QM1_USERNAME QM1
```

Enter the password, issue `DISPLAY QMGR ALL`, and then `END`. A successful
response proves the same client path used by MQDeck. Finally validate the API
inventory and Worker configuration:

```bash
mqdeck-api -validate
mqdeck-worker -validate
```

On Linux, repeat the connection test as the service account. A successful test
as `root` does not prove that the `mqdeck` identity receives the same CHLAUTH,
MCAUSER, or command-security mapping:

```bash
sudo -u mqdeck env MQSERVER='MQDECK.READONLY/TCP/mq1.example.com(1414)' \
  /opt/mqm/bin/runmqsc -c QM1
```

If this service-account test fails while the root test succeeds, authorize or
map the dedicated MQDeck identity on the SVRCONN; do not run the Worker service
as root. Alternatively, configure a dedicated authenticated identity under
`credentials` in the inventory.

For CCDT/TLS validation, clear `MQSERVER`, set `MQCCDTURL` and `MQSSLKEYR` to
the inventory values, and run the same `runmqsc -c` command. The key repository
value can omit its `.kdb` suffix.

If direct validation fails, the IBM MQ reason code is authoritative: `2058`
usually identifies a queue-manager name mismatch, `2059`/`2538` indicate the
connection path, `2035` indicates identity/CHLAUTH/authority, and TLS reason
codes require a CCDT profile matching the secured SVRCONN.

For direct connections, the Worker supplies `MQSERVER` only to the `runmqsc`
child process. For CCDT connections, it clears `MQSERVER` and supplies
`MQCCDTURL` plus optional `MQSSLKEYR`. It passes the password through standard
input, invokes no shell, bounds output, and rejects MQSC other than one
`DISPLAY` command, `START CHANNEL(name)`, or the Queue Watch
`ALTER QLOCAL(name) MONQ(OFF|QMGR|LOW)`.

For client applications, IBM MQ exposes `CONNAME` when the handle belongs to a
channel. MQDeck displays that value as the application origin alongside the
channel name. Bindings-mode applications run inside the queue manager host and
do not have a remote IP address, so they are identified as local processes.
