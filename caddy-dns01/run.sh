#!/bin/sh
# HA add-on entrypoint: render a Caddyfile from /data/options.json,
# export CF_API_TOKEN, exec caddy.

set -e

OPTS=/data/options.json

DOMAIN=$(jq -r '.domain // ""' "$OPTS")
EMAIL=$(jq -r '.email // ""' "$OPTS")
UPSTREAM=$(jq -r '.upstream // "localhost:8123"' "$OPTS")
CF_API_TOKEN=$(jq -r '.cloudflare_api_token // ""' "$OPTS")

[ -z "$DOMAIN" ]        && { echo "caddy-dns01: 'domain' option is required" >&2; exit 1; }
[ -z "$EMAIL" ]         && { echo "caddy-dns01: 'email' option is required" >&2; exit 1; }
[ -z "$CF_API_TOKEN" ]  && { echo "caddy-dns01: 'cloudflare_api_token' option is required" >&2; exit 1; }

# Trim defensively — Cloudflare returns 6111 'Invalid format for Authorization
# header' if a stray newline or space rides along in a pasted token.
CF_API_TOKEN=$(printf '%s' "$CF_API_TOKEN" | tr -d '[:space:]')

export CF_API_TOKEN
export DOMAIN EMAIL UPSTREAM

# Render the Caddyfile. Using sed since the alpine base lacks envsubst.
sed \
    -e "s|@@DOMAIN@@|${DOMAIN}|g" \
    -e "s|@@EMAIL@@|${EMAIL}|g" \
    -e "s|@@UPSTREAM@@|${UPSTREAM}|g" \
    /etc/caddy/Caddyfile.tmpl > /etc/caddy/Caddyfile

echo "caddy-dns01: rendered Caddyfile for ${DOMAIN} -> ${UPSTREAM}"

exec caddy run --config /etc/caddy/Caddyfile --adapter caddyfile
