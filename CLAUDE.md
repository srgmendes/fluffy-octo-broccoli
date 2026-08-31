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
| **Ponytail skills** | repo root (`PONYTAIL.md`), `.agents/skills/ponytail*/` | Vendored "lazy senior dev mode" skills (from the `DietrichGebert/ponytail` plugin) that push agents toward the simplest solution that works. |
| **LLM Council app** | `llm-council/` | Vendored local web app (FastAPI backend + React/Vite frontend) that queries a "council" of LLMs via OpenRouter, has them peer-review each other anonymously, and a chairman model synthesizes a final answer. |
| **Agent skills** | `.agents/skills/`, `.claude/skills/`, `skills-lock.json` | Vendored third-party Claude skills (`find-skills`, `research`, `ponytail*`) pinned by hash or version. |
| **ECC agent harness** | `.claude/` (agents, skills, commands, rules, hooks, scripts) | [ECC](https://github.com/affaan-m/ECC) 2.2.0 installed project-locally via its `claude-project` target (`full` profile, hooks enabled). Generated config, not hand-written. |
| **yt-dlp CLI** | `yt-dlp/` | Setup docs + install script for the [yt-dlp](https://github.com/yt-dlp/yt-dlp) media-downloader CLI. No application code — a local tool, not a hosted service. |

When asked to work on something, first figure out **which area** it belongs to;
changes rarely cross these boundaries.

## Repository layout

```
.
├── COMPOSIO.md              # Composio setup & usage docs
├── PONYTAIL.md              # Ponytail vendored-skills docs
├── composio-example.mjs     # Lists Composio toolkits (smoke test for SDK + key)
├── composio-connect.mjs     # Connects an app/toolkit to your account via OAuth
├── package.json             # ESM Node project; depends on @composio/core
├── .env.example             # Template for COMPOSIO_API_KEY (root scope)
├── skills-lock.json         # Pins vendored agent skills by source + hash
├── .agents/skills/          # Vendored skill sources (find-skills, research, ponytail*)
├── .claude/                 # Claude Code config: hand-maintained symlinks + generated ECC install
│   ├── skills/              # 9 symlinks into .agents/skills + 286 ECC skill dirs
│   ├── agents/              # 68 ECC subagents (generated)
│   ├── commands/            # 94 ECC slash commands (generated)
│   ├── rules/ecc/           # 122 ECC rule files (generated)
│   ├── hooks/hooks.json     # ECC hook runtime wiring (generated)
│   ├── scripts/             # ECC runtime + 53 hook scripts (generated)
│   ├── mcp-configs/         # ECC MCP server templates, placeholder creds only
│   └── ecc/install-state.json  # Git-ignored: machine-specific install record
├── stirling-pdf/            # Self-contained Docker Compose deployment
│   ├── docker-compose.yml   # Stirling-PDF (pinned 2.14.2) + Caddy proxy
│   ├── Caddyfile            # Proxy config: HTTPS, basic auth, headers, rate limit
│   ├── Caddy.Dockerfile     # Builds Caddy with the caddy-ratelimit module
│   ├── .env.example         # Admin creds, domain, rate-limit knobs
│   ├── proxy-auth.env.example  # Proxy basic-auth username + bcrypt hash
│   ├── README.md            # Full operator documentation
│   └── data/                # Runtime state (git-ignored except structure)
├── llm-council/             # Vendored FastAPI + React OpenRouter app (karpathy/llm-council)
│   ├── pyproject.toml       # Python deps (FastAPI, httpx, pydantic); pinned in uv.lock
│   ├── uv.lock              # Pinned Python dependency lockfile
│   ├── main.py              # Trivial entrypoint stub (real app is backend.main)
│   ├── start.sh             # Launches backend (:8001) + frontend dev server (:5173)
│   ├── .env.example         # Template for OPENROUTER_API_KEY (llm-council scope)
│   ├── README.md            # Upstream project docs (setup & running)
│   ├── CLAUDE.md            # Upstream architecture / implementation notes
│   ├── backend/             # FastAPI app: config, openrouter client, council logic, storage
│   └── frontend/            # React + Vite UI (npm; deps pinned in package-lock.json)
└── yt-dlp/                  # Setup docs + install script for the yt-dlp CLI
    ├── README.md            # Install, update, and usage instructions
    ├── install.sh           # pipx install yt-dlp (falls back to pip3 install --user)
    └── downloads/           # Git-ignored scratch spot for local downloads
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

## yt-dlp CLI (`yt-dlp/`)

Setup docs for the [yt-dlp](https://github.com/yt-dlp/yt-dlp) CLI — a
command-line media downloader. Unlike the other areas, this isn't application
code or a hosted service; it's just an `install.sh` wrapper and a README
documenting how to install, update, and use the `yt-dlp` command locally.
`yt-dlp/README.md` is the source of truth for usage.

```bash
cd yt-dlp
./install.sh          # pipx install yt-dlp (falls back to pip3 install --user)
```

- Installs via `pipx` (falls back to `pip3 install --user`); requires Python
  3.9+ and, optionally, `ffmpeg` for merging streams / extracting audio.
- `downloads/` is a git-ignored scratch spot for local output (same
  `.gitkeep`-plus-`.gitignore` pattern as `stirling-pdf/data/`).
- Sandbox caveat: downloading needs network egress to whatever site is being
  pulled from (e.g. `youtube.com`, `googlevideo.com`) — allow those domains in
  the sandbox egress policy first.

## ECC agent harness (`.claude/`)

[ECC](https://github.com/affaan-m/ECC) is an agent harness — a bundle of
subagents, skills, slash commands, rules, and hooks for Claude Code. It is
installed **project-locally** into `.claude/`, so it applies to anyone running
Claude Code in this repo and to no other project.

- **Version 2.2.0**, installed from the upstream repo at commit `005eff4`
  using ECC's own installer:

  ```bash
  node <ecc-checkout>/scripts/install-apply.js \
      --target claude-project --profile full --enable-hooks
  ```

  `--target claude-project` writes to `./.claude/` instead of `~/.claude/`.
  `--profile full` selects every classified module; `--enable-hooks` is ECC's
  required explicit consent for the automatic hook runtime.
- **Everything under `.claude/` except the `skills/*` symlinks is generated.**
  Don't hand-edit it — re-run the installer (a newer ECC checkout, same flags)
  and commit the diff. Adding `--dry-run --json` prints the plan without
  touching the tree.
- **Installed surface:** 68 agents, 286 skills, 94 commands, 122 rules,
  53 hook scripts, plus `mcp-configs/mcp-servers.json` (placeholder
  credentials only — fill them in locally, never commit real ones).
- **Hooks are live.** `.claude/hooks/hooks.json` wires PreToolUse / PostToolUse
  / SessionStart / Stop hooks to the Node and Python scripts in
  `.claude/scripts/hooks/`. They run automatically in Claude Code sessions here.
  To install without them, re-run with `--no-hooks` instead of `--enable-hooks`.
- **`.claude/ecc/install-state.json` is git-ignored.** It is a 548 KB record of
  1048 absolute paths under this checkout's directory — machine-specific runtime
  state, regenerated on every install, matching the repo's convention of not
  committing runtime data.
- **No collisions with the vendored skills.** ECC's 286 skill directories and
  the 9 existing `.claude/skills/*` symlinks have disjoint names; the installer
  applied 1048 operations with zero skipped and zero overwrites.

## Agent skills (`.agents/`, `.claude/`, `skills-lock.json`)

Third-party Claude skills are **vendored** into this repo, not fetched at
runtime:

- `skills-lock.json` pins each skill by `source` (GitHub repo), `skillPath`, and
  a `computedHash` for integrity.
- The skill sources live under `.agents/skills/<name>/`.
- `.claude/skills/<name>` are **symlinks** into `.agents/skills/` so Claude Code
  discovers them.

Currently present: `find-skills` (from `vercel-labs/skills`) and `research`
(from `mattpocock/skills`), both vendored from GitHub and tracked in
`skills-lock.json`; plus `chief-content-officer`, a **local** skill added
directly to the repo (not from a GitHub source, so it has no `skills-lock.json`
entry); plus the six `ponytail*` skills (`ponytail`, `ponytail-review`,
`ponytail-audit`, `ponytail-debt`, `ponytail-gain`, `ponytail-help`) vendored
from the `DietrichGebert/ponytail` **plugin** (see `PONYTAIL.md`). Because the
ponytail skills come from a plugin's `skills/` dir rather than a single-`SKILL.md`
GitHub skill installed via the `skills` CLI, they have **no `skills-lock.json`
entry** — their version is pinned instead by
`.agents/skills/ponytail/.ponytail_version`.

When adding or updating a GitHub-vendored skill installed through the `skills`
CLI, update `skills-lock.json` (including the hash) alongside the files. When
adding a local or plugin-/package-provided skill, just place `SKILL.md` under
`.agents/skills/<name>/` and create the matching `.claude/skills/<name>` symlink
— no lockfile entry. Either way, keep the `.claude/skills` symlink in place.

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
