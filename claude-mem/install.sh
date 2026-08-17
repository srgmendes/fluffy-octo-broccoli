#!/usr/bin/env bash
# Installs claude-mem (https://github.com/thedotmack/claude-mem) — a persistent
# memory system for Claude Code. It registers SessionStart / UserPromptSubmit /
# PostToolUse / Stop / SessionEnd hooks in your user-level Claude Code config
# and runs a local worker (Bun) backed by SQLite to capture and replay context
# across sessions.
#
# Usage:
#   ./install.sh
#
# This only wraps the upstream installer (`npx claude-mem install`) — it does
# not vendor any claude-mem source. Requirements: Node.js 20.12.0+. The
# installer auto-installs Bun and uv if they're missing.

set -euo pipefail

if ! command -v npx >/dev/null 2>&1; then
  echo "npx (Node.js 20.12.0+) not found. Install Node.js first." >&2
  exit 1
fi

npx claude-mem install "$@"

npx claude-mem --version
