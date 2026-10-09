# Identity and access

MQDeck Web supports Microsoft Entra ID as its primary corporate identity
provider through SAML 2.0. It also supports local accounts for recovery access
and installations that do not use Entra ID.

## Built-in access profiles

| Profile | Permissions |
| --- | --- |
| Administrator | Start and stop named channels, use Watch Activity, replace inventory, read audit records, configure SSO, and manage local users |
| User | Start an inactive channel |

Permissions are enforced by Web API routes. Hiding an unavailable button is a
usability measure and is not the authorization boundary.

## Configure Microsoft Entra ID

1. Start MQDeck Web behind HTTPS and sign in with the local recovery
   administrator.
2. Open **Settings → Single sign-on**.
3. Copy MQDeck's Entity ID, Reply URL, Sign-on URL, and SP metadata URL into the
   Basic SAML Configuration of the Entra enterprise application.
4. In Entra, configure a group claim when your tenant supports groups.
5. Copy the **App Federation Metadata URL** from Entra into MQDeck.
6. Map Entra group Object IDs or emitted names to the Administrator and User
   profiles, choose the default profile, then select **Validate and save**.

MQDeck imports the Entra issuer, SSO endpoint, and signing certificates from
the federation metadata. Assertions are validated for signature, issuer,
audience, expiry, and correlation to the authentication request.

### Tenants without groups

Group mapping is optional. If Entra sends no group claim, or no received group
matches a configured mapping, MQDeck assigns the selected default profile. The
default is **User**, so a tenant without group support can validate SSO without
granting administrative access.

Names such as `GROUP_USERS_ADMIN` and `GROUP_USERS` are accepted only when they
are actually emitted in the configured claim. Object IDs are recommended
because Entra normally emits immutable group identifiers.

## Local users

Open **Settings → Users & access** to create, disable, or assign an internal
profile to a local user. Passwords require at least 12 characters and are stored
as scrypt hashes. The bootstrap administrator configured through environment or
properties remains the recovery account.

## Temporary configuration store

Until a database is selected, identity configuration is stored in the file
selected by `MQDECK_PLATFORM_CONFIG_PATH`. The file contains SSO metadata,
group mappings, internal profiles, local account metadata, and password hashes.
MQDeck writes it atomically with owner-only permissions.

Back up the file, restrict access to the Web service account, and do not place
it in source control. Moving to a database should preserve the same group and
permission model.

## HTTPS requirements

Use a trusted certificate and stable public URL in production. The local
development launcher can create a host-trusted certificate with `mkcert` and
expose Web through nginx at `https://mqdeck.localhost:3443`; that workflow is
for local validation only.

Set the following values for a packaged or production installation:

| Variable | Purpose |
| --- | --- |
| `MQDECK_PUBLIC_URL` | External HTTPS origin used to build SAML identifiers and callback URLs |
| `MQDECK_PLATFORM_CONFIG_PATH` | Exclusive identity and access configuration file |
| `MQDECK_AUTH_SESSION_SECRET` | Long random value used to sign sessions |
| `MQDECK_AUTH_USERNAME` | Recovery administrator username |
| `MQDECK_AUTH_PASSWORD` | Recovery administrator password |
| `MQDECK_AUTH_DISPLAY_NAME` | Recovery administrator display name |
| `MQDECK_MANAGEMENT_TOKEN` | Server-to-server secret shared with API for managed operations and audit |

Rotate the bootstrap password and session secret before any shared deployment.

On the Linux service package, use the equivalent dotted property names in
`/etc/mqdeck/web.properties`; for example, `mqdeck.public.url` and
`mqdeck.platform.config.path`. The default writable platform configuration path
is `/var/lib/mqdeck-web/platform-config.json`. On Windows, the installer
defaults it to `%ProgramData%\MQDeck\Web\platform-config.json`.

IBM and IBM MQ are trademarks or registered trademarks of International
Business Machines Corporation. References describe compatibility only. See
[Trademarks and product independence](../TRADEMARKS.md).
