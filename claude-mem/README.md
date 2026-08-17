# claude-mem

Setup docs for [claude-mem](https://github.com/thedotmack/claude-mem) — a
persistent memory system for Claude Code and other coding agents. It captures
what happens during a session, compresses it with AI, and injects relevant
context back into future sessions so context survives across `/clear` and new
conversations. This directory has no application code of its own; it just
documents how to install and use the `claude-mem` CLI locally.

## What it does

claude-mem installs itself as a Claude Code plugin: it registers `SessionStart`,
`UserPromptSubmit`, `PostToolUse`, `Stop`, and `SessionEnd` hooks in your
user-level Claude Code config, then runs a local worker (Bun) that stores
observations in SQLite under `~/.claude-mem/` and serves them back through a
local HTTP API (with a web viewer UI) that the hooks query for relevant
context.

Everything runs locally by default; cloud sync to `cmem.ai` and optional
Telegram/Discord/Slack observation feeds are opt-in extras, not required for
basic use.

## Requirements

- Node.js 20.12.0+ (for `npx`)
- Claude Code with plugin support
- [Bun](https://bun.sh/) 1.0.0+ — auto-installed by the installer if missing
- [`uv`](https://docs.astral.sh/uv/) — auto-installed by the installer if
  missing
- SQLite 3 — bundled, no separate install needed

## Install

```bash
cd claude-mem
./install.sh          # npx claude-mem install
```

This runs the upstream installer, which auto-creates
`~/.claude-mem/settings.json` and registers the plugin hooks in your Claude
Code user config. Extra flags are passed straight through, e.g. to target a
different IDE integration:

```bash
./install.sh --ide opencode
./install.sh --ide antigravity
```

Verify:

```bash
npx claude-mem --version
```

Alternative install paths (see the
[upstream README](https://github.com/thedotmack/claude-mem#readme) for
details):

```bash
# Via Claude Code's plugin marketplace instead of npx
/plugin marketplace add thedotmack/claude-mem
/plugin install claude-mem
```

## Configuration

Settings live in `~/.claude-mem/settings.json` (auto-created on first run) —
this is a **user-level** config directory outside this repo, not something
tracked here. Key settings include the AI model used for compression, the
worker port, the data directory, log level, and context-injection behavior.
For example, to switch the workflow language:

```json
{
  "CLAUDE_MEM_MODE": "code--zh"
}
```

## Updating / uninstalling

```bash
npx claude-mem update          # upgrade to the latest version
npx claude-mem uninstall       # remove hooks, worker, and (optionally) data
npx claude-mem uninstall --yes # skip the confirmation prompt
```

## Sandbox caveat

The installer needs network egress to `registry.npmjs.org` (to fetch the
`claude-mem` package and its Bun/uv dependencies) and, if cloud sync is
enabled, to `cmem.ai`. In the Claude Code cloud sandbox, make sure the
sandbox's egress policy allows those domains before running `install.sh`.
Because claude-mem writes to `~/.claude-mem/` and to your user-level Claude
Code settings rather than anywhere in this repo, its state does not need to
be (and should not be) git-ignored here.
