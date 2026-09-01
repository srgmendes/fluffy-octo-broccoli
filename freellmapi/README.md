# FreeLLMAPI

Self-hosted deployment of [FreeLLMAPI](https://github.com/tashfeenahmed/freellmapi)
— an OpenAI-compatible gateway that aggregates the free tiers of ~34 LLM
providers (Google, Groq, Cerebras, Mistral, OpenRouter, Cloudflare, Cohere,
NVIDIA, HuggingFace, …) behind a single `/v1` endpoint. It stores your provider
keys encrypted, routes each request to the best available model, falls over to
the next provider when one is rate-limited, and tracks per-key usage so you stay
under every free-tier cap.

Like `stirling-pdf/`, this directory holds **no application code** — only the
Docker Compose config to run the upstream prebuilt image. The upstream repo is
the source of truth for the app itself; its
[install guide](https://github.com/tashfeenahmed/freellmapi/blob/main/docs/install.md)
and [API reference](https://github.com/tashfeenahmed/freellmapi/blob/main/docs/api.md)
cover everything not specific to this deployment.

## Requirements

- Docker + Docker Compose
- OpenSSL (to generate the encryption key)

## First start

```bash
cd freellmapi
cp .env.example .env

# Generate the at-rest encryption key and put it in .env, replacing the placeholder
printf 'ENCRYPTION_KEY=%s\n' "$(openssl rand -hex 32)"

docker compose up -d
```

Then open <http://localhost:3001>:

1. **Keys** page — paste the provider API keys you want to pool. Each provider's
   free tier is signed up for separately, on that provider's own site.
2. Reorder the **Fallback Chain** so the router prefers the models you want.
3. Copy the **unified API key** from the Keys page header — that single key is
   what your OpenAI client authenticates with.

Point any OpenAI-compatible client at it:

```bash
curl http://localhost:3001/v1/chat/completions \
  -H "Authorization: Bearer <your-unified-key>" \
  -H "Content-Type: application/json" \
  -d '{"model":"auto","messages":[{"role":"user","content":"hello"}]}'
```

The same base URL works for the OpenAI SDKs (`base_url="http://localhost:3001/v1"`)
and for coding agents that accept an OpenAI-compatible endpoint.

## Common operations

```bash
cd freellmapi
docker compose up -d          # start (pulls the pinned image on first run)
docker compose logs -f        # follow logs
docker compose ps             # status, including the healthcheck
docker compose restart        # restart after an .env change
docker compose down           # stop and remove the container (data volume kept)
docker compose down -v        # ALSO delete the data volume — wipes stored keys
```

## Configuration

All runtime tuning goes through `.env` (see `.env.example` for the annotated
list). Prefer adding a variable there over editing `docker-compose.yml`.

- **`ENCRYPTION_KEY` is required.** It encrypts your provider keys at rest.
  Losing or changing it makes every stored key undecryptable — back it up.
- **Not exposed by default.** The port is published on `127.0.0.1` only.
  FreeLLMAPI is single-user and guarded solely by its unified API key, so it
  must not face the internet. `HOST_BIND=0.0.0.0` opens it to a *trusted* LAN.
- **Data lives in a named Docker volume** (`freellmapi-data`, mounted at
  `/app/server/data`) — the SQLite database with your encrypted keys, usage
  counters, and request analytics. It survives `docker compose down`; only
  `down -v` destroys it.
- **Outbound proxy:** inside the container `127.0.0.1` is the container itself.
  To use a proxy running on the host, set
  `PROXY_URL=socks5h://host.docker.internal:7890` — `docker-compose.yml` maps
  `host.docker.internal` to the host gateway so this also works on plain Linux
  Docker, not just Docker Desktop.

## Updating

The image is **pinned by release tag** (`v0.9.0`) rather than tracking
`latest`, matching the repo-wide convention. To upgrade, bump the tag in
`docker-compose.yml` and the version reference in this README, then:

```bash
docker compose pull && docker compose up -d
```

Releases: <https://github.com/tashfeenahmed/freellmapi/releases>.

Note that the app updates its *model catalog* on its own from a signed feed, so
new free models and quota changes arrive without an image bump.

## Sandbox caveat

In the Claude Code cloud sandbox, the egress policy must allow
`ghcr.io` (to pull the image), `freellmapi.co` (the signed model catalog feed),
and every provider API host you add a key for (e.g.
`generativelanguage.googleapis.com`, `api.groq.com`, `openrouter.ai`).
To check what the container can actually reach:

```bash
docker compose exec freellmapi node -e \
  "fetch('https://api.groq.com/').then(r=>console.log('ok',r.status)).catch(e=>console.log('fail',e.cause?.code||e.message))"
```

## Upstream

- Repo: <https://github.com/tashfeenahmed/freellmapi> (MIT)
- Site & model catalog: <https://freellmapi.co>

A read-only clone for browsing the source:

```bash
git clone https://github.com/tashfeenahmed/freellmapi.git
```

Local development against the source (Node 20+, `npm run dev`) is documented
upstream; this directory deliberately only covers the container deployment.
