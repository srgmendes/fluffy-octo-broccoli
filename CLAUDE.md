# CLAUDE.md

Guidance for AI assistants (and humans) working in this repository.

## What this project is

A minimal Node.js project that demonstrates how to use the
[Composio SDK](https://www.npmjs.com/package/@composio/core) (`@composio/core`)
to connect to Composio and manage app integrations **from code** — specifically
inside the Claude Code cloud sandbox, where the Composio CLI cannot run.

It is not an application or library with its own domain logic. Think of it as a
small, well-documented example/scaffold: two runnable scripts plus setup docs.
Keep additions in that spirit — small, self-explanatory, and sandbox-friendly.

## Why the SDK instead of the Composio CLI

The Composio CLI (`composio login`) does not work in the Claude Code cloud
sandbox: its binary is distributed only via GitHub releases that the sandbox's
GitHub proxy blocks, and `composio login` needs a browser the sandbox lacks.
This repo therefore uses the SDK, which works entirely in code with just an API
key. Do not add workflows that depend on the interactive CLI for sandbox use;
see `COMPOSIO.md` for the full rationale.

## Repository layout

```
.
├── composio-example.mjs   # Lists the toolkits available to your account (connectivity smoke test)
├── composio-connect.mjs   # Connects an app (toolkit) to your account via OAuth
├── COMPOSIO.md            # Human-facing setup + usage guide for Composio
├── package.json           # ESM project; single dep @composio/core
├── package-lock.json
├── .env.example           # Template for COMPOSIO_API_KEY (copy to .env)
├── .gitignore             # Ignores node_modules/, .env, *.log
├── skills-lock.json       # Lockfile for skills installed via `npx skills`
└── .agents/skills/        # Installed agent skills (find-skills, research)
```

There is no `src/`, no build step, and no test suite (`npm test` is a
placeholder that intentionally exits 1).

## Conventions

- **ES modules only.** `package.json` sets `"type": "module"`; all scripts use
  `.mjs` and `import` syntax. Do not introduce CommonJS (`require`).
- **Top-level `await`** is used and expected in the scripts.
- **No secrets in git.** API keys come from the environment (`COMPOSIO_API_KEY`),
  loaded from a git-ignored `.env`. Never hardcode or commit a key. Update
  `.env.example` (with a placeholder) when adding a new required variable.
- **Scripts are self-documenting.** Each `.mjs` file opens with a comment block
  explaining what it does and exactly how to run it, including the sandbox proxy
  flag. Match this style for any new script.
- **Fail loudly and early.** Both scripts validate required inputs up front and
  `process.exit(1)` with a helpful usage message when something is missing.

## Development workflow

Install dependencies:

```bash
npm install
```

Run the connectivity check (lists your account's toolkits):

```bash
COMPOSIO_API_KEY=your_key node composio-example.mjs
```

Connect an app via OAuth (prints a login link, then waits for it to go ACTIVE):

```bash
COMPOSIO_API_KEY=your_key node composio-connect.mjs <toolkit> [userId]
# e.g.
COMPOSIO_API_KEY=your_key node composio-connect.mjs outlook you@example.com
```

`composio-connect.mjs` reuses an existing Composio-managed auth config for the
toolkit if one exists, otherwise creates one — so it needs an API key with
**write** access to `auth_configs` (a read-only key will fail at that step).

### Running inside the Claude Code cloud sandbox

Node's built-in `fetch` does not use the sandbox's network proxy by default. Add
`NODE_USE_ENV_PROXY=1` to route Composio's HTTPS calls through the proxy:

```bash
COMPOSIO_API_KEY=your_key NODE_USE_ENV_PROXY=1 node composio-example.mjs
```

This flag is only needed in the sandbox — on a normal machine the plain command
works. The sandbox's network egress must also allow `composio.dev` and
`*.composio.dev` (the SDK talks to `backend.composio.dev`).

## Composio SDK notes

- Entry point: `import { Composio } from '@composio/core'` →
  `new Composio({ apiKey })`.
- List integrations: `composio.toolkits.get({})` — responses may be `{ items }`
  or a bare array, so the scripts normalize with `res.items ?? res`. Keep that
  defensive pattern when reading SDK responses.
- Connect flow: `authConfigs.list()` / `authConfigs.create(slug, { type:
  'use_composio_managed_auth' })` → `connectedAccounts.link(userId,
  authConfigId)` → open `redirectUrl` → `connectedAccounts.waitForConnection(id)`.
- Using Composio-managed auth means you don't register your own
  Microsoft/Google/etc. OAuth app.

## Agent skills

Skills are installed with the Skills CLI (`npx skills`) into `.agents/skills/`
and tracked in `skills-lock.json`. Currently installed:

- **find-skills** (`vercel-labs/skills`) — discover and install skills from the
  open ecosystem.
- **research** (`mattpocock/skills`) — spin up a background agent to research a
  question against primary sources and save findings as Markdown.

To add another skill, prefer the CLI so the lockfile stays accurate:

```bash
npx skills add <owner/repo@skill> -g -y
```

## Git & PR conventions

- Branch naming in use follows `claude/<topic>-<suffix>` (see existing branches).
- Commit messages are short, imperative, and describe the change
  (e.g. "Add reusable Composio OAuth connect script").
- Keep changes scoped and the repo runnable; there is no CI or test gate, so the
  bar is that the example scripts still run cleanly.
