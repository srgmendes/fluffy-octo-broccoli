# Ollama

Setup docs for [Ollama](https://github.com/ollama/ollama) — a CLI and local
server for running open-weight LLMs (Llama, Mistral, Gemma, etc.) on your own
machine. Like `yt-dlp/`, this directory has no application code of its own;
it just documents how to install and use the `ollama` command locally.

## Requirements

- Linux, macOS, or Windows (see [Install](#install) below for
  platform-specific notes)
- Enough disk space and RAM for whatever model you plan to pull — model sizes
  range from ~1GB to 100GB+
- A GPU is optional but speeds up inference significantly; Ollama falls back
  to CPU automatically

## Install

```bash
cd ollama
./install.sh
```

- **Linux:** runs the official installer (`curl -fsSL https://ollama.com/install.sh | sh`)
- **macOS:** uses Homebrew (`brew install ollama`) if available, otherwise
  points you to the manual `.dmg` download
- **Windows:** not supported by this script — download the installer from
  [ollama.com/download](https://ollama.com/download)

Verify:

```bash
ollama --version
```

## Updating / uninstalling

```bash
# Linux: re-run the installer
curl -fsSL https://ollama.com/install.sh | sh

# macOS (Homebrew)
brew upgrade ollama
brew uninstall ollama
```

See the [upstream docs](https://github.com/ollama/ollama?tab=readme-ov-file#uninstall)
for manual uninstall steps on each platform.

## Basic usage

```bash
# Start the local server (also starts automatically on most installs)
ollama serve

# Pull and run a model interactively
ollama run llama3

# Pull a model without running it
ollama pull llama3

# List installed models
ollama list

# Remove a model
ollama rm llama3
```

The server listens on `http://localhost:11434` and exposes a REST API
([docs](https://github.com/ollama/ollama/blob/main/docs/api.md)) that other
tools can call.

Full command reference: `ollama --help` or the
[upstream README](https://github.com/ollama/ollama#readme).

## Sandbox caveat

Pulling models requires network egress to `ollama.com` (registry) and its
CDN. In the Claude Code cloud sandbox, make sure the sandbox's egress policy
allows those domains before running `ollama pull` or `ollama run`.
