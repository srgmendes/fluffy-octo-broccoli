# Ponytail setup (vendored skills)

[Ponytail](https://github.com/DietrichGebert/ponytail) is "lazy senior dev mode"
for AI agents: it forces the simplest, shortest solution that actually works —
YAGNI, stdlib before custom code, native platform features before dependencies,
one line before fifty. Upstream ships it as a multi-platform tool (a Claude Code
plugin, editor rulesets, an MCP server, hooks). This repo vendors just the
**skills**, matching how the other agent skills here are handled.

## What's installed here

Upstream distributes ponytail for Claude Code as a **plugin**
(`/plugin install ponytail@ponytail` from its marketplace). That pulls in the
skills *plus* mode-switching hooks, slash commands, and a statusline. Following
this repo's "vendored, not fetched at runtime" convention (see `CLAUDE.md`), we
vendor the six bundled skills directly instead:

- `.agents/skills/ponytail/` — the core "lazy mode" skill (intensity levels
  `lite` / `full` / `ultra`).
- `.agents/skills/ponytail-review/` — review a diff for over-engineering.
- `.agents/skills/ponytail-audit/` — whole-repo over-engineering audit.
- `.agents/skills/ponytail-debt/` — harvest `ponytail:` shortcut comments into a
  debt ledger.
- `.agents/skills/ponytail-gain/` — show ponytail's measured impact scoreboard.
- `.agents/skills/ponytail-help/` — quick-reference card for all of the above.

Each has a matching `.claude/skills/<name>` symlink so Claude Code discovers it.

Because these come from a **plugin repo** (the `skills/` directory of
`DietrichGebert/ponytail`) rather than a single-`SKILL.md` GitHub skill installed
via the `skills` CLI, they have **no `skills-lock.json` entry** — same rationale
as the package-provided `graphify` skill. The vendored version is pinned by
`.agents/skills/ponytail/.ponytail_version` (plugin `4.8.4`, upstream commit
`16f2980`).

## Usage

Invoke from your AI assistant by name (each maps to the upstream `/ponytail*`
command):

```
/ponytail [lite|full|ultra]   # engage lazy mode at an intensity (default: full)
/ponytail-review [target]     # review a diff for over-engineering
/ponytail-audit [target]      # audit the whole repo for bloat
/ponytail-debt                # list deferred `ponytail:` shortcuts
/ponytail-gain                # show the impact scoreboard
/ponytail-help                # quick reference
```

`ponytail` is a persistent mode — once engaged it stays active until you say
"stop ponytail" / "normal mode". The other five are one-shot reports and change
nothing on their own.

## What's intentionally left out

The vendored skills give the review/audit/debt/help behavior and the lazy-coding
discipline. The upstream plugin's **runtime pieces** — the hooks that track the
active mode across turns, the statusline, and the MCP server — are *not* vendored
(they're Claude Code plugin machinery, not skills). If you want the full mode
tracking and statusline, install the upstream plugin instead:

```
/plugin marketplace add DietrichGebert/ponytail
/plugin install ponytail@ponytail
```

## Upgrading

Re-vendor the skills from a newer upstream tag and bump the pin:

```bash
git clone --depth 1 https://github.com/DietrichGebert/ponytail.git /tmp/ponytail
for n in ponytail ponytail-review ponytail-audit ponytail-debt ponytail-gain ponytail-help; do
  cp /tmp/ponytail/skills/$n/SKILL.md .agents/skills/$n/SKILL.md
done
# record the new version (from /tmp/ponytail/.claude-plugin/plugin.json)
printf '<new-version>\n' > .agents/skills/ponytail/.ponytail_version
```

Commit the updated `.agents/skills/ponytail*/` and `.ponytail_version` together.
