# caddy-dns01

A small Caddy 2 build with the [`caddy-dns/cloudflare`](https://github.com/caddy-dns/cloudflare)
provider and [`caddy-l4`](https://github.com/mholt/caddy-l4), packaged as a Home Assistant add-on that fronts HA on `localhost:8123`
with HTTPS using DNS-01 ACME (no port 80 reachability from the public internet
required).

One multi-arch image published per release:

- `ghcr.io/cinderblock/caddy-dns01:latest` (and `:<version>`) — multi-arch
  manifest covering `linux/amd64` + `linux/arm64`. `docker pull` (and HA
  Supervisor's pull) auto-resolves the right architecture.

## Use as a Home Assistant add-on

In Home Assistant: **Settings → Add-ons → ⋮ → Repositories → Add**, paste

```
https://github.com/cinderblock/caddy-dns01
```

Then install **Caddy DNS-01** from the add-on store, fill in the options, and
start.

Required Cloudflare API token permissions (under **My Profile → API Tokens →
Create Token → Custom token**):

- `Zone:DNS:Edit` — create/delete `_acme-challenge` TXT records
- `Zone:Zone:Read` — look up the zone ID

Scoped to the specific zone (**Zone Resources → Include → Specific zone →
yourdomain.com**). Don't use the legacy Global API Key — the add-on rejects it
deliberately.

## Use the image standalone (non-HA)

The image is self-contained Caddy 2 + Cloudflare DNS plugin; the HA addon
entrypoint just renders a Caddyfile from `/data/options.json` before exec'ing
Caddy. To use it outside HA, supply your own Caddyfile and override the
entrypoint:

```bash
docker run --rm -d \
  -e CF_API_TOKEN=<your-token> \
  -p 80:80 -p 443:443 -p 443:443/udp \
  -v $PWD/Caddyfile:/etc/caddy/Caddyfile \
  --entrypoint caddy \
  ghcr.io/cinderblock/caddy-dns01:latest \
  run --config /etc/caddy/Caddyfile
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

## Repository layout

- `caddy-dns01/` — the HA add-on (slug `caddy-dns01`): `config.yaml`,
  `Dockerfile`, `run.sh`, `Caddyfile.tmpl`, README, CHANGELOG.
- `repository.yaml` — registers this repo as a HA add-on repository.
- `.github/workflows/build.yaml` — CI: native per-arch builds + multi-arch
  manifest stitch.

## License

MIT — see `LICENSE`.
