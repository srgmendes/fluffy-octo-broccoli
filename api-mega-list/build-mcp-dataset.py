#!/usr/bin/env python3
"""Extract the MCP servers listed in cporter202/api-mega-list into CSVs.

That repo is a directory of Apify actors: one README.md per category, each a
Markdown table of `| [Name](url) | Description |` rows. Its `mcp-servers-*`
category is unreliable — it both contains plain scrapers and omits real MCP
servers that upstream filed under `ai-apis` / `developer-tools` instead — so we
classify every row in every category ourselves.

Nothing here contacts Apify: classification is based on the repo's own text.
"A row says it is an MCP server" is the claim being recorded, not a verified fact.

Usage:  ./build-mcp-dataset.py /path/to/api-mega-list [outdir]
"""
import csv, glob, os, re, sys
from collections import Counter
from urllib.parse import urlsplit, urlunsplit, parse_qsl, urlencode

ROW = re.compile(r'^\|\s*\[(?P<name>.*?)\]\((?P<url>[^)\s]+)\)\s*\|(?P<desc>.*?)\|\s*$')

# MCP named as the product itself.
IDENTITY = re.compile(r'\bMCP\s*(server|gateway|client)\b', re.I)
# MCP named only as a compatibility claim bolted onto some other product.
CLAIM    = re.compile(r'MCP[-\s]*ready|\bMCP\s*&|\bMCP,|\bvia\s+MCP|\bMCP\s*\+', re.I)
TOKEN    = re.compile(r'(?<![A-Za-z])MCP(?![A-Za-z])', re.I)
# Name is silent but the description says the thing *is* an MCP server.
DESC_IS  = re.compile(r'\bMCP\s*(server|gateway|client)\b|\bas an?\s+(?:\w+\s+)?MCP\b', re.I)

BASE   = ["name", "publisher", "slug", "url", "url_with_affiliate", "description"]
SIGNAL = BASE + ["mcp_signal"]                              # one category, no cross-listing
FULL   = SIGNAL + ["categories", "in_mcp_category"]         # deduped across all categories


def classify(name, desc, slug):
    """Order matters: product identity beats a marketing claim in the same string."""
    if IDENTITY.search(name):            return True,  "named-mcp-server"
    if "mcp" in slug.lower().split("-"): return True,  "mcp-in-slug"
    if DESC_IS.search(desc):             return True,  "mcp-server-in-description"
    if CLAIM.search(name):               return False, "mcp-ready-claim-only"
    if TOKEN.search(name):               return True,  "mcp-in-name"
    if "mcp" in desc.lower():            return False, "mcp-in-description-only"
    return False, "no-mcp-signal"


def parse_rows(path):
    """Yield one dict per table row in a category README."""
    for line in open(path, encoding="utf-8"):
        line = line.rstrip("\n")
        if not line.startswith("|") or line.startswith("| API Name") or set(line) <= set("|- "):
            continue
        m = ROW.match(line)
        if not m:
            continue
        url = m.group("url")
        parts = urlsplit(url)
        # Drop the affiliate tag; keep the original link alongside it.
        q = [(k, v) for k, v in parse_qsl(parts.query) if k != "fpr"]
        clean = urlunsplit((parts.scheme, parts.netloc, parts.path, urlencode(q), parts.fragment))
        seg = [s for s in parts.path.split("/") if s]
        publisher, slug = (seg + ["", ""])[:2] if parts.netloc == "apify.com" else ("", seg[-1] if seg else "")
        yield {"name": m.group("name").strip(), "publisher": publisher, "slug": slug,
               "url": clean, "url_with_affiliate": url,
               "description": " ".join(m.group("desc").split())}


def write(path, rows, key, fields):
    rows = sorted(rows, key=key)
    with open(path, "w", newline="", encoding="utf-8") as f:
        w = csv.DictWriter(f, fieldnames=fields, extrasaction="ignore")
        w.writeheader()
        w.writerows(rows)
    print(f"  {len(rows):>4} rows  {os.path.basename(path)}")


def main(repo, outdir):
    by_name = lambda r: r["name"].lower()
    by_pub  = lambda r: (r["publisher"].lower(), r["name"].lower())

    # 1. The MCP category on its own: every row, then the keep/drop split.
    cat = sorted(glob.glob(f"{repo}/mcp-servers-*/README.md"))
    if not cat:
        sys.exit(f"no mcp-servers-*/README.md under {repo}")
    category, excluded = [], []
    for r in parse_rows(cat[0]):
        keep, r["mcp_signal"] = classify(r["name"], r["description"], r["slug"])
        category.append(r)
        if not keep:
            excluded.append(r)

    # 2. Every category, deduped by URL — an actor is cross-listed in several.
    hits = {}
    scanned = 0
    for path in sorted(glob.glob(f"{repo}/**/README.md", recursive=True)):
        category_dir = os.path.dirname(os.path.relpath(path, repo))
        if not category_dir:
            continue  # root README duplicates every category section
        for r in parse_rows(path):
            scanned += 1
            keep, signal = classify(r["name"], r["description"], r["slug"])
            if not keep:
                continue
            if r["url"] in hits:
                hits[r["url"]]["_cats"].add(category_dir)
            else:
                hits[r["url"]] = {**r, "mcp_signal": signal, "_cats": {category_dir}}
    servers = []
    for r in hits.values():
        cats = sorted(r.pop("_cats"))
        r["categories"] = "; ".join(cats)
        r["in_mcp_category"] = "yes" if any(c.startswith("mcp-servers-") for c in cats) else "no"
        servers.append(r)

    print(f"scanned {scanned} table rows across {len(set(glob.glob(f'{repo}/**/README.md', recursive=True)))} files")
    write(f"{outdir}/mcp-servers-apis.csv", category, by_name, SIGNAL)
    write(f"{outdir}/mcp-servers-excluded.csv", excluded, by_name, SIGNAL)
    write(f"{outdir}/mcp-servers-outside-category.csv",
          [r for r in servers if r["in_mcp_category"] == "no"], by_name, FULL)
    write(f"{outdir}/mcp-servers-real.csv", servers, by_pub, FULL)
    print("signals:", Counter(r["mcp_signal"] for r in servers).most_common())


if __name__ == "__main__":
    if len(sys.argv) < 2:
        sys.exit(__doc__)
    main(sys.argv[1].rstrip("/"), sys.argv[2].rstrip("/") if len(sys.argv) > 2 else ".")
