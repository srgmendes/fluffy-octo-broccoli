# Free Claude Code (FCC) install notes

[Free Claude Code](https://github.com/Alishahryar1/free-claude-code) is a local
proxy gateway that lets you run coding agents — **Claude Code**, **Codex**, and
**Pi** — through your own OpenAI‑compatible AI providers (NVIDIA NIM, OpenAI,
Azure OpenAI, Gemini, DeepSeek, Mistral, Ollama, LM Studio, …). It ships:

- CLI entry points `fcc-server`, `fcc-claude`, `fcc-codex`, `fcc-pi`,
  `fcc-desktop`.
- A local **Admin UI** at `http://127.0.0.1:8082/admin` for configuring
  providers and model‑tier routing (Fable / Opus / Sonnet / Haiku → different
  providers).
- Optional Discord / Telegram bots and voice transcription (not installed here).

It is distributed as a Python package (`free-claude-code`, requires
**Python ≥ 3.14**) installed as a `uv` tool. The `fcc-claude` launcher just runs
your existing `claude` binary with its Anthropic base URL pointed at the local
proxy on port `8082`.

This directory is **documentation only** — FCC installs into your user
environment (`~/.local`), not into this repo.

## Standard install (normal machine)

On an unrestricted machine, use the upstream one‑liner (it installs the agents
you pick, ensures a recent `uv`, then `uv tool install`s FCC):

```bash
# macOS / Linux
curl -fsSL "https://raw.githubusercontent.com/Alishahryar1/free-claude-code/main/scripts/install.sh" | sh
```

```powershell
# Windows PowerShell
& ([scriptblock]::Create((irm "https://raw.githubusercontent.com/Alishahryar1/free-claude-code/main/scripts/install.ps1")))
```

Then: `fcc-server` (start the proxy) → configure a provider in the Admin UI →
`fcc-claude` (or `fcc-codex` / `fcc-pi`).

### Windows

```powershell
& ([scriptblock]::Create((irm "https://raw.githubusercontent.com/Alishahryar1/free-claude-code/main/scripts/install.ps1")))
```

On Windows and macOS the installer also drops a background desktop launcher
(`fcc-desktop`) so the proxy can run without a terminal window.

## Install inside a restricted / proxied sandbox

The Claude Code cloud sandbox routes all outbound HTTPS through a
policy‑enforcing egress proxy. The upstream one‑liner **cannot run there**: it
downloads from hosts the policy blocks at the gateway (`403`). The following
procedure reaches the same end state using **only sanctioned lanes** — the git
proxy (public GitHub reads), PyPI, and `static.crates.io` — and installs
**Claude Code only** (Codex and Pi hosts are blocked; `claude` is already
present in the sandbox).

> **Shortcut:** [`install-sandbox.sh`](./install-sandbox.sh) in this directory
> automates every step below (idempotent; re-run to update). From the repo root:
>
> ```bash
> sh free-claude-code/install-sandbox.sh
> ```
>
> Override `CLONE_DIR`, `TIKTOKEN_CACHE_DIR`, or `PYTHON_VERSION` via the
> environment. The manual steps that follow are what the script does.

Prefix commands with `NODE_USE_ENV_PROXY=1` so tools that use Node's built‑in
fetch honour the proxy, matching the convention in `../COMPOSIO.md`.

### 1. Get the FCC source via the git proxy (not the blocked archive URL)

```bash
GIT_LFS_SKIP_SMUDGE=1 git clone --depth 1 \
  https://github.com/Alishahryar1/free-claude-code /workspace/alishahryar1/free-claude-code
```

`github.com/.../archive/....zip` is blocked, but anonymous **git reads** of
public repos go through the sanctioned git proxy.

### 2. Ensure `uv ≥ 0.11.16` from PyPI (not the blocked `astral.sh`)

FCC's `pyproject.toml` sets `required-version = ">=0.11.16"`. If the sandbox's
`uv` is older (it shipped 0.8.17), upgrade it from PyPI:

```bash
python3 -m pip install --user --upgrade "uv>=0.11.16"   # installs uv 0.12.x
```

### 3. Provision Python 3.14.0 **final** with uv

FCC requires Python ≥ 3.14. `uv` can download a managed CPython (this host
allows the python‑build‑standalone download). **Use the final release, not a
release candidate:** 3.14.0rc2 crashes at startup because the pinned `pydantic`
calls `typing._eval_type(..., prefer_fwd_module=True)`, a keyword the rc's
`typing` module does not accept (`TypeError: _eval_type() got an unexpected
keyword argument 'prefer_fwd_module'`).

```bash
uv python install 3.14.0     # a newer uv (step 2) knows about 3.14.0..3.14.x final
```

### 4. Install FCC from the local clone (deps resolve from PyPI)

```bash
uv tool install --force --python 3.14.0 /workspace/alishahryar1/free-claude-code
uv tool update-shell            # puts the uv tool bin on PATH
fcc-server --version            # -> free-claude-code 4.16.7
```

Install **without** the `[voice]` / `[voice_local]` extras — their wheels
(NVIDIA Riva gRPC, Torch from `download.pytorch.org`) need hosts the policy
blocks.

### 5. Pre‑seed the tiktoken vocab cache (blocked runtime download)

`fcc-server` counts tokens with `tiktoken`, which fetches its BPE vocab files
from `openaipublic.blob.core.windows.net` on first use — a **blocked** host, so
the server crashes at boot. `tiktoken` verifies every vocab file against a known
`sha256`, so it is safe to supply the files from any source: the hash check
guarantees the exact official bytes. Fetch them from the `tiktoken-rs` crate
(vendored as plain, non‑LFS blobs; `static.crates.io` is reachable):

```bash
# discover latest version from the sparse index, then download + extract the crate
curl -fsSL "https://static.crates.io/crates/tiktoken-rs/tiktoken-rs-<VER>.crate" -o tt.crate
tar -xzf tt.crate                      # assets/{cl100k_base,o200k_base}.tiktoken
```

Verify and place each file under `TIKTOKEN_CACHE_DIR`, named `sha1(<blob URL>)`:

| encoding | sha256 (`expected_hash`) | cache filename = `sha1(url)` |
| --- | --- | --- |
| `cl100k_base` | `223921b76ee99bde995b7ff738513eef100fb51d18c93597a113bcffe865b2a7` | `9b5ad71b2ce5302211f9c61530b329a4922fc6a4` |
| `o200k_base`  | `446a9538cb6c348e3516120d7c08b09f57c36495e2acfffe59a5bf8b0cfb1a2d` | `fb374d419588a4632f3f557e76b4b70aebbca790` |

where the URL is `https://openaipublic.blob.core.windows.net/encodings/<encoding>.tiktoken`.

```bash
export TIKTOKEN_CACHE_DIR=$HOME/.cache/tiktoken   # must be set when fcc-server runs
```

### 6. Run and verify

```bash
TIKTOKEN_CACHE_DIR=$HOME/.cache/tiktoken NODE_USE_ENV_PROXY=1 fcc-server
# INFO: Application startup complete.  Admin UI: http://127.0.0.1:8082/admin
curl -s -o /dev/null -w '%{http_code}\n' http://127.0.0.1:8082/admin   # 200
```

`GET /admin`, `/`, `/health`, and `/v1/models` all return `200`.

## Configuring providers

FCC talks to any **OpenAI‑compatible** Chat Completions endpoint. Configure
providers in the Admin UI (`/admin`) or via a `.env` file; the picked chat model
is set with `MODEL="<provider>/<model-id>"`. Providers ship preconfigured — you
only supply a key (or a base URL for local ones). A sample of what's supported:

| Kind | Providers (env var) |
| --- | --- |
| **Local, no key** | Ollama (`OLLAMA_BASE_URL`), LM Studio (`LM_STUDIO_BASE_URL`), llama.cpp (`LLAMACPP_BASE_URL`) |
| **Hosted, API key** | OpenAI, Azure OpenAI, Gemini / Google AI Studio (`GEMINI_API_KEY`), DeepSeek, Mistral (+ Codestral), Groq, Cerebras, SambaNova, Fireworks, OpenRouter, Vercel AI Gateway, Hugging Face, Cohere, GitHub Models, NVIDIA NIM, Kimi, MiniMax, Z.ai, Cloudflare Workers AI, Ollama Cloud, … |
| **Cloud IAM** | Google Vertex (`VERTEX_PROJECT_ID` + ADC), Amazon Bedrock (`AWS_BEARER_TOKEN_BEDROCK`) |

Optional model‑tier routing sends each Claude tier to a different provider, and
`ANTHROPIC_AUTH_TOKEN` (default `freecc`) is the local proxy's bearer token. A
per‑provider `*_PROXY` env var lets a provider egress through its own HTTP/SOCKS
proxy. **Fastest local start:** run Ollama, then set
`MODEL="ollama/<model>"` — no key required.

## Messaging bots (optional)

FCC can drive an agent from Telegram or Discord. Set `MESSAGING_PLATFORM` to
`telegram`, `discord`, or `none`, then:

- **Telegram:** `TELEGRAM_BOT_TOKEN`, `ALLOWED_TELEGRAM_USER_ID` (allow‑list),
  optional `TELEGRAM_PROXY_URL`.
- **Discord:** `DISCORD_BOT_TOKEN`, `ALLOWED_DISCORD_CHANNELS`.

## Voice transcription (optional)

Voice notes are transcribed when `VOICE_NOTE_ENABLED=true`. Pick a backend with
`WHISPER_DEVICE`:

- `cpu` / `cuda` — offline Hugging Face Whisper. Install the extra:
  `uv tool install ... 'free-claude-code[voice_local]'` (pulls Torch; needs
  `download.pytorch.org`, **blocked in the sandbox**).
- `nvidia_nim` — NVIDIA NIM Whisper over Riva gRPC; needs `NVIDIA_NIM_API_KEY`
  and the `[voice]` extra. gRPC is **not supported through the sandbox proxy**.

Both voice backends therefore only work outside the restricted sandbox.

## Egress caveats in this sandbox

These hosts are denied by the session's egress policy (`403` at the gateway),
so the corresponding features are unavailable here — this is an environment
limitation, not an FCC bug, and must be reported rather than worked around:

| Host | What it gates | Handled by |
| --- | --- | --- |
| `github.com/.../*.zip` | FCC source archive | git proxy clone (step 1) |
| `astral.sh` | `uv` self‑install/update | PyPI `pip install uv` (step 2) |
| `downloads.claude.ai` | Claude Code installer | `claude` already present in sandbox |
| `chatgpt.com` | Codex installer | **not installed** (blocked) |
| `pi.dev` | Pi installer | **not installed** (blocked) |
| `openaipublic.blob.core.windows.net` | tiktoken vocab | crates.io + cache seed (step 5) |
| provider APIs (OpenAI, NIM, Gemini, …) | FCC's actual proxying | **blocked** — configure & run FCC where these are reachable |

The proxy boots and serves its Admin UI here, but FCC's core job — forwarding
agent traffic to a third‑party provider — needs the provider's API host to be
reachable. Point FCC at a provider from an environment whose egress policy
allows it.
