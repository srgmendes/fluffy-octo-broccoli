# Public APIs (vendored)

This directory vendors the [`public-apis/public-apis`](https://github.com/public-apis/public-apis)
repository: a community-curated Markdown list of free public APIs, organized by
category (Animals, Finance, Weather, etc.). There is nothing to build or run —
it's a reference document, not application code.

- `README.md` — the full curated API list (source of truth, browse or grep it).
- `CONTRIBUTING.md` — upstream's guidelines for proposing additions to the list.
- `LICENSE` — upstream's MIT license.

**Vendored, not a submodule.** Copied in as a snapshot (commit
`b2ad91b0784237ef8e7eebfa4d2310c65a0a7b97`, 2026-08-17) with git history
stripped, same as `llm-council/`. To refresh, re-pull `README.md` /
`CONTRIBUTING.md` / `LICENSE` from upstream and review the diff — upstream is
actively maintained via community PRs, so check periodically for updates.

Upstream's own contributor tooling (`.github/` PR/issue templates, CI
workflows, and `scripts/` validation scripts used to lint PRs against the
list) was intentionally left out: it exists to support *contributing back to
public-apis/public-apis*, not to using the list here.
