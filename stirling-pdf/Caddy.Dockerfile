# Custom Caddy image with the caddy-ratelimit module compiled in.
#
# Rate limiting is not part of stock Caddy, so we use xcaddy (bundled in the
# official Caddy "builder" image) to build a Caddy binary that includes the
# module, then copy it into the standard slim runtime image.
#
# Pin the module version for reproducible builds if you like, e.g.:
#   --with github.com/mholt/caddy-ratelimit@v0.1.0
FROM caddy:2-builder AS builder
RUN xcaddy build \
    --with github.com/mholt/caddy-ratelimit

FROM caddy:2-alpine
COPY --from=builder /usr/bin/caddy /usr/bin/caddy
