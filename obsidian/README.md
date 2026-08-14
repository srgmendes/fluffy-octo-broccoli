# Obsidian

Setup docs for the [Obsidian](https://obsidian.md) desktop app — a local-first
Markdown note-taking app that reads/writes a plain folder of `.md` files (a
"vault") on disk. This directory has no application code of its own; it just
documents how to install the desktop app locally, pulling builds from
Obsidian's release repo,
[`obsidianmd/obsidian-releases`](https://github.com/obsidianmd/obsidian-releases).
That repo hosts the app's binaries (Obsidian itself is closed-source) plus its
community plugin/theme directories — there's no source code to build from
it.

## Requirements

- `curl`
- **Linux:** [FUSE](https://github.com/AppImage/AppImageKit/wiki/FUSE) to run
  the downloaded AppImage directly. If FUSE isn't available (common in
  containers/sandboxes), extract and run instead — see below.
- **macOS:** [Homebrew](https://brew.sh) (recommended; the script falls back
  to printing a manual `.dmg` link if `brew` isn't found).

## Install

```bash
cd obsidian
./install.sh
```

- **Linux:** downloads the latest `x86_64` or `aarch64` AppImage from the
  [latest release](https://github.com/obsidianmd/obsidian-releases/releases/latest)
  into `~/.local/bin/Obsidian.AppImage` and makes it executable.
- **macOS:** runs `brew install --cask obsidian`.
- **Windows:** not automated by this script — download the installer from the
  [releases page](https://github.com/obsidianmd/obsidian-releases/releases/latest)
  or `winget install Obsidian.Obsidian`.

## Running

```bash
# Linux, if FUSE is available:
~/.local/bin/Obsidian.AppImage

# Linux, without FUSE (e.g. inside a container/sandbox):
~/.local/bin/Obsidian.AppImage --appimage-extract-and-run

# macOS:
open -a Obsidian
```

On first launch, Obsidian prompts you to create or open a vault (just a
folder on disk) — there's nothing to configure ahead of time.

## Updating / uninstalling

```bash
./install.sh                        # re-run to fetch the current latest release

# Linux
rm ~/.local/bin/Obsidian.AppImage

# macOS
brew uninstall --cask obsidian
```

## Sandbox caveat

Installing needs network egress to `github.com` and `api.github.com` (to
resolve the latest release) and `objects.githubusercontent.com` (where
release assets are actually served from). Allow those domains in the sandbox
egress policy before running `install.sh`. Running the AppImage inside a
container/sandbox that lacks FUSE also requires the
`--appimage-extract-and-run` fallback shown above.
