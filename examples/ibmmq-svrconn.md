# Observe IBM MQ through a client SVRCONN

MQDeck can collect IBM MQ definitions and runtime status when `mqweb`,
Administrative REST, and Messaging REST are disabled. The Agent runs the IBM
MQ Client `runmqsc -c` utility through a dedicated `SVRCONN` channel and
accepts only one `DISPLAY` statement per check.

## Requirements

- IBM MQ Client 9.4, including `runmqsc` and `dmpmqmsg`, on the Agent machine.
- TCP access from the Agent to the queue manager listener.
- A dedicated `SVRCONN` channel and least-privilege IBM MQ identity.
- Permission to connect, display the configured object types, and use the IBM
  MQ remote MQSC command/reply queues.

Ask the IBM MQ administrator to create the channel and map the authenticated
identity according to the site's TLS, CONNAUTH, and CHLAUTH standards. Do not
use an administrative principal for production observation. The exact OAM
records depend on the enabled checks and local security policy.

MQDeck always identifies the configured SVRCONN channel used for the current
collection. Queue, channel, listener, and status lists still reflect the
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
multiple IBM MQ connection names. For TLS ciphers, certificate labels, channel
exits, or other advanced client settings, configure a CCDT in the IBM MQ client
runtime instead of relying only on `MQSERVER`.

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
inventory and Agent configuration:

```bash
mqdeck-api -validate
mqdeck-agent -config agent.yaml -validate
```

The Agent supplies `MQSERVER` only to the `runmqsc` child process, passes the
password through standard input, invokes no shell, bounds output, and rejects
all MQSC operations that do not begin with `DISPLAY`.

For client applications, IBM MQ exposes `CONNAME` when the handle belongs to a
channel. MQDeck displays that value as the application origin alongside the
channel name. Bindings-mode applications run inside the queue manager host and
do not have a remote IP address, so they are identified as local processes.
