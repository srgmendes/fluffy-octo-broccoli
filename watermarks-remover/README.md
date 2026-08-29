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

`git` and Python **3.10+** are all you need — the service is stdlib-only and has
no Python dependencies.

Everything else is an **optional external CLI**, auto-detected on `PATH` and
reported by `/capabilities`. Each one widens what can actually be stripped:

| Tool | Unlocks | Without it |
| --- | --- | --- |
| [`qpdf`](https://qpdf.sourceforge.io/) | Structural PDF rebuild | PDF strips are **incomplete** |
| [`exiftool`](https://exiftool.org/) | Residual EXIF/XMP/doc-property strip | Metadata survives in several formats |
| [`c2patool`](https://github.com/contentauth/c2pa-rs/tree/main/cli) | Reads C2PA manifests, so inspection can *confirm* one rather than infer it from JUMBF bytes | Detection is heuristic-only |
| [`ghostscript`](https://www.ghostscript.com/) | PDF **deep image pass** — a `pdfwrite` re-distill reaching metadata *inside images embedded in a PDF* (`--deep-images`) | That stage is skipped; the outer PDF is still cleaned |

### Installing them

Three of the four are in the usual package repositories:

```bash
# Debian / Ubuntu
sudo apt-get install qpdf libimage-exiftool-perl ghostscript
# macOS
brew install qpdf exiftool ghostscript
```

`c2patool` ships only as a GitHub release binary — there is no distro package,
and `cargo install c2patool` needs crates.io access:

```bash
V=c2patool-v0.27.16          # pin a release; check upstream for newer
curl -sL -o c2patool.tar.gz \
  "https://github.com/contentauth/c2pa-rs/releases/download/$V/$V-x86_64-unknown-linux-gnu.tar.gz"
tar xzf c2patool.tar.gz
sudo install -m 0755 c2patool/c2patool /usr/local/bin/c2patool
c2patool --version
```

Note that upstream publishes **no checksums or signatures** for these release
assets, so that download is trusted on HTTPS alone. Verify it yourself if that
matters to you; the `v0.27.16` Linux x86-64 tarball is
`sha256:62eed34f0c90a24b696b1969c8aad4340e11ec7264e1cf6fc375ad15c1db7663`.

### Restart the service after installing a tool

**The service probes for these tools once, at startup, and caches the result.**
Installing a tool while it is running changes nothing — `/capabilities` keeps
reporting `false` and the cleaning pipeline keeps skipping that stage. Restart
the service, then confirm:

```bash
curl -s http://127.0.0.1:8765/capabilities   # "tools": { ... all true ... }
```

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

The optional tools install fine in the Claude Code cloud sandbox: `apt-get`
reaches the Ubuntu archive (third-party PPAs are blocked, but none are needed),
and `github.com` release downloads work, which is how `c2patool` gets in.
`crates.io` is blocked there (403), so `cargo install c2patool` is not an
option. All of it lands in the container, not the repo — a fresh session starts
without these tools, which is why they are documented here rather than pinned
anywhere.

Full details: [upstream README](https://github.com/guillaumemeyer/watermarks-remover#readme).
