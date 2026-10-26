# Caddy DNS-01 (HA add-on)

Caddy 2 as a TLS-terminating reverse proxy in front of Home Assistant
(`localhost:8123` by default). ACME certificates are issued and renewed
automatically via the Cloudflare **DNS-01** challenge — no port-80
reachability from the public internet required.

Use case: Home Assistant on a host where you want valid HTTPS for clients
on the LAN (split-DNS), without exposing HA's Supervisor admin paths
through an external reverse proxy.

## Configuration

| Option | Required | Default | Description |
|---|---|---|---|
| `domain` | yes | — | FQDN to serve (e.g. `homeassistant.example.com`). |
| `email` | yes | — | Contact email for the ACME account (renewal-failure alerts). |
| `upstream` | no | `localhost:8123` | Where Caddy proxies traffic. |
| `cloudflare_api_token` | yes | — | Cloudflare API token scoped to `Zone:DNS:Edit` + `Zone:Zone:Read` for the zone. |

Whitespace in the pasted token is stripped defensively at startup — a
leading or trailing newline otherwise produces Cloudflare error
`6111: Invalid format for Authorization header`.

## Extra Caddyfile snippets

The add-on config dir (`/addon_configs/<repo>_caddy-dns01` on the host,
`/config` in the container, read-only) can hold Caddyfile snippets:

- `global.d/*.caddy` — imported inside the global options block.
- `sites.d/*.caddy` — imported after the HA site.

Either directory may be absent. Restart the add-on after changing them.

The build includes [`caddy-l4`](https://github.com/mholt/caddy-l4), so a
`global.d` snippet can route raw TCP on `:443` by TLS SNI before Caddy's own
TLS handling — e.g. pass some names straight through to another service that
terminates its own TLS:

```
servers :443 {
    listener_wrappers {
        layer4 {
            @passthrough tls sni other.example.com
            route @passthrough {
                proxy tcp/127.0.0.1:4443
            }
        }
        tls
    }
}
```

## Ports

Add-on binds the host's `80/tcp`, `443/tcp`, and `443/udp` (HTTP/3).
HTTP requests automatically redirect to HTTPS.

## What it does at startup

1. Reads `/data/options.json` (provided by the Supervisor from the add-on
   options).
2. Renders `/etc/caddy/Caddyfile` from `Caddyfile.tmpl` using `sed`
   (including the `global.d` / `sites.d` imports above).
3. Exports `CF_API_TOKEN` for Caddy's `tls { dns cloudflare {env...} }`
   directive.
4. `exec caddy run`.

Caddy then issues/renews the cert via Cloudflare DNS-01 and keeps it
fresh automatically.

## Logs

Add-on log surfaces both the rendered-Caddyfile log line and Caddy's own
output (ACME, request log, etc.).

## Renewal

Caddy automatically renews ~30 days before expiry. No HA automation
needed.
