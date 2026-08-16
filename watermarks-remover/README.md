# watermarks-remover

Setup docs for [guillaumemeyer/watermarks-remover](https://github.com/guillaumemeyer/watermarks-remover),
a tool that strips AI provenance markers — invisible Unicode watermarks,
statistical text watermarks, and file metadata (C2PA, EXIF, XMP) — from files
you own. This directory has no application code of its own; it just documents
how to clone and run the upstream tool locally. The tool itself is Python
3.10+, stdlib-first with no required production dependencies.

## Requirements

- git
- Python 3.10+
- Optional, for full metadata-stripping coverage: `exiftool`, `qpdf`,
  `c2patool` (install via your OS package manager)

## Install

```bash
cd watermarks-remover
./install.sh          # clones upstream into the git-ignored checkout/ dir
```

Re-running `install.sh` pulls the latest instead of re-cloning if
`checkout/` already exists.

## Usage

All commands run from inside `checkout/` (the upstream clone):

```bash
cd checkout

# One-off CLI cleaning
python3 service/scripts/clean_file.py input.md -o output.md

# HTTP service (default 127.0.0.1:8765)
python3 service/scripts/server.py
```

Docker/Docker Compose and an agent-skill install path (`.grok/skills/remove-ai-marks`)
are also available upstream — see `checkout/README.md` after cloning for the
full setup, including optional backends (Ollama, OpenAI-compatible APIs) and
verification harnesses.

## Updating / uninstalling

```bash
./install.sh                 # re-run to git-pull the latest checkout/
rm -rf checkout/              # uninstall (checkout/ is git-ignored scratch state)
```

## Sandbox caveat

Cloning needs network egress to `github.com`. If you use the optional Ollama
or OpenAI-compatible backends, or the Docker Compose harnesses, allow the
relevant domains in the sandbox egress policy first.
