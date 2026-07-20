# Composio setup (SDK / code approach)

The Composio **CLI** (`composio login`) can't run in the Claude Code cloud sandbox:
its binary is only distributed via GitHub releases of the `ComposioHQ/composio`
repo, which the sandbox's GitHub proxy blocks, and `composio login` needs a
browser the sandbox doesn't have. So this repo uses the **Composio SDK** instead,
which works fully in code with just an API key.

## What's installed

- [`@composio/core`](https://www.npmjs.com/package/@composio/core) — the official
  Composio SDK, added as a dependency in `package.json`.

## One-time setup

1. Get an API key from the Composio dashboard: https://app.composio.dev
   (Settings → API Keys).
2. Copy the example env file and paste your key in:
   ```bash
   cp .env.example .env
   # then edit .env and replace the placeholder with your real key
   ```
   `.env` is git-ignored, so your key never gets committed.

## Run the example

```bash
COMPOSIO_API_KEY=your_key node composio-example.mjs
```

It connects to Composio and lists the toolkits available to your account — a quick
way to confirm the SDK and your key work.

### In the Claude Code cloud sandbox

Node's built-in `fetch` doesn't use the sandbox's network proxy by default, so add
`NODE_USE_ENV_PROXY=1`:

```bash
COMPOSIO_API_KEY=your_key NODE_USE_ENV_PROXY=1 node composio-example.mjs
```

This is only needed inside the cloud sandbox; on your own machine the plain command
works. (The sandbox environment must also allow `composio.dev` and `*.composio.dev`
in its network egress settings — the SDK talks to `backend.composio.dev`.)

## Connecting an app (e.g. Outlook)

Use `composio-connect.mjs` to connect an app to your account via OAuth. This needs
an API key with **write** access to auth_configs.

```bash
COMPOSIO_API_KEY=your_key NODE_USE_ENV_PROXY=1 node composio-connect.mjs outlook you@example.com
```

It prints a login link — open it, sign in and approve, and the script waits until
the connection is ACTIVE. Composio manages the OAuth, so you don't need to register
your own Microsoft/Google/etc. app.

## Using it locally instead (optional)

If you'd rather use the interactive CLI with browser login, run these on your own
computer (not the sandbox):

```bash
curl -fsSL https://composio.dev/install | bash
composio login
```
