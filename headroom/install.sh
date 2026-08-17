#!/usr/bin/env bash
# Installs the headroom CLI (https://github.com/headroomlabs-ai/headroom) via
# pipx, falling back to `pip install --user` if pipx isn't available.
#
# Usage:
#   ./install.sh
#
# Requirements: Python 3.10+. The `[all]` extra pulls in the optional
# ML/embedder dependencies used by some compressors; drop it below for a
# lighter install if you don't need them.

set -euo pipefail

PACKAGE='headroom-ai[all]'

if command -v pipx >/dev/null 2>&1; then
  pipx install "$PACKAGE"
elif command -v pip3 >/dev/null 2>&1; then
  echo "pipx not found; falling back to 'pip3 install --user $PACKAGE'" >&2
  pip3 install --user "$PACKAGE"
else
  echo "Neither pipx nor pip3 found. Install Python 3.10+ first." >&2
  exit 1
fi

headroom --version
