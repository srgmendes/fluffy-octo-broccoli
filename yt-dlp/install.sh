#!/usr/bin/env bash
# Installs the yt-dlp CLI (https://github.com/yt-dlp/yt-dlp) via pipx, falling
# back to `pip install --user` if pipx isn't available.
#
# Usage:
#   ./install.sh
#
# Requirements: Python 3.9+. ffmpeg is recommended — yt-dlp shells out to it to
# merge separate video/audio streams and to extract audio-only formats. Install
# it via your OS package manager, e.g. `apt install ffmpeg` / `brew install ffmpeg`.

set -euo pipefail

if command -v pipx >/dev/null 2>&1; then
  pipx install yt-dlp
elif command -v pip3 >/dev/null 2>&1; then
  echo "pipx not found; falling back to 'pip3 install --user yt-dlp'" >&2
  pip3 install --user yt-dlp
else
  echo "Neither pipx nor pip3 found. Install Python 3.9+ first." >&2
  exit 1
fi

yt-dlp --version
