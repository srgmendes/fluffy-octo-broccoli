// Minimal Composio SDK example.
//
// Run it with:   COMPOSIO_API_KEY=your_key node composio-example.mjs
// (or put the key in a .env file — see .env.example)
//
// In the Claude Code cloud sandbox, also set NODE_USE_ENV_PROXY=1 so Node's
// built-in fetch routes through the sandbox proxy:
//   COMPOSIO_API_KEY=your_key NODE_USE_ENV_PROXY=1 node composio-example.mjs
//
// This connects to Composio and lists the toolkits (app integrations) available
// to your account, just to prove the SDK and your key work end to end.

import { Composio } from '@composio/core';

const apiKey = process.env.COMPOSIO_API_KEY;

if (!apiKey) {
  console.error(
    'Missing COMPOSIO_API_KEY.\n' +
      'Get a key from https://app.composio.dev (Settings -> API Keys),\n' +
      'then run:  COMPOSIO_API_KEY=your_key node composio-example.mjs',
  );
  process.exit(1);
}

const composio = new Composio({ apiKey });

try {
  const res = await composio.toolkits.get({});
  const items = res.items ?? res;
  console.log(`Connected to Composio. Found ${items.length} toolkit(s).`);
  for (const t of items.slice(0, 10)) {
    console.log(` - ${t.slug ?? t.name}`);
  }
} catch (err) {
  console.error('Composio request failed:', err.message ?? err);
  if (err.cause) console.error('Cause:', err.cause.message ?? err.cause);
  process.exit(1);
}
