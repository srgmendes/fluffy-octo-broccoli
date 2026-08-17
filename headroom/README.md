# headroom

Setup docs for the [headroom](https://github.com/headroomlabs-ai/headroom) CLI
— a context compression layer for AI agents that shrinks tool outputs, logs,
files, RAG chunks, and conversation history before they reach an LLM (claimed
60–95% fewer tokens for JSON data, 15–20% for coding-agent traffic). This
directory has no application code of its own; it just documents how to
install and use the `headroom` command locally. Everything runs on your
machine — no data is sent to a headroom-hosted service.

## Requirements

- Python 3.10+ (3.13 recommended for dashboard pricing features)
- [`pipx`](https://pipx.pypa.io/) (recommended) or `pip3`

## Install

```bash
cd headroom
./install.sh          # pipx install "headroom-ai[all]" (falls back to pip3 install --user)
```

Verify:

```bash
headroom --version
headroom doctor        # health check confirming routing works
```

Alternative install methods from upstream (not what `install.sh` uses, but
available if you need them):

```bash
uv tool install --python 3.13 "headroom-ai[all]"   # isolated install via uv
npm install headroom-ai                             # TypeScript/JS SDK (library only, no CLI)
docker pull ghcr.io/headroomlabs-ai/headroom:latest # container image
```

## Updating / uninstalling

```bash
headroom update                # self-upgrade across pip/pipx/uv
pipx upgrade headroom-ai       # if installed via pipx
pipx uninstall headroom-ai     # remove
```

## Basic usage

```bash
# Turnkey local deployment with agent configuration
headroom deploy

# Wrap a coding agent (claude, codex, cursor, aider, etc.) so its traffic
# is transparently compressed
headroom wrap claude

# Run as a drop-in proxy for zero-code integration
headroom proxy --port 8787

# Confirm routing/compression is actually working
headroom doctor

# Other useful subcommands
headroom perf         # performance metrics
headroom dashboard     # live savings visualization
headroom learn         # mine failed sessions, generate corrections
headroom mcp install   # install as an MCP server
```

Full flag reference: `headroom --help` or the
[upstream README](https://github.com/headroomlabs-ai/headroom#readme).

## Useful environment variables

```bash
HEADROOM_OUTPUT_SHAPER=1               # enable output token reduction
HEADROOM_EMBEDDER_RUNTIME=pytorch_mps  # Apple GPU offload
HF_HUB_OFFLINE=1                       # use pre-downloaded models only
ORT_STRATEGY=system                    # use system ONNX Runtime
HEADROOM_TLS_STRICT=0                  # relax TLS validation for corporate proxies
```

## Sandbox caveat

Installing requires network egress to PyPI (`pypi.org`, `files.pythonhosted.org`)
for the pip/pipx/uv paths, or `ghcr.io` for the Docker image. Running
`headroom wrap`/`headroom proxy` needs egress to whatever LLM provider(s) the
wrapped agent talks to (e.g. `api.anthropic.com`). In the Claude Code cloud
sandbox, make sure the sandbox's egress policy allows those domains before
installing or running `headroom`.
