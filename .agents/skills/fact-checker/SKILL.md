---
name: fact-checker
description: Verifies the factual claims in a piece of text before it's published or sent. Use when the user says "/fact-checker", asks to "fact-check this", "verify these claims", "is this accurate", or is about to publish something and wants the facts checked. Flags what's true, false, unverifiable, or misleading, with sources.
---

# Fact-Checker

Check the factual claims in a draft before it goes out. The goal is to catch anything wrong, unsupported, or misleading — with enough evidence that the user can trust the verdict or fix the claim.

## When to Use This Skill

- The user types `/fact-checker`, or asks to "fact-check", "verify", or "check the facts".
- They're about to publish, send, or cite something and want the claims stress-tested.

## The Method

### 1. Extract the checkable claims

Pull out every statement of fact — numbers, dates, names, quotes, causal claims, "studies show", superlatives ("the first", "the largest"), and anything stated as objective truth. Ignore opinion, framing, and clearly hypothetical language; those aren't fact-checkable.

List them so the user can see what you're checking.

### 2. Verify against primary sources

For each claim, check it against the most authoritative source available — official docs, the original study, first-party data, the primary record — not a secondary write-up. Use `WebSearch` / `WebFetch` where live verification helps; follow each claim back to the source that actually owns it.

Do not verify a claim from memory alone if it's the kind of thing that changes over time (prices, versions, current office-holders, "latest" anything) or that you're not certain of. Say when you couldn't verify.

### 3. Assign a verdict to each claim

- ✅ **Supported** — verified against a reliable source. Cite it.
- ❌ **Contradicted** — the source says otherwise. Give the correct fact and the source.
- ⚠️ **Unverifiable** — no reliable source found, or the claim is too vague to check. Say what's missing.
- 🟡 **Misleading** — technically true but framed in a way that misleads (cherry-picked, missing context, stale). Explain the distortion.

### 4. Report

Lead with the headline: is the piece safe to publish as-is, or are there claims to fix first? Then the per-claim table with verdicts and sources. Put ❌ and 🟡 items first — those are what the user needs to act on.

## Rules

1. **Cite every verdict.** A verdict without a source is just an opinion. Link or name the source for anything you mark supported or contradicted.
2. **Separate "false" from "unverifiable".** Not finding evidence is not the same as finding it's wrong. Don't overstate.
3. **Check the claim actually made,** not a stronger or weaker version of it. Quote the exact wording you're checking.
4. **Flag confidence.** If a source is dated, contested, or second-hand, say so rather than presenting it as settled.
5. **Stay in scope.** Check facts; don't rewrite the argument or editorialize on the take — unless a framing is actively misleading, which *is* a factual problem worth flagging.
