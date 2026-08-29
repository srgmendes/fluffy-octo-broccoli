# watermarks-remover

Setup docs for [`guillaumemeyer/watermarks-remover`](https://github.com/guillaumemeyer/watermarks-remover)
— an agent skill plus a small HTTP service that strips **AI provenance marks**
from text and files you own: invisible Unicode (zero-width, bidi, tag chars,
exotic spaces), C2PA manifests, EXIF/XMP metadata, and document properties.

Like `yt-dlp/`, this directory holds **no application code**. It's an
`install.sh` wrapper plus these docs; the upstream project is cloned into
`src/` (git-ignored) at a pinned tag.

Two pieces:

| Piece | What it does |
| --- | --- |
| **Agent skill** (`remove-ai-marks`) | Markdown only — a thin client that drives the service over HTTP, so the agent host needs no Python. |
| **HTTP service** (`service/scripts/server.py`) | Python 3.10+ **stdlib only**, no dependencies. Does the actual inspecting and cleaning. |

A second skill, `clean-user-facing-text`, is text-only and self-contained (it
ships its own scripts and needs no service).

## Requirements

- `git` and Python **3.10+** (stdlib only — the service has no dependencies)
- Optional, auto-detected when on `PATH`:
  - [`qpdf`](https://qpdf.sourceforge.io/) — **required** for a real PDF strip
  - [`exiftool`](https://exiftool.org/) — residual metadata strip
  - [`c2patool`](https://github.com/contentauth/c2pa-rs/tree/main/cli) — inspect C2PA manifests

## Install

```bash
cd watermarks-remover
./install.sh                                   # skill -> ~/.claude/skills (personal)
./install.sh cursor                            # skill -> ~/.cursor/skills
./install.sh claude-project /path/to/project   # skill -> <project>/.claude/skills
./install.sh none                              # clone/update src/ only, install no skill
```

The script clones upstream at the pinned tag into `src/`, then runs upstream's
`install_skill.py` for the chosen host. Re-running it updates the checkout in
place. Two knobs:

```bash
WATERMARKS_VERSION=v0.6.0 ./install.sh              # upstream tag (default: v0.6.0)
WATERMARKS_SKILL=clean-user-facing-text ./install.sh  # which skill to install
```

Upstream is **pinned to `v0.6.0`**, matching this repo's convention of pinning
external dependencies rather than tracking a moving branch. To upgrade, bump
the default in `install.sh` and the version references here in the same commit.

### Alternative: the Claude Code plugin marketplace

Upstream is also a Claude Code plugin and single-plugin marketplace, so for the
skills alone you don't need this directory or a clone at all:

```
/plugin marketplace add guillaumemeyer/watermarks-remover
/plugin install watermarks-remover@watermarks-remover
```

That route also registers a `PostToolUse` hook that checks (or, with
`WATERMARKS_HOOK_MODE=clean`, cleans) every file the agent writes. You still
need the service running for `remove-ai-marks` to do anything.

## Running the service

```bash
python3 src/service/scripts/server.py --host 127.0.0.1 --port 8765
# or, from the checkout: (cd src && make serve)
```

It binds to loopback only by default. Verify and use it:

```bash
curl -s http://127.0.0.1:8765/health          # {"ok": true, "version": "..."}
curl -s http://127.0.0.1:8765/capabilities    # which optional tools were found
curl -s http://127.0.0.1:8765/openapi.json    # machine-readable contract

curl -s -X POST http://127.0.0.1:8765/clean -H 'Content-Type: application/json' \
  -d "{\"file\": \"$(base64 < notes.md | tr -d '\n')\", \"name\": \"notes.md\"}"
```

If the skill is talking to a service somewhere other than
`http://127.0.0.1:8765`, point it there with `WATERMARKS_SERVICE_URL`. Set
`WATERMARKS_SERVER_API_KEY` on any service that isn't loopback-only — it then
requires `Authorization: Bearer <key>` on every request.

## Using the CLI scripts directly

The same machinery runs without the service:

```bash
S=src/service/scripts

python3 "$S/inspect_file.py" draft.md          # what's in there
python3 "$S/clean_file.py"   draft.md -o draft.cleaned.md
python3 "$S/clean_file.py"   photo.png -o photo.cleaned.png
python3 "$S/clean_text.py"   draft.md -o draft.cleaned.md --stats
```

`inspect_file.py` exits non-zero when it finds actionable marks — handy in a
shell gate. The text-only tools refuse binary input (a `.docx`/`.pdf`/image) and
name `inspect_file.py` / `clean_file.py` instead; unrecognized formats are never
auto-cleaned.

## Scope: what it can and can't do

- **Deterministic** for invisible Unicode and file metadata (C2PA, EXIF/XMP,
  doc properties) across images, PDF, Office/OpenDocument, EPUB, HTML/Markdown,
  and common audio/video containers.
- **Best-effort** for statistical (token-sampling) text watermarks — that layer
  is an agent rewrite, not a guarantee.
- PDF stripping needs `qpdf` for the structural rebuild; without it the strip is
  incomplete.
- Nothing can rewrite an assistant's chat message before you read it. The
  guarantee covers files on disk.

Intended for privacy and hygiene on content **you own**.

## Sandbox caveat

`install.sh` clones over HTTPS from `github.com`, so the sandbox egress policy
must allow it. The service itself binds to loopback and makes no outbound calls
unless you opt into detection backends. `curl` against the local service needs
`--noproxy 127.0.0.1` in the Claude Code cloud sandbox, where `HTTPS_PROXY` is
set globally.

Full details: [upstream README](https://github.com/guillaumemeyer/watermarks-remover#readme).
