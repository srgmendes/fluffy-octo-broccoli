# MCP servers

Four MCP servers are configured for this repo in `.mcp.json` (project scope, so
the config is shared via git and picked up by anyone who checks the repo out).

| Server | Transport | Auth | Cost |
| --- | --- | --- | --- |
| `playwright` | stdio (`npx @playwright/mcp@latest`) | none | free |
| `composio` | HTTP | OAuth (browser sign-in) | free tier |
| `firecrawl` | HTTP | `FIRECRAWL_API_KEY` bearer token | free tier |
| `perplexity` | HTTP | `PERPLEXITY_API_KEY` bearer token | **paid** |

## Setup

### 1. Keys

`.mcp.json` reads the two API keys from the environment via `${VAR}` expansion,
so no secret is ever committed — the same pattern the rest of this repo uses for
`COMPOSIO_API_KEY`.

```bash
cp .env.example .env    # then paste your real keys in
```

Claude Code does **not** auto-load `.env`. Export the vars in the shell you
launch `claude` from (or use your usual dotenv loader / shell profile):

```bash
set -a; source .env; set +a
claude
```

Without the keys set, Claude Code reports
`Missing environment variables: FIRECRAWL_API_KEY` and starts the other servers
normally — the unconfigured server is simply unavailable, nothing else breaks.

### 2. Approve the servers

Project-scoped servers need a one-time approval per machine. Start `claude` in
this directory and approve when prompted, or check state at any time with:

```bash
claude mcp list
```

### 3. Sign in to Composio

Composio uses OAuth 2.1 (dynamic client registration + PKCE against
`login.composio.dev`) rather than an API key. Inside `claude`, run:

```
/mcp
```

then pick `composio` and authenticate. This opens a browser and redirects back
to a `localhost` callback, so it only works on a machine where you have a
browser — see the sandbox note below.

## Per-server notes

### Playwright

Drives a real browser (navigate, click, type, snapshot, screenshot). Exposes 24
tools; needs no key.

By default `@playwright/mcp` launches branded Google Chrome. If Chrome isn't
installed you'll get `Chromium distribution 'chrome' is not found`. Either
install Chrome, or switch the server to Playwright's own bundled Chromium by
adding `"--browser", "chromium"` to the `args` in `.mcp.json`.

### Composio

Broker that connects third-party apps (Outlook, Gmail, Slack, …) and exposes
their actions as MCP tools. Unrelated to the `composio-*.mjs` scripts at the repo
root, which use the Composio **SDK** with `COMPOSIO_API_KEY` — see `COMPOSIO.md`.
The two can coexist; the MCP server is for using Composio tools from inside
Claude, the SDK scripts are for wiring up connections programmatically.

Composio is also available as a **claude.ai connector**, which authenticates at
the account level and works in Claude web/desktop without any local config. That
path avoids the localhost-callback problem entirely.

### Firecrawl

Web search, scraping and crawling. Free-tier key from
<https://www.firecrawl.dev/app/api-keys>. Firecrawl also offers a keyless mode
and an OAuth endpoint (`https://mcp.firecrawl.dev/v2/mcp-oauth`); this repo uses
the API-key endpoint documented at <https://docs.firecrawl.dev/mcp-server>.

Note that Firecrawl is *also* available as a claude.ai connector. If you have
that connected, Claude web/desktop already has Firecrawl and this entry is only
needed for the Claude Code CLI, which uses its own quota against your key.

### Perplexity

Web-grounded search and research answers with citations. Requires a **paid** API
key (`pplx-…`) from <https://www.perplexity.ai/account/api>. Endpoint and bearer
scheme per <https://docs.perplexity.ai/docs/getting-started/integrations/mcp-server>.

If you'd rather not pay, delete the `perplexity` block from `.mcp.json` — the
Firecrawl server covers most web-search needs.

## Sandbox caveat (Claude Code on the web)

In the Claude Code cloud sandbox, outbound HTTPS goes through a policy-enforcing
egress proxy. As configured today it allows `composio.dev` but **blocks**
`mcp.firecrawl.dev` and `api.perplexity.ai` (the proxy answers `403` to the
CONNECT). Those two servers therefore can't be reached from a web session
regardless of whether the keys are set — they work from a local machine. To use
them in the sandbox, an admin has to add those hosts to the environment's egress
allowlist.

Composio's OAuth flow also can't complete in the sandbox: it needs a browser and
a `localhost` callback the container has no way to serve. Sign in from a local
`claude` session, or use the claude.ai connector.

Playwright runs in the sandbox, but `@playwright/mcp`'s bundled Playwright
expects a newer Chromium build than the image ships. Point it at the pre-installed
binary:

```bash
npx -y @playwright/mcp@latest --browser chromium \
  --executable-path /opt/pw-browsers/chromium-1194/chrome-linux/chrome
```

Pages the browser then loads are still subject to the same egress allowlist.
