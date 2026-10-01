# Install Web

MQDeck Web requires Node.js 20.20 or newer for the standalone artifact.
Configure:

```dotenv
MQDECK_API_URL=https://mqdeck-api.example.com
MQDECK_AUTH_USERNAME=admin
MQDECK_AUTH_PASSWORD=replace-with-a-strong-password
MQDECK_AUTH_DISPLAY_NAME=MQDeck Operator
MQDECK_AUTH_SESSION_SECRET=replace-with-a-long-random-secret
```

The browser talks only to same-origin Web proxy routes. Web does not connect to
brokers, Agents, or a datastore.
