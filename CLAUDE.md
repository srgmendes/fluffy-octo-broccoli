# CLAUDE.md

Guidance for AI assistants (Claude Code and others) working in this repository.

## What this repository is

`fluffy-octo-broccoli` is **not a single application** — it is a small
collection of independent, self-hosting and integration setups that live side by
side. There is no shared build, no unified entry point, and the top-level
`package.json` `main`/`test` fields are placeholders. Treat each top-level piece
as its own mini-project:

| Area | Location | What it is |
| --- | --- | --- |
| **Composio integration** | repo root (`composio-*.mjs`, `COMPOSIO.md`) | Node.js (ESM) scripts that use the Composio SDK to connect third-party apps (Outlook, etc.) via OAuth and list toolkits. |
| **Stirling-PDF deployment** | `stirling-pdf/` | Docker Compose stack running self-hosted Stirling-PDF behind a Caddy reverse proxy (HTTPS, basic auth, security headers, rate limiting). |
| **LLM Council app** | `llm-council/` | Vendored local web app (FastAPI backend + React/Vite frontend) that queries a "council" of LLMs via OpenRouter, has them peer-review each other anonymously, and a chairman model synthesizes a final answer. |
| **Agent skills** | `.agents/skills/`, `.claude/skills/`, `skills-lock.json` | Vendored third-party Claude skills (`find-skills`, `research`, `prompt-optimizer`) pinned by hash. |

When asked to work on something, first figure out **which area** it belongs to;
changes rarely cross these boundaries.

## Repository layout

```
.
├── COMPOSIO.md              # Composio setup & usage docs
├── composio-example.mjs     # Lists Composio toolkits (smoke test for SDK + key)
├── composio-connect.mjs     # Connects an app/toolkit to your account via OAuth
├── package.json             # ESM Node project; depends on @composio/core
├── .env.example             # Template for COMPOSIO_API_KEY (root scope)
├── skills-lock.json         # Pins vendored agent skills by source + hash
├── .agents/skills/          # Vendored skill sources (find-skills, research, prompt-optimizer)
├── .claude/skills/          # Symlinks into .agents/skills so Claude Code sees them
├── stirling-pdf/            # Self-contained Docker Compose deployment
│   ├── docker-compose.yml   # Stirling-PDF (pinned 2.14.2) + Caddy proxy
│   ├── Caddyfile            # Proxy config: HTTPS, basic auth, headers, rate limit
│   ├── Caddy.Dockerfile     # Builds Caddy with the caddy-ratelimit module
│   ├── .env.example         # Admin creds, domain, rate-limit knobs
│   ├── proxy-auth.env.example  # Proxy basic-auth username + bcrypt hash
│   ├── README.md            # Full operator documentation
│   └── data/                # Runtime state (git-ignored except structure)
└── llm-council/             # Vendored FastAPI + React OpenRouter app (karpathy/llm-council)
    ├── pyproject.toml       # Python deps (FastAPI, httpx, pydantic); pinned in uv.lock
    ├── uv.lock              # Pinned Python dependency lockfile
    ├── main.py              # Trivial entrypoint stub (real app is backend.main)
    ├── start.sh             # Launches backend (:8001) + frontend dev server (:5173)
    ├── .env.example         # Template for OPENROUTER_API_KEY (llm-council scope)
    ├── README.md            # Upstream project docs (setup & running)
    ├── CLAUDE.md            # Upstream architecture / implementation notes
    ├── backend/             # FastAPI app: config, openrouter client, council logic, storage
    └── frontend/            # React + Vite UI (npm; deps pinned in package-lock.json)
```

## Composio integration (repo root)

