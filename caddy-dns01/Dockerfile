# Caddy 2 + caddy-dns/cloudflare, wrapped as a Home Assistant add-on.
# Built per-arch natively in CI (ubuntu-24.04 + ubuntu-24.04-arm) and
# stitched into a multi-arch manifest at ghcr.io/cinderblock/caddy-dns01.

FROM caddy:2-builder AS builder

RUN xcaddy build \
    --with github.com/caddy-dns/cloudflare

FROM caddy:2

COPY --from=builder /usr/bin/caddy /usr/bin/caddy

# Smoke-test: fails the build if the Cloudflare provider didn't link.
RUN caddy list-modules | grep -q '^dns.providers.cloudflare$'

# Tools for the HA add-on entrypoint
RUN apk add --no-cache jq

COPY run.sh /run.sh
COPY Caddyfile.tmpl /etc/caddy/Caddyfile.tmpl
RUN chmod +x /run.sh

ARG BUILD_VERSION
ARG BUILD_ARCH
LABEL \
    io.hass.name="Caddy DNS-01" \
    io.hass.description="Caddy 2 reverse proxy with Cloudflare DNS-01 ACME" \
    io.hass.type="addon" \
    io.hass.version="${BUILD_VERSION}" \
    io.hass.arch="${BUILD_ARCH}" \
    org.opencontainers.image.source="https://github.com/cinderblock/caddy-dns01"

ENTRYPOINT ["/run.sh"]
