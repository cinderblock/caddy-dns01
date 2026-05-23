# Lean Caddy 2 build with only the caddy-dns/cloudflare provider.
# Multi-arch image (linux/amd64 + linux/arm64) — see .github/workflows/build.yaml.
#
# Used directly as a Caddy + Cloudflare-DNS-01 base image, and as the base
# for the Home Assistant add-on in ../caddy-dns01/.

FROM caddy:2-builder AS builder

RUN xcaddy build \
    --with github.com/caddy-dns/cloudflare

FROM caddy:2

COPY --from=builder /usr/bin/caddy /usr/bin/caddy

# Smoke-test the build — fails the image build if the plugin didn't link.
RUN caddy list-modules | grep -q '^dns.providers.cloudflare$'
