# Changelog

## 0.1.0 — initial

- Caddy 2 reverse proxy with Cloudflare DNS-01 ACME
- Options: `domain`, `email`, `upstream`, `cloudflare_api_token`
- Binds host `80/tcp`, `443/tcp`, `443/udp` (HTTP/3); auto HTTP→HTTPS redirect
- Built from `caddy-dns01-base` (lean Caddy + `caddy-dns/cloudflare`)
