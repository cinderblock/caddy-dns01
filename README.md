# caddy-dns01

A small Caddy 2 build with the [`caddy-dns/cloudflare`](https://github.com/caddy-dns/cloudflare)
provider, plus a Home Assistant add-on that uses it as a TLS-terminating reverse
proxy in front of `localhost:8123`.

Two artifacts in one repo:

- **`base/`** — the lean Caddy image (Caddy 2 + Cloudflare DNS plugin, nothing
  else). Published as a multi-arch image at
  `ghcr.io/cinderblock/caddy-dns01-base:latest`. Use it directly if you just
  want Caddy with DNS-01 (any setting, any upstream).
- **`caddy-dns01/`** — the Home Assistant add-on. Builds on `base/`, adds a
  tiny entrypoint that renders a Caddyfile from add-on options, and exposes
  ports 80/443. Listed in `repository.yaml` so HA Supervisor finds it.

## Use as an HA add-on

In Home Assistant: **Settings → Add-ons → ⋮ → Repositories → Add**, paste
`https://github.com/cinderblock/caddy-dns01`. Then install **Caddy DNS-01**
from the add-on store, fill in the options (Cloudflare API token, domain,
ACME email), and start.

Required Cloudflare API token permissions:

- `Zone:DNS:Edit` (create/delete `_acme-challenge` TXT records)
- `Zone:Zone:Read` (look up the zone ID)

Scoped to the specific zone (`Zone Resources → Include → Specific zone`).
Don't use the legacy Global API Key.

## Use the base image standalone

```bash
docker run --rm -d \
  -e CF_API_TOKEN=<token> \
  -p 80:80 -p 443:443 -p 443:443/udp \
  -v $PWD/Caddyfile:/etc/caddy/Caddyfile \
  ghcr.io/cinderblock/caddy-dns01-base:latest
```

Example `Caddyfile`:

```
example.com {
    reverse_proxy backend:8080
    tls {
        dns cloudflare {env.CF_API_TOKEN}
    }
}
```

## License

MIT — see `LICENSE`.
