#!/bin/sh
set -e

# Default port to Railway's PORT env var or 29334
LISTEN_PORT="${PORT:-29334}"

# Create data directory if it doesn't exist
mkdir -p /data

# Write config.yaml
cat <<EOF > /data/config.yaml
homeserver:
  address: "${HOMESERVER_URL}"
  domain: "${HOMESERVER_DOMAIN}"
  software: "standard"

appservice:
  address: "http://0.0.0.0:${LISTEN_PORT}"
  hostname: "0.0.0.0"
  port: ${LISTEN_PORT}
  database:
    type: "postgres"
    uri: "${DATABASE_URL}"
  id: "discord"
  bot:
    username: "discordbot"
    displayname: "Discord Bridge Bot"
  as_token: "${AS_TOKEN}"
  hs_token: "${HS_TOKEN}"
  public_address: "${PUBLIC_URL}"

bridge:
  restricted_rooms: true
  public_portals: true
  default_join_rules: "public"
  federate_rooms: true
  prefix_webhook_messages: false
  username_template: "discord_{{.}}"
  displayname_template: "{{.GlobalName}}"
  permissions:
    "${HOMESERVER_DOMAIN}": "user"
    "${ADMIN_MXID}": "admin"
  webhooks:
    allowed: true
    name_format: "{{.DisplayName}} (Matrix)"
    avatar_url_format: "{{.AvatarURL}}"

discord:
  bot_token: "${DISCORD_TOKEN}"
EOF

# Write registration.yaml
cat <<EOF > /data/registration.yaml
id: discord
url: "${PUBLIC_URL}"
as_token: "${AS_TOKEN}"
hs_token: "${HS_TOKEN}"
sender_localpart: discordbot
rate_limited: false
namespaces:
  users:
    - exclusive: true
      regex: '@discord_.*'
  rooms: []
  aliases:
    - exclusive: true
      regex: '#discord_.*'
EOF

echo "Configuration generated successfully. Starting mautrix-discord..."
exec /usr/bin/mautrix-discord -c /data/config.yaml -r /data/registration.yaml
