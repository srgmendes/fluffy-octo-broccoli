# camofox-browser (MCP integration for Claude)

Wires [`jo-inc/camofox-browser`](https://github.com/jo-inc/camofox-browser) —
an **anti-detection browser server for AI agents**, built on
[Camoufox](https://camoufox.com) (a Firefox fork that spoofs fingerprints at the
C++ level) — into Claude Code as a set of MCP tools.

Like the other areas in this repo, this is a **self-contained integration
setup**: a Docker Compose deployment of the browser server plus the MCP
registration Claude reads. No application code is vendored here — the server is
built straight from the pinned upstream repo.

## How the pieces fit

camofox-browser is two processes, and Claude uses both:

```
┌─────────────┐   spawns    ┌──────────────────────┐   HTTP    ┌─────────────────────┐
│ Claude Code │────────────▶│  MCP adapter (stdio)  │──────────▶│  REST server :9377  │
│  (session)  │  per session│ @askjo/camofox-       │  localhost│  Camoufox / Firefox │
└─────────────┘             │  browser-mcp          │           │  (this compose file)│
                            └──────────────────────┘           └─────────────────────┘
```

- **REST server** — launches the Camoufox engine and exposes the HTTP API on
  port **9377**. Run it **once**; it stays up (lazy browser launch, idle
  shutdown → ~40MB when idle). This is what `docker-compose.yml` here runs.
- **MCP adapter** (`@askjo/camofox-browser-mcp`) — a thin stdio client that
  translates MCP tool calls into REST calls. Claude Code spawns **one per
  session** from the repo-root [`.mcp.json`](../.mcp.json); it needs only Node,
  not the browser binary.

The adapter does nothing on its own — **the REST server must be running** at
`CAMOFOX_BASE_URL` (default `http://localhost:9377`) or every tool call fails.

## 1. Start the REST server

```bash
cd camofox-browser
docker compose up -d --build     # first start builds the image (bakes in the
                                 # ~300MB Camoufox binary — this is slow)
docker compose up -d             # subsequent starts (no rebuild)
docker compose logs -f           # follow logs
docker compose ps                # check health (waits ~60s to report healthy)
docker compose down              # stop and remove
```

The image is built from the upstream repo pinned to a specific commit in
`docker-compose.yml`. To upgrade, bump the `#<sha>` fragment on the build
`context` (and the pinned MCP version in `../.mcp.json` to match), then
`docker compose up -d --build`.

> **No Docker?** You can instead run the server from an upstream checkout:
> `git clone https://github.com/jo-inc/camofox-browser && cd camofox-browser
> && npm install && npm start` (Node ≥ 22; downloads Camoufox on first run).
> Either way it must end up listening on `http://localhost:9377`.

## 2. Register with Claude

Already done — [`.mcp.json`](../.mcp.json) at the repo root registers the
`camofox-browser` MCP server for this project:

```json
{
  "mcpServers": {
    "camofox-browser": {
      "command": "npx",
      "args": ["-y", "@askjo/camofox-browser-mcp@1.13.1"],
      "env": { "CAMOFOX_BASE_URL": "http://localhost:9377" }
    }
  }
}
```

- **Claude Code** picks this up automatically when you open the project. Because
  it's a project-scoped server, Claude Code prompts you once to **approve** it;
  if a session was already open, restart it (or run `/mcp`) so the server loads.
  `npx -y` fetches the pinned adapter on first use (Node ≥ 22 required).
- Prefer it available in **every** project instead? Register it user-scoped:
  ```bash
  claude mcp add camofox-browser -s user \
    --env CAMOFOX_BASE_URL=http://localhost:9377 \
    -- npx -y @askjo/camofox-browser-mcp@1.13.1
  ```
- **Claude Desktop** speaks the same MCP config — add the identical
  `camofox-browser` block to its `claude_desktop_config.json`
  (Settings → Developer → Edit Config).

## 3. Verify

In Claude Code, run `/mcp` — `camofox-browser` should show **connected** with
**11 tools**:

`camofox_create_tab`, `camofox_snapshot`, `camofox_click`, `camofox_type`,
`camofox_navigate`, `camofox_scroll`, `camofox_screenshot`,
`camofox_evaluate`, `camofox_list_tabs`, `camofox_close_tab`,
`camofox_import_cookies`.

Then ask Claude to browse something, e.g. *"open example.com and snapshot it."*
The usual loop is **snapshot before you act**: `create_tab` → `snapshot` (gives
element refs `e1`, `e2`, …) → `click`/`type` by ref → `snapshot` again →
`close_tab`.

## Configuration

Optional settings live in `.env` (copy from [`.env.example`](.env.example)) — a
private, localhost-only setup needs none of them.

| Var | Where | Purpose |
| --- | --- | --- |
| `MAX_OLD_SPACE_SIZE` | `.env` | Node heap cap (MB) for the server. Default `128`. |
| `CAMOFOX_ACCESS_KEY` | `.env` **and** `../.mcp.json` | Global bearer token gating **every** REST call. If set on the server, set the **same** value in the adapter's `env` or all tool calls 401/403. |
| `CAMOFOX_API_KEY` | `.env` **and** `../.mcp.json` | Secret gating cookie import only. Optional on localhost; required if exposed remotely. |
| `CAMOFOX_BASE_URL` | `../.mcp.json` | REST server URL the adapter targets. Default `http://localhost:9377`. Point it elsewhere to use a server running on another host. |

Secrets follow the repo-wide rule: `.env` is git-ignored; only `.env.example`
is tracked. If you add an auth key, put it in **both** places (server `.env` and
adapter env in `../.mcp.json`) or auth will mismatch.

## Troubleshooting

- **`/mcp` shows the server but tool calls fail / time out** — the REST server
  isn't running or isn't reachable at `CAMOFOX_BASE_URL`. Check
  `docker compose ps` and `curl http://localhost:9377/health`.
- **`401`/`403` on every tool call** — the server has `CAMOFOX_ACCESS_KEY` set
  but the adapter doesn't. Add the same value to `../.mcp.json`'s `env`.
- **`503 session_expired` / `tab create timed out`** — the browser session
  died. `docker compose restart camofox-browser`.
- **`403` only on `camofox_import_cookies`** — `CAMOFOX_API_KEY` mismatch
  between server and adapter.
- **`camofox_scroll` no-ops on lazy-load pages** — expected; have Claude use
  `camofox_evaluate` with `window.scrollTo` / `scrollBy` instead.

For the full REST API and tool contracts, see the upstream
[README](https://github.com/jo-inc/camofox-browser#readme) and
[`mcp/README.md`](https://github.com/jo-inc/camofox-browser/blob/master/mcp/README.md).
