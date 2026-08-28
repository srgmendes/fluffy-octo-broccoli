# Obsidian skills (vendored)

[kepano/obsidian-skills](https://github.com/kepano/obsidian-skills) is a set of
agent skills for working with [Obsidian](https://obsidian.md) vault files —
Obsidian Flavored Markdown, Bases, and Canvas — plus the Obsidian CLI and the
Defuddle web extractor. Upstream ships them as a Claude Code **plugin**
(`obsidian@obsidian-skills`); this repo vendors the skills directly, matching how
the other agent skills here are handled (see `CLAUDE.md`).

## What's installed here

- `.agents/skills/obsidian-markdown/` — Obsidian Flavored Markdown: wikilinks,
  embeds, callouts, properties, comments. References: `CALLOUTS.md`,
  `EMBEDS.md`, `PROPERTIES.md`.
- `.agents/skills/obsidian-bases/` — Obsidian Bases (`.base`): views, filters,
  formulas, summaries. Reference: `FUNCTIONS_REFERENCE.md`.
- `.agents/skills/json-canvas/` — [JSON Canvas](https://jsoncanvas.org/)
  (`.canvas`): nodes, edges, groups, connections. Reference: `EXAMPLES.md`.
- `.agents/skills/obsidian-cli/` — drive a running Obsidian instance with the
  `obsidian` CLI (notes, search, vault ops, plugin/theme debugging).
- `.agents/skills/defuddle/` — extract clean Markdown from web pages with the
  Defuddle CLI instead of `WebFetch`, to cut token usage.

Each has a matching `.claude/skills/<name>` symlink so Claude Code discovers it.

Because these come from a **plugin repo** (the `skills/` directory of
`kepano/obsidian-skills`) rather than a single-`SKILL.md` GitHub skill installed
via the `skills` CLI, they have **no `skills-lock.json` entry** — same rationale
as the vendored `ponytail*` skills. The vendored version is pinned by
`.agents/skills/.obsidian_version` (plugin `1.0.1`, upstream commit `a1dc48e`).
It sits beside the skill directories rather than inside one of them, since it
pins all five.

Upstream is MIT-licensed, © Steph Ango (@kepano). The MIT terms require the
licence text to travel with the copies, so upstream's `LICENSE` is vendored
verbatim into **each** of the five skill directories — they sit as siblings
among unrelated skills under `.agents/skills/`, with no shared parent directory
to hold one copy. All five files are byte-identical to upstream's.

## Usage

These are model-invoked skills, not slash commands — they activate on the file
types and topics in their descriptions:

| Skill | Activates on |
| --- | --- |
| `obsidian-markdown` | `.md` in a vault; wikilinks, callouts, frontmatter, tags, embeds |
| `obsidian-bases` | `.base` files; table/card views, filters, formulas |
| `json-canvas` | `.canvas` files; mind maps, flowcharts, visual canvases |
| `obsidian-cli` | vault operations from the command line; plugin/theme dev |
| `defuddle` | reading a non-`.md` URL (articles, docs, blog posts) |

Two of them shell out to tools that are **not** installed by this repo, and
neither is available in the Claude Code cloud sandbox:

- `obsidian-cli` needs the `obsidian` CLI **and a running Obsidian instance** on
  the same machine — so it only works locally, never in the sandbox.
- `defuddle` needs `npm install -g defuddle`, and fetching a page needs sandbox
  egress to that domain (same caveat as the other areas here).

## Upgrading

Re-vendor from a newer upstream commit and bump the pin:

```bash
git clone --depth 1 https://github.com/kepano/obsidian-skills.git /tmp/obsidian-skills
for n in obsidian-markdown obsidian-bases json-canvas obsidian-cli defuddle; do
  rm -rf .agents/skills/$n
  cp -R /tmp/obsidian-skills/skills/$n .agents/skills/$n
  cp /tmp/obsidian-skills/LICENSE .agents/skills/$n/LICENSE
done
# record the new version (from /tmp/obsidian-skills/.claude-plugin/plugin.json)
printf '<new-version>\n' > .agents/skills/.obsidian_version
```

Note the loop deletes each skill directory first, wiping the vendored `LICENSE`
copies — hence the licence restore inside the loop. The version pin lives outside
those directories, so it survives; the recipe rewrites it anyway to record the new
version. Commit the updated `.agents/skills/` directories, the `LICENSE` copies
and `.obsidian_version` together, and update the commit SHA above.
