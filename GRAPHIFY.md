# Graphify setup (CLI + vendored skill)

[Graphify](https://github.com/Graphify-Labs/graphify) turns any folder of files
(code, docs, PDFs, images, audio/video) into a navigable **knowledge graph** with
community detection and an honest `EXTRACTED`/`INFERRED`/`AMBIGUOUS` audit trail.
Extraction is deterministic and local — it uses tree-sitter AST parsing (36+
languages) with no API calls or LLM inference required to build the graph. It
produces three outputs under `graphify-out/`: an interactive HTML visualization,
a GraphRAG-ready `graph.json`, and a plain-language `GRAPH_REPORT.md`, plus
`query`/`path`/`explain` commands for exploring the result.

## What's installed here

Graphify has two halves, and this repo tracks the one that belongs in git:

1. **The `graphify` CLI** — shipped as the [`graphifyy`](https://pypi.org/project/graphifyy/)
   PyPI package. It is a machine-level tool, **not** vendored into the repo (the
   same way the Composio SDK's binaries aren't). Install it per machine:

   ```bash
   uv tool install graphifyy        # installs `graphify` + `graphify-mcp` (or: pipx install graphifyy)
   ```

   In **Claude Code on the web**, this install runs automatically: a
   `SessionStart` hook (`.claude/hooks/session-start.sh`, registered in
   `.claude/settings.json`) installs the CLI at session start so `/graphify`
   works out of the box. The hook only runs in remote sessions
   (`$CLAUDE_CODE_REMOTE`), is idempotent (skips if `graphify` is already on
   `PATH`), and adds `~/.local/bin` to the session `PATH`. On a local machine,
   install the CLI yourself with the command above.

2. **The graphify skill** — bundled inside the `graphifyy` package and normally
   copied out by `graphify install`. That command targets a machine-global config
   dir (`~/.claude/skills/`), which does not survive the ephemeral Claude Code
   sandbox. So instead the skill is **vendored into this repo** following the same
   convention as the other agent skills:

   - `.agents/skills/graphify/` — the skill source (`SKILL.md` + `references/`),
     pinned to the version recorded in `.agents/skills/graphify/.graphify_version`.
   - `.claude/skills/graphify` — a symlink into `.agents/skills/graphify` so Claude
     Code discovers it.

   Because the skill comes from a PyPI package (not a GitHub `SKILL.md` checkout),
   it has **no `skills-lock.json` entry** — same as the local
   `chief-content-officer` skill. The pinned version lives in `.graphify_version`.

## Usage

Once the CLI is installed, use the skill from your AI assistant by typing
`/graphify` (see `.agents/skills/graphify/SKILL.md` for the full command list):

```
/graphify                        # build a graph of the current directory
/graphify <path>                 # build a graph of a specific path
/graphify https://github.com/<owner>/<repo>   # clone a repo, then graph it
/graphify query "<question>"     # BFS traversal over the built graph
/graphify path "A" "B"           # shortest path between two concepts
/graphify explain "SomeNode"     # plain-language explanation of a node
```

Or drive the CLI directly:

```bash
graphify install --platform claude   # (machine-global) re-copy the skill to ~/.claude
graphify query "How does auth work?" # query graphify-out/graph.json
graphify --help                      # full command reference
```

Generated output lands in `graphify-out/`, which is git-ignored — the knowledge
graph is a build artifact, not source.

## Upgrading

Bump the CLI and re-vendor the skill so the two stay in lockstep:

```bash
uv tool upgrade graphifyy
graphify install --platform claude                       # refresh ~/.claude/skills/graphify
cp -a ~/.claude/skills/graphify/SKILL.md \
      ~/.claude/skills/graphify/references \
      ~/.claude/skills/graphify/.graphify_version \
      .agents/skills/graphify/                           # re-vendor into the repo
```

Commit the updated `.agents/skills/graphify/` (including the new
`.graphify_version`) in the same change.
