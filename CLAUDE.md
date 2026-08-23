# fluffy-octo-broccoli — Agent Skills & Integration Hub

A curated collection of agent skills, AI gateway setup, and integration examples for Claude Code and other AI development environments.

## Overview

This repository brings together:
- **Agent skills** — reusable capabilities like research and skill discovery
- **OmniRoute setup** — free AI gateway configuration and integration guides
- **Integration patterns** — workflows for combining these tools effectively

All areas are self-contained and can be used independently or together.

## Areas

| Area | Purpose | Install | Docs |
|------|---------|---------|------|
| **find-skills** | Discover and install agent skills from marketplace | Symlink to `.claude/skills/` | `.agents/skills/find-skills/SKILL.md` |
| **research** | Research and information gathering capability | Symlink to `.claude/skills/` | `.agents/skills/research/SKILL.md` |
| **omniroute** | Free AI gateway setup with 290+ providers | `./omniroute/install.sh` | `omniroute/README.md` |

## Repository Layout

```
fluffy-octo-broccoli/
├── CLAUDE.md                           # This file — project documentation
├── .claude/skills/                     # Symlinks to installed skills
│   ├── find-skills → ../../.agents/skills/find-skills/
│   └── research → ../../.agents/skills/research/
├── .agents/skills/                     # Vendored skill source
│   ├── find-skills/
│   │   ├── SKILL.md
│   │   └── references/
│   └── research/
│       ├── SKILL.md
│       └── references/
├── omniroute/                          # OmniRoute AI gateway setup
│   ├── install.sh
│   ├── README.md
│   ├── SKILL_INTEGRATION.md
│   └── checkout/                       # (git-ignored) cloned OmniRoute repo
├── package.json
├── package-lock.json
└── skills-lock.json
```

## Quick Start

### 1. Use Installed Skills in Claude Code

In any Claude Code session, the skills are automatically available:

```
@research

What are the main features of OmniRoute?
```

```
@find-skills

Are there skills for monitoring AI provider usage?
```

### 2. Set Up OmniRoute AI Gateway

```bash
cd omniroute
./install.sh
cd checkout
cp .env.example .env
# Edit .env and set INITIAL_PASSWORD
npm ci
npm run build
npm start
```

Then access the dashboard at `http://127.0.0.1:20128`.

### 3. Use OmniRoute + Skills Together

See `omniroute/SKILL_INTEGRATION.md` for workflows that combine the gateway with skills.

## Currently Installed Skills

### find-skills (vercel-labs/skills)

**Purpose:** Discover agent skills from the marketplace

**Use for:**
- Finding tools for specific tasks ("are there skills for X?")
- Browsing available community skills
- Installing new capabilities

**Activation:** Use `@find-skills` in Claude Code sessions

### research (mattpocock/skills)

**Purpose:** Research and information gathering

**Use for:**
- Analyzing documentation and code
- Exploring architecture and design patterns
- Summarizing complex topics
- Finding answers in repositories

**Activation:** Use `@research` in Claude Code sessions

## OmniRoute Setup

**Purpose:** Free AI gateway aggregating 290+ providers

**What it provides:**
- Unified endpoint for Claude, GPT, Gemini, and others
- ~1.53B free tokens/month tracked live
- Auto-fallback when providers hit rate limits
- Token compression (saves 15–95% tokens)
- Dashboard for monitoring usage and routing

**Full docs:** See `omniroute/README.md` and `omniroute/SKILL_INTEGRATION.md`

## Using Skills Together

The installed skills pair naturally with OmniRoute:

1. **Research** the OmniRoute docs to understand routing and configuration
2. **Find-skills** to discover monitoring tools and integrations
3. **Integrate** the discovered tools with your OmniRoute instance

Example workflow:

```
@research
Show me how OmniRoute's routing strategies work.

@find-skills
What skills exist for analyzing AI provider costs?

# Now use both sets of findings to optimize your setup
```

See `omniroute/SKILL_INTEGRATION.md` for detailed patterns.

## Adding New Skills

To vendor a new skill:

1. Create a directory in `.agents/skills/`
2. Copy the skill's source (usually just `SKILL.md` and references)
3. Create a symlink in `.claude/skills/`
4. Update `skills-lock.json` with the new skill metadata
5. Document in this file

## Adding New Areas

To add a new integration area (CLI, tool, service):

1. Create a top-level directory (e.g., `example-tool/`)
2. Add:
   - `install.sh` — setup script
   - `README.md` — comprehensive documentation
   - `NOTES.md` (optional) — metadata about the area
3. Update the areas table above
4. Document in this file

## Git Workflow

- **Branch:** Each major task gets its own branch (e.g., `claude/omniroute-repo-setup-lnzw7t`)
- **PR:** Changes are made via pull requests to keep the work discoverable
- **Skills-lock:** Always update `skills-lock.json` when adding/updating skills
- **Docs:** Update this file and area-specific READMEs alongside code changes

## Troubleshooting

### Skills Not Loading

If `@research` or `@find-skills` aren't available in Claude Code:

1. Verify `.claude/skills/` has the correct symlinks:
   ```bash
   ls -la .claude/skills/
   ```

2. Ensure skills are registered in your Claude Code session (may need to restart)

3. Check `skills-lock.json` is valid JSON:
   ```bash
   jq . skills-lock.json
   ```

### OmniRoute Build Issues

See `omniroute/README.md` troubleshooting section.

### Skills Need Updating

To refresh a skill:

```bash
cd .agents/skills/skill-name
git fetch origin
git checkout <new-version>
# Update the hash in skills-lock.json
```

Then document the update in the area's section above.

## Resources

- **OmniRoute:** https://github.com/diegosouzapw/OmniRoute
- **OmniRoute Discord:** https://discord.gg/U47eFqAXCn
- **find-skills:** https://github.com/vercel-labs/skills
- **research skill:** https://github.com/mattpocock/skills
- **Claude Code:** https://claude.ai/code

## License

Each area maintains its own license:
- **Skills:** Licensed per upstream (check `SKILL.md`)
- **OmniRoute:** MIT (see `omniroute/checkout/LICENSE`)
- **This repo structure:** MIT

---

**Questions?** Open an issue or check the README in each area for detailed docs.
