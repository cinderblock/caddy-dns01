# HA add-on image. Built per-arch by CI and published to
# ghcr.io/cinderblock/{arch}-caddy-dns01:<version>.
#
# Composes the lean base image with a tiny entrypoint that renders a
# Caddyfile from add-on options and execs caddy.

FROM ghcr.io/cinderblock/caddy-dns01-base:latest

RUN apk add --no-cache jq

COPY run.sh /run.sh
COPY Caddyfile.tmpl /etc/caddy/Caddyfile.tmpl
RUN chmod +x /run.sh

# Standard HA add-on labels
ARG BUILD_VERSION
ARG BUILD_ARCH
LABEL \
    io.hass.name="Caddy DNS-01" \
    io.hass.description="Caddy 2 reverse proxy with Cloudflare DNS-01 ACME" \
    io.hass.type="addon" \
    io.hass.version="${BUILD_VERSION}" \
    io.hass.arch="${BUILD_ARCH}"

ENTRYPOINT ["/run.sh"]
