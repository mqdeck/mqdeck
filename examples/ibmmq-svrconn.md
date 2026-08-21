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

## Agent definition

```yaml
- id: ibmmq-production-qm1
  name: IBM MQ production QM1
  adapter: ibmmq
  transport: client
  endpoint: mq1.example.com:1414
  queue_manager: QM1
  channel: MQDECK.READONLY
  schedule: "@every 30s"
  timeout: 20s
  credentials:
    username: ${IBMMQ_QM1_USERNAME}
    password: ${IBMMQ_QM1_PASSWORD}
  tests: [queue_manager, queue_status, channel_status]
  detail_tests: [queues, channels, listeners, listener_status]
  capture:
    detail_interval: 10m
    max_response_bytes: 2097152
```

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
response proves the same client path used by MQDeck. Finally validate the full
Agent configuration:

```bash
mqdeck-agent -config mqdeck.yaml -validate
```

The Agent supplies `MQSERVER` only to the `runmqsc` child process, passes the
password through standard input, invokes no shell, bounds output, and rejects
all MQSC operations that do not begin with `DISPLAY`.

When Test Flight is enabled, the Agent also supplies `MQSERVER` only to the
`dmpmqmsg` child process and passes its password through standard input. It
creates one message with a generated correlation ID and consumes only that
exact ID from an existing `MQDECK.*` test queue. Set `test_runner.channel` when
this identity uses a different `SVRCONN` channel from the collection identity.
