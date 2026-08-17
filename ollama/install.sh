#!/usr/bin/env bash
# Installs the Ollama CLI (https://github.com/ollama/ollama) — a local runtime
# for running open-weight LLMs on your own machine.
#
# Usage:
#   ./install.sh
#
# Uses the official install script on Linux (curl | sh, matching upstream's
# documented method). On macOS, prefers Homebrew if available; otherwise
# points to the manual .dmg download since ollama.com has no piped installer
# for macOS. Windows isn't supported by this script — see README.md.

set -euo pipefail

os="$(uname -s)"

case "$os" in
  Linux)
    curl -fsSL https://ollama.com/install.sh | sh
    ;;
  Darwin)
    if command -v brew >/dev/null 2>&1; then
      brew install ollama
    else
      echo "Homebrew not found. Install Ollama for macOS manually from https://ollama.com/download/mac" >&2
      exit 1
    fi
    ;;
  *)
    echo "Unsupported OS: $os. Install Ollama manually from https://ollama.com/download" >&2
    exit 1
    ;;
esac

ollama --version
