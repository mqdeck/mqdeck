# IBM MQ standalone publisher and consumer

This public laboratory keeps one publisher and one consumer connected to a
local queue on the same standalone queue manager. It does not use a remote
queue, transmission queue, sender channel, receiver channel, or second queue
manager.

MQDeck observes the resulting application handles through the detailed `queues`
check. The dependency map should show this path:

```text
amqsput (publisher) -> QM1 -> MQDECK.DEMO.LOCAL -> amqsget (consumer)
```

## Prerequisites

- IBM MQ sample programs are installed under `/opt/mqm/samp/bin`.
- `QM1` is running.
- The operating-system identity running the samples is authorized to connect,
  put, and get messages.
- The MQDeck Agent uses an IBM MQ host definition with `queues` in
  `detail_tests`.

The queue is an environment prerequisite. Creating it is an administrative
setup action performed outside MQDeck:

```bash
printf 'DEFINE QLOCAL(MQDECK.DEMO.LOCAL) DEFPSIST(NO) MAXDEPTH(10000)\nEND\n' |
  runmqsc QM1
```

## Keep the consumer connected

Run this command in the first terminal:

```bash
/opt/mqm/samp/bin/amqsget MQDECK.DEMO.LOCAL QM1
```

`amqsget` keeps an input handle open while it waits for messages.

## Keep the publisher connected

Run `amqsput` in a second terminal. Enter one message per line and leave the
process running instead of sending end-of-file:

```bash
/opt/mqm/samp/bin/amqsput MQDECK.DEMO.LOCAL QM1
```

Each submitted line is placed on the local queue while the output handle stays
open. Submit messages frequently enough to keep the sample consumer waiting
for the next message.

## Verify through MQDeck

After the next detailed collection, open the `ibmmq-standalone` host and select
**Dependencies**. The queue lane should contain both an observed publisher and
an observed consumer. The **Applications** tab exposes the process IDs, users,
connection type, open options, and queue roles used to derive the map.

Stop the sample applications with `Ctrl+C`. MQDeck does not stop, alter, or
manage either application.
