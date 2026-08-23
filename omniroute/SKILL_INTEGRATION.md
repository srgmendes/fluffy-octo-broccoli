# OmniRoute + Skills Integration

This document explains how to use the `find-skills` and `research` skills alongside OmniRoute for discovering capabilities, analyzing provider strategies, and building integrations.

## Quick Start

After installing OmniRoute (see README.md), use the installed skills in your Claude Code sessions:

### 1. Research OmniRoute Architecture & Strategies

**Use case:** Understand how routing works, what strategies are available, or analyze provider docs

```
@research

I need to understand how OmniRoute's token compression works. 
Analyze the RTK and Caveman compression strategies in the OmniRoute 
repository at /path/to/omniroute/checkout/docs.
```

The research skill will:
- Locate and read documentation files
- Extract key concepts about routing logic
- Summarize compression algorithms
- Provide analysis of trade-offs

### 2. Discover Skills & Integrations

**Use case:** Find tools or skills that enhance OmniRoute workflows

```
@find-skills

I'm using OmniRoute as an AI gateway. What skills are available for:
- Monitoring provider API usage
- Automating routing strategy selection
- Integrating with development tools (Cursor, Cline, etc.)
```

The find-skills skill will:
- Search the skill marketplace for relevant tools
- Return descriptions and install commands
- Help you build a custom toolkit around OmniRoute

## Workflow Examples

### Example 1: Optimize Your Provider Stack

1. **Research Phase:**
   ```
   @research
   
   What are the documented free tiers for GPT-4 Mini, Claude Sonnet 4.5, 
   and Gemini 2.5 Flash? Compare their token limits and reset periods.
   ```

2. **Discovery Phase:**
   ```
   @find-skills
   
   Are there skills for tracking free tier usage across multiple providers?
   I want to monitor my remaining tokens and get alerts when limits approach.
   ```

3. **Integration:**
   - Use research findings to inform your `.env` provider configuration
   - Install discovered monitoring skills to track usage
   - Configure OmniRoute's routing strategy based on provider limits

### Example 2: Build Custom Routing Logic

1. **Research Phase:**
   ```
   @research
   
   Show me the routing strategy implementations in OmniRoute's codebase.
   Explain the difference between cost-based, latency-based, and 
   reliability-based routing.
   ```

2. **Discovery Phase:**
   ```
   @find-skills
   
   Are there skills for building custom AI model routing policies? 
   Can I create a skill that routes based on my own criteria?
   ```

3. **Implementation:**
   - Use research findings to understand the routing API
   - Follow discovered patterns for extending OmniRoute
   - Create custom routing logic tailored to your needs

### Example 3: Integrate with Your Development Workflow

1. **Discovery Phase:**
   ```
   @find-skills
   
   What skills exist for integrating OmniRoute with:
   - Claude Code
   - Cursor editor
   - Cline agent
   - GitHub Copilot
   ```

2. **Research Phase:**
   ```
   @research
   
   How does OmniRoute's OpenAI-compatible API work? What configuration 
   is needed to point Cursor/Cline to an OmniRoute endpoint?
   ```

3. **Setup:**
   - Install integration skills for your tools
   - Configure endpoints based on research findings
   - Test routing through OmniRoute from your IDE

## Tips for Effective Use

### Before Starting OmniRoute:
- **Use `research`** to understand the configuration options in `.env.example`
- **Use `find-skills`** to discover monitoring or analytics tools
- Read both results before diving into installation

### During Setup:
- **Use `research`** to troubleshoot build errors or configuration issues
- Reference the research findings alongside this README
- **Use `find-skills`** if you hit a problem and want a specialized skill

### In Production:
- **Use `research`** to periodically review provider terms and free tier changes
- **Use `find-skills`** to stay updated on new integrations and extensions
- Keep findings documented for your team

## Key Documentation to Research

When using the `@research` skill, these are the most valuable docs:

| Topic | File | Research Goal |
|-------|------|---------------|
| **Free Tiers** | `docs/reference/FREE_TIERS.md` | Current token budgets and provider pools |
| **Routing** | `src/lib/routing/` | How strategies work and custom extensions |
| **Compression** | `src/lib/compression/` | RTK and Caveman token savings |
| **Dashboard** | `src/app/dashboard/` | Available monitoring features |
| **API** | `src/app/api/` | OpenAI-compatible endpoint usage |
| **Provider Config** | `src/lib/providers/` | Available providers and their APIs |

## Integration Patterns

### Pattern 1: Monitor & Alert

```
OmniRoute Dashboard 
    ↓ (reads free tier budget via /dashboard/free-tiers)
Skills-based Analytics Tool
    ↓ (discovered via find-skills)
Your Alert System (Slack, email, etc.)
```

Use `research` to understand the dashboard API, `find-skills` to find analytics tools.

### Pattern 2: Route & Optimize

```
Your App / Claude Code 
    ↓ (calls http://localhost:20128/api/v1)
OmniRoute Routing Logic
    ↓ (strategy = cost_optimized)
Selected Provider (GPT / Claude / Gemini / etc.)
```

Use `research` to understand routing config, `find-skills` to find policy tools.

### Pattern 3: Extend & Automate

```
Custom Skill (discovered via find-skills)
    ↓ (uses OmniRoute API findings from research)
OmniRoute Instance
    ↓ (applies custom logic)
Enhanced Routing Decision
```

Use both skills together to build end-to-end automation.

## Troubleshooting via Skills

| Problem | Skill | Query |
|---------|-------|-------|
| "Why won't OmniRoute build?" | `@research` | Build errors and Node version requirements |
| "How do I configure a new provider?" | `@research` | Provider configuration format in docs |
| "What routing strategies exist?" | `@research` | Routing strategy implementations |
| "How do I monitor usage?" | `@find-skills` + `@research` | Analytics tools + dashboard API |
| "Can I customize routing?" | `@research` | Routing extension patterns |
| "What tools work with OmniRoute?" | `@find-skills` | IDE integrations, monitoring, analytics |

## Next Steps

1. **Install OmniRoute:** Follow `README.md` to set up the gateway
2. **Use research:** Understand your configuration options before starting
3. **Use find-skills:** Discover complementary tools and integrations
4. **Integrate:** Point your development tools to the OmniRoute endpoint
5. **Monitor:** Use discovered analytics tools to track usage
6. **Optimize:** Use research findings to refine your routing strategy

---

**Have questions?** 
- Use `@research` to find answers in the OmniRoute docs
- Use `@find-skills` to discover community solutions
- Join the [OmniRoute Discord](https://discord.gg/U47eFqAXCn)
