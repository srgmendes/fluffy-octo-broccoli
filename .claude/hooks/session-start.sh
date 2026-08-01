#!/bin/bash
# SessionStart hook: ensure the `graphify` CLI is installed so the vendored
# graphify skill (.agents/skills/graphify/) can actually run its commands.
# See GRAPHIFY.md for the full rationale. Idempotent and non-interactive.
set -euo pipefail

# Only run in Claude Code on the web / remote sessions; local machines manage
# their own tools (and this avoids surprising installs on a dev's laptop).
if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

# uv tool / pip --user both drop executables here; make sure it's on PATH for
# both this hook and the session that follows.
BIN_DIR="$HOME/.local/bin"
export PATH="$BIN_DIR:$PATH"
if [ -n "${CLAUDE_ENV_FILE:-}" ]; then
  echo "export PATH=\"$BIN_DIR:\$PATH\"" >> "$CLAUDE_ENV_FILE"
fi

# Already installed? Nothing to do (keeps re-runs fast and cache-friendly).
if command -v graphify >/dev/null 2>&1; then
  echo "graphify already installed: $(graphify --version 2>/dev/null || echo present)"
  exit 0
fi

# Prefer uv (fast, isolated tool env); fall back to pipx, then pip --user.
if command -v uv >/dev/null 2>&1; then
  uv tool install graphifyy
elif command -v pipx >/dev/null 2>&1; then
  pipx install graphifyy
else
  python3 -m pip install --user graphifyy
fi

command -v graphify >/dev/null 2>&1 && echo "graphify installed: $(graphify --version)"
