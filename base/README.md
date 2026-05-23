# base/ — lean Caddy + Cloudflare DNS plugin

Vanilla Caddy 2 plus only the `caddy-dns/cloudflare` DNS provider. Nothing
else — no FrankenPHP, no cache layer, no extra plugins. ~50 MB.

Published as `ghcr.io/cinderblock/caddy-dns01-base:latest` (multi-arch).

Build locally:

```bash
docker build -t caddy-dns01-base:dev base/
docker run --rm caddy-dns01-base:dev caddy list-modules | grep cloudflare
```

If the Cloudflare module didn't link, the build itself fails (the smoke
test in the final `RUN` exits non-zero).

Usage: see the top-level `README.md`.