Node.js **ESM** project (`"type": "module"`, so files use `.mjs` / `import`).
The single runtime dependency is [`@composio/core`](https://www.npmjs.com/package/@composio/core).

**Why the SDK and not the CLI:** the Composio CLI (`composio login`) can't run in
the Claude Code cloud sandbox — its binary is only on GitHub releases (blocked by
the sandbox proxy) and login needs a browser. So everything here is code-driven
with just an API key. See `COMPOSIO.md` for the full rationale.

### Setup

```bash
npm install                     # install @composio/core
cp .env.example .env            # then edit .env, paste a real COMPOSIO_API_KEY
```

Get the key from https://app.composio.dev (Settings → API Keys). `.env` is
git-ignored.

### Running the scripts

```bash
# Smoke test — lists toolkits available to your account:
COMPOSIO_API_KEY=your_key node composio-example.mjs

# Connect an app via OAuth (prints a login link, waits until ACTIVE):
COMPOSIO_API_KEY=your_key node composio-connect.mjs <toolkit> [userId]
# e.g. ... node composio-connect.mjs outlook you@example.com
```

**Sandbox caveat:** inside the Claude Code cloud sandbox, Node's built-in `fetch`
does not use the proxy by default. Prefix commands with `NODE_USE_ENV_PROXY=1`:

```bash
COMPOSIO_API_KEY=your_key NODE_USE_ENV_PROXY=1 node composio-example.mjs
```

This is only needed in the sandbox; on a normal machine the plain command works.
The sandbox's egress settings must also allow `composio.dev` / `*.composio.dev`
(the SDK talks to `backend.composio.dev`).

**Note:** `composio-connect.mjs` needs an API key with **write** access to
`auth_configs`; a read-only key can't create the auth config.

## Stirling-PDF deployment (`stirling-pdf/`)

A fully self-contained Docker Compose stack — no application code, only
infrastructure config. `stirling-pdf/README.md` is the authoritative operator
guide; read it before changing anything here. Key facts:

- **Two services:** `stirling-pdf` (official prebuilt image, pinned to
  `2.14.2`) and `caddy` (reverse proxy). Stirling-PDF is **not** published to the
  host — it's only reachable through Caddy on the internal Docker network.
- **Caddy is a custom build.** `Caddy.Dockerfile` compiles the
  `caddy-ratelimit` module into Caddy via `xcaddy` (rate limiting isn't in stock
  Caddy). This is why the first start needs `docker compose up -d --build`.
- **Layered auth:** the Caddy proxy enforces HTTP Basic Auth (bcrypt hash) in
  front of Stirling-PDF's own login. Rate limiting runs *before* basic auth, so
  it also throttles unauthenticated brute-force attempts.
- **HTTPS everywhere:** Caddy terminates TLS — internal CA on `localhost`,
  automatic Let's Encrypt for a public domain (via `STIRLING_DOMAIN`).

### Common operations

```bash
cd stirling-pdf
cp .env.example .env               # set STIRLING_ADMIN_USERNAME / _PASSWORD, domain
docker compose up -d --build       # first start (builds custom Caddy image)
docker compose up -d               # subsequent starts (no rebuild needed)
docker compose logs -f             # follow logs
docker compose pull && docker compose up -d   # update Stirling-PDF image
docker compose down                # stop and remove
```

Rebuild the Caddy image (`--build`) only after changing `Caddy.Dockerfile`.
After editing just the `Caddyfile`, `docker compose restart caddy` is enough.

### Configuration conventions

- Runtime tuning is done through **environment variables** in
  `docker-compose.yml` (app settings) and `.env` (secrets, domain, rate-limit
  values). Prefer adding a variable over hardcoding.
- **Secrets never get committed.** `.env` and `proxy-auth.env` are git-ignored;
  only their `.example` templates are tracked. The bcrypt proxy hash lives in
  `proxy-auth.env` (or as a baked-in fallback in the `Caddyfile`).
- `data/` holds runtime state (OCR language files, configs, logs, pipelines).
  Its `.gitignore` keeps the directory structure (`.gitkeep` files) but ignores
  all real contents — don't commit runtime data.
- The Stirling-PDF image is **pinned by tag** for reproducibility. To upgrade,
  bump the tag in `docker-compose.yml` and update the version references in
  `README.md` to match.

## LLM Council app (`llm-council/`)

A **vendored** copy of [`karpathy/llm-council`](https://github.com/karpathy/llm-council)
— a self-contained local web app, unrelated to the other areas. It sends one
query to a configurable "council" of LLMs through **OpenRouter**, has each model
anonymously review and rank the others' answers, then a chairman model
synthesizes a final response. Two processes: a **FastAPI** backend and a
**React + Vite** frontend. `llm-council/README.md` is the upstream setup guide
and `llm-council/CLAUDE.md` holds the upstream architecture notes — read those
before changing anything inside.

- **Vendored, not a submodule.** The code was copied in with its own git history
  stripped; there is no `skills-lock.json`-style pin. To update, re-pull from
  upstream and review the diff. Upstream is explicitly unmaintained ("provided as
  is"), so treat this snapshot as the source of truth.
- **Dependencies are pinned.** Python via `uv.lock` (managed with
  [uv](https://docs.astral.sh/uv/)); frontend via `frontend/package-lock.json`
  (npm). Backend needs Python ≥ 3.10 (`.python-version` pins 3.10).
- **Ports:** backend on **8001**, frontend dev server on **5173** (Vite). CORS in
  `backend/main.py` allows `localhost:5173` / `localhost:3000`.
- **Model config** lives in `backend/config.py` (`COUNCIL_MODELS`,
  `CHAIRMAN_MODEL`) — edit there to change the council.

### Setup & running

```bash
cd llm-council
uv sync                            # install Python backend deps
cp .env.example .env               # then paste a real OPENROUTER_API_KEY
(cd frontend && npm install)       # install frontend deps
./start.sh                         # runs backend (:8001) + frontend (:5173)
# then open http://localhost:5173
```

### Configuration conventions

- **Secrets never get committed.** `.env` (holding `OPENROUTER_API_KEY`) is
  git-ignored by `llm-council/.gitignore`; only `.env.example` is tracked —
  mirroring the repo-wide `*.example` pattern. Get a key at
  [openrouter.ai](https://openrouter.ai/).
- `data/` (JSON conversation storage under `data/conversations/`) is runtime
  state and is git-ignored — don't commit it.
- Sandbox caveat: OpenRouter calls (`openrouter.ai`) must be allowed by the
  sandbox egress policy, and the frontend/backend dev servers bind to localhost.

## Agent skills (`.agents/`, `.claude/`, `skills-lock.json`)

Third-party Claude skills are **vendored** into this repo, not fetched at
runtime:

- `skills-lock.json` pins each skill by `source` (GitHub repo), `skillPath`, and
  a `computedHash` for integrity.
- The skill sources live under `.agents/skills/<name>/`.
- `.claude/skills/<name>` are **symlinks** into `.agents/skills/` so Claude Code
  discovers them.

Currently present: `find-skills` (from `vercel-labs/skills`), `research`
(from `mattpocock/skills`), and `prompt-optimizer` (from
`geq1fan/prompt-optimizer-skill`), all vendored from GitHub and tracked in
`skills-lock.json`; plus `chief-content-officer`, a **local** skill added
directly to the repo (not from a GitHub source, so it has no `skills-lock.json`
entry).

`prompt-optimizer` drives its `/optimize-prompt` workflow through a companion
Wails desktop WebView binary that the upstream project distributes as a
platform-specific GitHub Release asset (see `bin/.gitkeep` in the vendored
skill — only the placeholder is tracked here). That binary is not vendored
into this repo; per the upstream `README.md`, run its `install.sh` /
`install.ps1` to fetch it if the interactive WebView review step is needed.
Without it, the skill's own fallback (see its `SKILL.md`) is to skip the
WebView step and output results directly.

When adding or updating a GitHub-vendored skill, update `skills-lock.json`
(including the hash) alongside the files. When adding a local skill, just place
`SKILL.md` under `.agents/skills/<name>/` and create the matching
`.claude/skills/<name>` symlink — no lockfile entry. Either way, keep the
`.claude/skills` symlink in place.

## Conventions & workflow

- **JavaScript is ESM.** Use `import`/`export` and `.mjs`; the root
  `package.json` sets `"type": "module"`. Match the existing terse,
  heavily-commented style of the `composio-*.mjs` scripts (top-of-file usage
  comments explaining flags and sandbox caveats).
- **Documentation lives next to what it documents** — `COMPOSIO.md` at root,
  `stirling-pdf/README.md` in that directory. When you change behavior, update
  the corresponding doc in the same commit. This CLAUDE.md is a map; the
  per-area docs are the source of truth for details.
- **Secrets discipline:** never commit real credentials or API keys. Add new
  secret-bearing config as a `*.example` template + a git-ignore entry, mirroring
  the existing `.env.example` / `proxy-auth.env.example` pattern.
- **Pin external dependencies** (Docker image tags, skill hashes, module
  versions) for reproducibility rather than tracking `latest`.
- There is **no test suite or linter** configured. `npm test` is a placeholder
  that exits non-zero. Verify Composio changes by running the scripts against a
  real key; verify Stirling-PDF changes with `docker compose config` (validates
  the compose file) and a local `docker compose up`.

## Git & contribution workflow

- Development happens on feature branches named `claude/<topic>-<suffix>`, which
  are merged into the default branch via pull requests (see the git history —
  each feature landed as its own PR).
- Keep commits focused and descriptively messaged; one logical change per commit,
  matching the existing history (e.g. "Add per-IP rate limiting to the Caddy
  reverse proxy").
- Always push to the designated feature branch, open a PR as ready for review,
  and never push directly to the default branch.
