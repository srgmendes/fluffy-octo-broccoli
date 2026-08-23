# OmniRoute Setup

[OmniRoute](https://github.com/diegosouzapw/OmniRoute) is a free AI gateway that aggregates 290+ AI providers and their free tiers into a single endpoint with intelligent routing, token compression, and fallback strategies.

## What OmniRoute Does

- **Unified endpoint** — route to Claude, GPT, Gemini, and 290+ other providers through one API
- **~1.53B free tokens/month** — aggregates and tracks documented free tiers from 43 provider pools
- **Auto-fallback** — if one provider hits rate limits, automatically routes to another
- **Token compression** — RTK + Caveman stacked compression saves 15–95% tokens (avg ~89%)
- **19 routing strategies** — intelligent selection based on model, cost, latency, or reliability
- **Dashboard** — live view of free tier budgets, usage, and provider status
- **Compatible with Claude Code, Cursor, Cline, Copilot** — works with popular coding tools

## Requirements

- **Node.js** 20.12+ (check with `node --version`)
- **npm** 10+ (comes with Node)
- **Git** (to clone the repository)
- **~2GB disk space** for dependencies and build output
- **RAM**: 2GB+ recommended for building; 1GB sufficient for running

### Sandbox / Cloud Environment Notes

- **Outbound network**: requires access to `github.com`, `npmjs.com`, and your AI provider APIs
- **Disk space**: verify with `df -h` before cloning
- **File descriptors**: if you hit "too many open files" during build, consider limiting parallel workers (see troubleshooting below)

## Installation

### 1. Clone OmniRoute

Run the install script to clone the official repository:

```bash
./omniroute/install.sh
```

This clones to `omniroute/checkout/`, which is git-ignored so it won't be committed to this repo.

### 2. Configure Environment

```bash
cd omniroute/checkout
cp .env.example .env
# Edit .env and set your values
```

**Key environment variables:**

- **`INITIAL_PASSWORD`** — Dashboard login password (required; use something strong)
- **`OMNIROUTE_USE_TURBOPACK`** — `0` to use webpack (recommended if you hit OOM during build; webpack uses less memory)
- Provider API keys — optional; OmniRoute works with free tiers by default

### 3. Install Dependencies

```bash
npm ci
```

This installs ~1,471 dependencies pinned in `package-lock.json`.

### 4. Build

```bash
npm run build
```

First build takes 5–15 minutes depending on your machine. Uses Next.js with Turbopack/webpack.

**If you hit memory limits:**
- Set `OMNIROUTE_USE_TURBOPACK=0` in `.env` before building (uses webpack, ~3.9GB vs. Turbopack's 15GB+)
- On very constrained systems, limit parallelism: `taskset -c 0,1 npm run build` (2 cores only)

### 5. Start the Server

**Production:**
```bash
npm start
# Server listens on http://127.0.0.1:20128
```

**Development (hot-reload):**
```bash
npm run dev
```

### 6. Access the Dashboard

Open your browser to **http://127.0.0.1:20128** and log in with the password you set in `INITIAL_PASSWORD`.

From the dashboard you can:
- View free tier budgets and live usage (`/dashboard/free-tiers`)
- Manage API keys for any provider
- Configure routing strategies
- Monitor request logs

## Integration with Claude Code Skills

This repository includes two skills that pair well with OmniRoute:

### `find-skills` Skill

Use the find-skills skill to discover additional capabilities for working with OmniRoute:
- Research tools for analyzing provider docs
- Integration patterns for connecting routing strategies to your own tools
- Community-contributed OmniRoute extensions

### `research` Skill

Use the research skill to:
- Explore OmniRoute's architecture and source code
- Analyze provider pricing and free tier terms
- Research optimal routing strategies for your use case
- Document findings about AI provider APIs

## Using OmniRoute as an AI Gateway

Once running, OmniRoute exposes an OpenAI-compatible endpoint at `http://127.0.0.1:20128/api/v1`.

### Example: Use with Claude Code or Your Tools

If your tool supports custom endpoints, point it to OmniRoute:

```bash
# Example: curl to OmniRoute
curl http://127.0.0.1:20128/api/v1/chat/completions \
  -H "Authorization: Bearer your_omniroute_api_key" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "gpt-4-turbo",
    "messages": [{"role": "user", "content": "Hello"}]
  }'
```

See the OmniRoute documentation for routing strategy configuration and fallback rules.

## Troubleshooting

### Build fails with "Out of memory"

Use webpack instead of Turbopack:
```bash
echo "OMNIROUTE_USE_TURBOPACK=0" >> .env
npm run build
```

Or limit parallelism:
```bash
taskset -c 0,1 npm run build
```

### Build fails with "EMFILE: too many open files"

Reduce file descriptor usage by limiting workers:
```bash
taskset -c 0,1 npm run build
```

### Dashboard login fails

1. Verify the password in `.env` matches `INITIAL_PASSWORD`
2. Check the server is running: `ps aux | grep node`
3. Confirm the server started successfully by checking logs

### Server won't start

1. Check Node.js version: `node --version` (should be 20.12+)
2. Verify port 20128 is available: `lsof -i :20128` (should return nothing)
3. Check logs for errors: look at terminal output when running `npm start`

## Updates and Maintenance

### Update OmniRoute to Latest

```bash
cd omniroute/checkout
git fetch origin
git checkout <version-tag>  # or 'main' for latest
npm ci
npm run build
npm start
```

### Reset Database/Settings

OmniRoute stores configuration in `~/.omniroute/storage.sqlite`. To reset:

```bash
rm -rf ~/.omniroute/
# Restart the server — it will re-initialize with .env values
```

## Resources

- **GitHub**: https://github.com/diegosouzapw/OmniRoute
- **Dashboard Docs**: See the `/dashboard/` section in the app itself
- **Free Tiers Reference**: https://github.com/diegosouzapw/OmniRoute/blob/main/docs/reference/FREE_TIERS.md
- **Discord Community**: https://discord.gg/U47eFqAXCn
- **Website**: https://omniroute.online

## Next Steps

1. ✅ Install OmniRoute (this guide)
2. Use the `research` skill to explore routing strategies
3. Use the `find-skills` skill to discover integrations
4. Configure API keys in the dashboard as needed
5. Point your Claude Code or other tools to the OmniRoute endpoint

---

**Questions?** Join the [OmniRoute Discord](https://discord.gg/U47eFqAXCn) or open an issue on [GitHub](https://github.com/diegosouzapw/OmniRoute/issues).
