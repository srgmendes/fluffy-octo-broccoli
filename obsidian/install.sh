#!/usr/bin/env bash
# Installs the Obsidian desktop app (https://obsidian.md) by pulling the
# platform-appropriate build from this app's release repo:
# https://github.com/obsidianmd/obsidian-releases
#
# Usage:
#   ./install.sh
#
# Linux: downloads the latest AppImage into ~/.local/bin/Obsidian.AppImage
#        and makes it executable.
# macOS: installs via Homebrew (`brew install --cask obsidian`) if `brew`
#        is available; otherwise prints the manual download link.
#
# Requirements: curl. AppImages need FUSE on Linux — see this directory's
# README for the container/sandbox fallback if FUSE isn't available.

set -euo pipefail

REPO="obsidianmd/obsidian-releases"
API_URL="https://api.github.com/repos/${REPO}/releases/latest"
RELEASES_URL="https://github.com/${REPO}/releases/latest"

os="$(uname -s)"

case "$os" in
  Darwin)
    if command -v brew >/dev/null 2>&1; then
      brew install --cask obsidian
    else
      echo "Homebrew not found. Install it from https://brew.sh, or download" >&2
      echo "the .dmg manually from $RELEASES_URL" >&2
      exit 1
    fi
    ;;

  Linux)
    arch="$(uname -m)"
    if [ "$arch" != "x86_64" ] && [ "$arch" != "aarch64" ]; then
      echo "Unsupported architecture: $arch. Download manually from $RELEASES_URL" >&2
      exit 1
    fi

    echo "Looking up the latest Obsidian release..." >&2
    release_json="$(curl -sSfL "$API_URL")"

    all_appimages="$(printf '%s' "$release_json" \
      | grep -o '"browser_download_url": *"[^"]*\.AppImage"' \
      | sed -E 's/.*"(https:[^"]+)"/\1/')"

    if [ "$arch" = "aarch64" ]; then
      download_url="$(printf '%s' "$all_appimages" | grep -i 'arm64' | head -n1)"
    else
      download_url="$(printf '%s' "$all_appimages" | grep -vi 'arm64' | head -n1)"
    fi

    if [ -z "$download_url" ]; then
      echo "Could not find an AppImage asset for $arch in the latest release." >&2
      echo "Browse releases manually: $RELEASES_URL" >&2
      exit 1
    fi

    mkdir -p "$HOME/.local/bin"
    dest="$HOME/.local/bin/Obsidian.AppImage"
    echo "Downloading $download_url -> $dest" >&2
    curl -sSfL "$download_url" -o "$dest"
    chmod +x "$dest"

    echo "Installed: $dest"
    case ":$PATH:" in
      *":$HOME/.local/bin:"*) ;;
      *)
        echo "Note: $HOME/.local/bin is not on your PATH. Add it, e.g.:" >&2
        echo '  export PATH="$HOME/.local/bin:$PATH"' >&2
        ;;
    esac
    ;;

  *)
    echo "Unsupported OS: $os. Download manually from $RELEASES_URL" >&2
    exit 1
    ;;
esac
