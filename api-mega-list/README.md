# API Mega List — MCP server extract

CSV extracts of the **MCP servers** listed in
[`cporter202/api-mega-list`](https://github.com/cporter202/api-mega-list), a
GitHub directory of ~11,860 API listings.

Unlike the other areas in this repo, this is **derived data, not a deployment**:
four CSVs plus the script that regenerates them. Nothing here runs as a service.

## Why this exists

The upstream repo has an `mcp-servers-apis-289/` category, but browsing it is
misleading in both directions:

- It **contains plain scrapers** — entries whose only connection to MCP is
  "MCP-ready" in the marketing blurb.
- It **omits real MCP servers**. A third of them (48 of 142) are filed under
  `ai-apis-1555` / `developer-tools-apis-4065` instead. Categorization appears
  to run per-publisher: `ryanclinton` (14 servers) and `martc03` (7) have every
  one of their MCP servers outside the MCP category.

So every table row in every category is classified here rather than trusting
the category label.

## Files

| File | Rows | What |
| --- | --- | --- |
| `mcp-servers-real.csv` | 142 | **The main output.** Every MCP server found anywhere in the repo, deduped, sorted by publisher. |
| `mcp-servers-outside-category.csv` | 48 | The subset the MCP category missed. |
| `mcp-servers-apis.csv` | 289 | Raw extract of the MCP category, every row, classified. |
| `mcp-servers-excluded.csv` | 195 | MCP-category rows rejected as not-MCP-servers, with the reason. |

Columns: `name`, `publisher`, `slug`, `url`, `url_with_affiliate`,
`description`, `mcp_signal`, and — on the deduped files — `categories` and
`in_mcp_category`.

Upstream links carry an affiliate tag (`?fpr=`); `url` has it stripped and
`url_with_affiliate` keeps the original.

## `mcp_signal` — why a row was kept or dropped

Checked in order; product identity beats a marketing claim in the same string.

| Signal | Kept | Meaning |
| --- | --- | --- |
| `named-mcp-server` | yes | Name says "MCP Server / Gateway / Client" |
| `mcp-in-slug` | yes | `mcp` is a token in the URL slug |
| `mcp-server-in-description` | yes | Name is silent, description says it *is* an MCP server |
| `mcp-in-name` | yes | Standalone `MCP` token in the name (e.g. `Card Grader MCP`) |
| `mcp-ready-claim-only` | no | "MCP-Ready", "via MCP" — a compatibility claim on another product |
| `mcp-in-description-only` | no | MCP appears only in the blurb, as a feature |
| `no-mcp-signal` | no | No mention anywhere |

## Caveats

- **Unverified.** This classifies the upstream repo's own marketing text. No row
  has been confirmed to actually serve MCP — `apify.com` was blocked by the
  sandbox egress policy at extraction time. Allowing `api.apify.com` would let
  each actor be checked against the public actor API.
- **Point-in-time.** Upstream states it was last updated `2026-07-23`; these
  CSVs were built from commit `be78c4e`.
- **Descriptions are truncated** to ~150 characters by upstream, sometimes
  mid-sentence — which is why four rows rest on partial description evidence.
- **Concentration is high.** 49 publishers, but the top 10 hold 87 of 142
  servers; `nexgendata` alone has 23.

## Regenerating

```bash
git clone --depth 1 https://github.com/cporter202/api-mega-list /tmp/api-mega-list
./build-mcp-dataset.py /tmp/api-mega-list .
```

The script is offline and deterministic — it only parses the cloned Markdown.
