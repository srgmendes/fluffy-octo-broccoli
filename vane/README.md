# Vane

Self-hosted [Vane](https://github.com/ItzCrazyKns/Vane) — a privacy-focused AI
answering engine that merges web search (via a bundled SearxNG instance) with
local (Ollama, Lemonade) or cloud (OpenAI, Anthropic, Google, Groq) LLMs to
answer questions with cited sources. This directory contains a Docker Compose
setup that runs the official prebuilt image behind a
[Caddy](https://caddyserver.com/) reverse proxy that terminates **HTTPS** — so
no build from source is required.

## Requirements

- [Docker](https://docs.docker.com/get-docker/) 20.10+
- [Docker Compose](https://docs.docker.com/compose/) v2 (`docker compose`)
- Host ports **80** and **443** free (used by the reverse proxy)

## Quick start

Vane has **no built-in login yet** (it's an upcoming upstream feature), so the
Caddy proxy's HTTP Basic Auth is the only thing gating access to this
instance. Set real credentials before exposing it beyond your own machine:

```bash
cp proxy-auth.env.example proxy-auth.env   # then edit it, see below
cp .env.example .env                       # optional: set VANE_DOMAIN, rate limits
docker compose up -d --build
```

> The `--build` flag builds the custom Caddy image (it bundles the rate-limiting
> module). You only need it the first time and whenever `Caddy.Dockerfile`
> changes; plain `docker compose up -d` is fine otherwise.

Then open <https://localhost>, sign in with your Basic Auth credentials, and
complete Vane's **in-app setup screen** — that's where you pick AI providers,
models, and (if not using the bundled one) a SearxNG URL. See
[Configuration](#configuration).

Traffic is served over HTTPS by the bundled Caddy reverse proxy. On
`localhost` Caddy uses its own internal CA, so your browser shows a one-time
certificate warning until you trust that CA — see
[Reverse proxy & HTTPS](#reverse-proxy--https).

To view logs, stop, or update:

```bash
docker compose logs -f        # follow logs
docker compose down           # stop and remove the containers
docker compose pull           # fetch the latest Vane image
docker compose up -d          # recreate with the new image
```

## What's here

| Path                     | Purpose                                                              |
| ------------------------ | --------------------------------------------------------------------- |
| `docker-compose.yml`     | Vane (pinned to `v1.12.2`, bundled SearxNG) + Caddy reverse proxy.   |
| `Caddyfile`               | Reverse-proxy config: HTTPS, basic auth, security headers, rate limit. |
| `Caddy.Dockerfile`        | Builds Caddy with the `caddy-ratelimit` module compiled in.          |
| `.env.example`            | Template for the proxy domain and rate limits — copy to `.env`.      |
| `proxy-auth.env.example`  | Template for the proxy's basic-auth credentials — copy to `proxy-auth.env`. |
| `data/`                   | Persisted Vane app data (bundled SearxNG state, history, uploads, setup config). |

The `data/` contents are git-ignored (except the directory structure) since they
are runtime state.

## Configuration

Unlike the Caddy layer, **Vane itself is not configured via environment
variables.** AI provider API keys, model choices, and the SearxNG URL (only
relevant if you swap in an external SearxNG instance) are all set through
Vane's setup screen the first time you open it in a browser. There's nothing
to edit in `docker-compose.yml` for this.

The bundled image (`itzcrazykns1337/vane:v1.12.2`) ships with SearxNG built
in, pre-configured with the JSON response format and Wolfram Alpha engine
enabled, which Vane requires — no separate SearxNG container is needed for
the default setup.

### Connecting to a local Ollama or Lemonade server

The `vane` service has `extra_hosts: host.docker.internal:host-gateway` wired
in, so from inside the container you can reach a model server running on the
Docker host at `http://host.docker.internal:11434` (Ollama's default port) or
`http://host.docker.internal:8000` (Lemonade's default port), on Linux, Mac,
and Windows alike.

Ollama binds to `localhost` only by default, which blocks container access
even with the host mapping above. Make it listen on all interfaces:

```bash
# Linux: edit /etc/systemd/system/ollama.service, add under [Service]:
#   Environment="OLLAMA_HOST=0.0.0.0:11434"
sudo systemctl daemon-reload && sudo systemctl restart ollama
```

(On Docker Desktop for Mac/Windows, Ollama installed on the host is generally
reachable without extra configuration.) The same idea applies to Lemonade.

## Reverse proxy & HTTPS

A [Caddy](https://caddyserver.com/) container sits in front of Vane and
terminates TLS. Vane itself is **not** published to the host — it's only
reachable through the proxy on the internal Docker network — so all traffic is
encrypted end to user.

- Caddy listens on host ports **80** and **443**.
- Port 80 automatically redirects to HTTPS.
- Issued certificates and ACME state persist in the `caddy_data` volume, so
  restarts don't re-request certificates.

The proxied hostname is controlled by `VANE_DOMAIN` (in `.env`).

### Local / `localhost` (default)

With `VANE_DOMAIN=localhost`, Caddy serves HTTPS using its **internal CA**
(a locally generated root). It works immediately at <https://localhost>, but the
browser warns because that root isn't trusted yet. To remove the warning, install
Caddy's root certificate into your OS/browser trust store:

```bash
# Copy Caddy's generated root CA out of the container...
docker compose cp caddy:/data/caddy/pki/authorities/local/root.crt ./caddy-root.crt
# ...then trust it. For example, on Debian/Ubuntu:
sudo cp caddy-root.crt /usr/local/share/ca-certificates/caddy-root.crt
sudo update-ca-certificates
```

(macOS: add it to Keychain Access and mark as trusted. Windows: import into
"Trusted Root Certification Authorities".)

### Public domain (automatic Let's Encrypt)

Point a domain's DNS at this host, make sure ports 80 and 443 are reachable from
the internet, then set the domain and restart:

```bash
echo 'VANE_DOMAIN=vane.example.com' >> .env
docker compose up -d
```

Caddy will automatically obtain and renew a publicly trusted Let's Encrypt
certificate — no manual cert management. To receive expiry/problem notifications,
uncomment the `email` global option in the `Caddyfile`.

### Basic authentication

Because Vane has no login of its own yet, HTTP Basic Auth at the proxy is the
**only** access control in front of it. The password is stored as a
**bcrypt hash**, never in plaintext.

Out of the box it accepts `admin` / `changeme` (the hash baked into the
`Caddyfile` as a fallback). **Change it** by supplying your own credentials:

```bash
cp proxy-auth.env.example proxy-auth.env

# generate a hash for your password...
docker run --rm caddy:2-alpine caddy hash-password --plaintext 'your-strong-password'
# ...and put the username + hash into proxy-auth.env, then:
docker compose up -d
```

`proxy-auth.env` is git-ignored and passed to Caddy verbatim (via `env_file`), so
the hash's `$` characters need no escaping. Do not remove the `basic_auth { ... }`
block from the `Caddyfile` unless you've put some other access control in front
of this instance — without it, anyone who can reach the proxy can use your
configured AI provider keys.

### Security headers

The proxy attaches a set of hardening headers to every response (in the `header`
block of the `Caddyfile`). It uses Caddy's `defer` so these reliably override any
header Vane sets itself:

| Header | Value | Purpose |
| --- | --- | --- |
| `Strict-Transport-Security` | `max-age=31536000; includeSubDomains` | Force HTTPS for a year (HSTS). |
| `X-Content-Type-Options` | `nosniff` | Block MIME-type sniffing. |
| `X-Frame-Options` | `SAMEORIGIN` | Clickjacking protection. |
| `Referrer-Policy` | `strict-origin-when-cross-origin` | Limit cross-origin referrer leakage. |
| `X-XSS-Protection` | `0` | Disable the legacy, buggy XSS auditor. |
| `Permissions-Policy` | `geolocation=(), microphone=(), camera=()` | Turn off unused browser features. |
| `Server` | *(removed)* | Don't advertise the server software. |

> **HSTS on `localhost`:** once you trust Caddy's internal CA, the HSTS header can
> make your browser force HTTPS for *all* `localhost` apps (not just this one). If
> that interferes with other local development, remove the
> `Strict-Transport-Security` line from the `Caddyfile`.

A [Content-Security-Policy](https://developer.mozilla.org/docs/Web/HTTP/Headers/Content-Security-Policy)
is intentionally **not** set by default — a strict CSP is application-specific and
easily breaks Vane's UI. Add and tune one in the `header` block if you need it.

### Rate limiting

The proxy limits how many requests a single client IP can make, returning
**HTTP 429** (with a `Retry-After` header) once the limit is exceeded. This guards
against request floods and brute-force attempts against basic auth — and because
the limiter runs *before* basic auth, it throttles unauthenticated traffic too.

Rate limiting isn't part of stock Caddy, so the image is built from
`Caddy.Dockerfile`, which compiles in the
[`caddy-ratelimit`](https://github.com/mholt/caddy-ratelimit) module via `xcaddy`.
That's why the first start needs `docker compose up -d --build`.

The limit is per client IP and configurable in `.env`:

| Variable | Default | Description |
| --- | --- | --- |
| `RATE_LIMIT_EVENTS` | `200` | Max requests per window, per IP. |
| `RATE_LIMIT_WINDOW` | `1m` | The sliding window (e.g. `1m`, `30s`, `1h`). |

Raise `RATE_LIMIT_EVENTS` if heavy pages get throttled; lower it to tighten
protection. After changing values, `docker compose up -d` to apply. If your setup
sits behind another proxy/load balancer, configure Caddy
[`trusted_proxies`](https://caddyserver.com/docs/caddyfile/options#trusted-proxies)
so `{client_ip}` reflects the real client rather than the upstream proxy.

### Customizing the proxy

Edit the `Caddyfile` for extra behavior (extra headers, CSP, more rate-limit
zones, etc.), then apply it with `docker compose restart caddy`. To expose
Vane directly on the host as well (e.g. for debugging), add a
`ports: ["3000:3000"]` block to the `vane` service.

## Using an external SearxNG instance

If you'd rather point Vane at a SearxNG instance you already run (instead of
the bundled one), switch the image to the `slim` variant and set
`SEARXNG_API_URL` on the `vane` service in `docker-compose.yml`:

```yaml
services:
  vane:
    image: itzcrazykns1337/vane:slim-v1.12.2
    environment:
      SEARXNG_API_URL: "http://your-searxng-host:8080"
```

Your external SearxNG must have the JSON response format and the Wolfram
Alpha engine enabled — Vane requires both.

## Notes

- This is pinned to `itzcrazykns1337/vane:v1.12.2` for reproducible
  deployments. To upgrade, bump the tag in `docker-compose.yml` to a newer
  [release](https://github.com/ItzCrazyKns/Vane/releases), then run
  `docker compose pull && docker compose up -d`.
- Vane stores your AI provider API keys and search history in its persisted
  `data/` volume; nothing is sent anywhere except the providers/search
  backends you configure.
