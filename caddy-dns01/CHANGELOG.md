# Changelog

## 0.2.1

- Mount the add-on config dir at `/addon_config` instead of `/config`. The caddy
  base image keeps its config autosave in `/config`, which 0.2.0's read-only
  mapping shadowed (`unable to create folder for config autosave`).

## 0.2.0

- Build includes [`caddy-l4`](https://github.com/mholt/caddy-l4) (layer-4 routing, e.g. TLS passthrough by SNI)
- Maps the add-on config dir read-only at `/config`; the Caddyfile imports
  `/config/global.d/*.caddy` (inside the global options) and `/config/sites.d/*.caddy`

## 0.1.0 — initial

- Caddy 2 reverse proxy with Cloudflare DNS-01 ACME
- Options: `domain`, `email`, `upstream`, `cloudflare_api_token`
- Binds host `80/tcp`, `443/tcp`, `443/udp` (HTTP/3); auto HTTP→HTTPS redirect
- Single multi-arch image at `ghcr.io/cinderblock/caddy-dns01` (linux/amd64 + linux/arm64)
