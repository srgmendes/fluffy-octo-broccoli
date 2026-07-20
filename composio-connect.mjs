// Connect an app (toolkit) to your Composio account via OAuth.
//
// Usage:
//   COMPOSIO_API_KEY=your_key NODE_USE_ENV_PROXY=1 node composio-connect.mjs <toolkit> [userId]
//
// Example:
//   COMPOSIO_API_KEY=your_key NODE_USE_ENV_PROXY=1 node composio-connect.mjs outlook you@example.com
//
// It creates (or reuses) a Composio-managed auth config for the toolkit, then
// prints a login link. Open the link, sign in / approve, and the script waits for
// the connection to become ACTIVE.
//
// Notes:
//  - Requires an API key with WRITE access to auth_configs (a read-only key can't
//    create the auth config).
//  - NODE_USE_ENV_PROXY=1 is only needed inside the Claude Code cloud sandbox.

import { Composio } from '@composio/core';

const toolkit = process.argv[2];
const userId = process.argv[3] || 'default';

if (!process.env.COMPOSIO_API_KEY || !toolkit) {
  console.error(
    'Usage: COMPOSIO_API_KEY=your_key node composio-connect.mjs <toolkit> [userId]\n' +
      'Example: ... node composio-connect.mjs outlook you@example.com',
  );
  process.exit(1);
}

const composio = new Composio({ apiKey: process.env.COMPOSIO_API_KEY });

// Reuse an existing managed auth config for this toolkit, or create one.
async function getAuthConfigId(slug) {
  const res = await composio.authConfigs.list();
  const items = res.items ?? res;
  const existing = items.find((a) => (a.toolkit?.slug ?? a.toolkitSlug) === slug);
  if (existing) return existing.id;

  const created = await composio.authConfigs.create(slug, { type: 'use_composio_managed_auth' });
  return created.id ?? created.authConfigId;
}

const authConfigId = await getAuthConfigId(toolkit);
console.log(`Auth config for "${toolkit}": ${authConfigId}`);

const conn = await composio.connectedAccounts.link(userId, authConfigId);
console.log(`\nOpen this link in your browser to connect "${toolkit}":\n  ${conn.redirectUrl}\n`);
console.log('Waiting for you to finish authorizing...');

const active = await composio.connectedAccounts.waitForConnection(conn.id);
console.log(`\nConnected! status: ${active.status}  (connection id: ${conn.id})`);
