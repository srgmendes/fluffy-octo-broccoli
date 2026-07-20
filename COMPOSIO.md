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

## Using it locally instead (optional)

If you'd rather use the interactive CLI with browser login, run these on your own
computer (not the sandbox):

```bash
curl -fsSL https://composio.dev/install | bash
composio login
```
