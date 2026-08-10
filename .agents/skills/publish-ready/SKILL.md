---
name: publish-ready
description: Runs a piece of writing through a full pre-publish pass — fact-check, then humanize — in the user's voice, so it's ready to send or post. Use when the user says "/publish-ready", "get this ready to publish", "final pass before I post", or hands over a near-final draft and wants it checked and polished in one go. Chains the fact-checker and humanizer skills.
---

# Publish-Ready

One pass that takes a near-final draft and gets it ready to go out: verify the claims, then fix how it reads — in the user's own voice. This is the last thing you run before publish or send.

## When to Use This Skill

- The user types `/publish-ready`, or asks for a "final pass", "ready to publish", "check and polish this".
- They have a draft that's substantively done and want it verified and cleaned in one step.

Do not use this to *write* the draft — it operates on text that already exists. If there's no draft yet, that's a `how-to` or drafting task first.

## The Order Matters

Run the steps in this sequence. Fact-check **before** humanize, never after.

### 1. Fact-check first

Apply the **`fact-checker`** skill: extract the checkable claims, verify each against primary sources, and assign verdicts (✅ / ❌ / ⚠️ / 🟡).

**Stop here if anything material is wrong.** Do not polish a draft that contains a false or misleading claim — a smoother version of a wrong statement is worse, because it reads more convincingly. Surface the ❌ and 🟡 items and get them resolved (corrected by you, or confirmed by the user) before moving on. Polishing a lie is the one thing this skill must never do.

### 2. Humanize second

Once the facts hold, apply the **`humanizer`** skill: strip AI tells (em-dashes, filler phrases, autopilot tricolons, uniform rhythm) while preserving meaning.

Do this after fact-checking so you're only polishing verified text — and so corrections made in step 1 also get the humanizing pass.

### 3. Voice check

Throughout, honor the user's **`about-me`** profile if one exists:
- Match the register the piece calls for (e.g. formal for legal/contractual, warmer-but-professional for HR/internal).
- Respect red lines (never-use words, hated formats).
- Humanizing means sounding like *the user*, not like a generic casual voice.

## Output

Deliver in this order:

1. **Verdict line** — is it publish-ready, or are there claims to resolve first? Lead with this.
2. **Claims to fix** (if any) — the ❌ / 🟡 items with sources, so the user can act. If these exist, the piece is *not* ready; say so plainly.
3. **The clean version** — the fact-corrected, humanized text, in the user's voice, ready to copy out.
4. **What changed** (brief) — a few lines: claims corrected, tells removed. Not a full diff.

## Rules

1. **Never polish an unverified claim into a confident one.** Facts before finish, every time.
2. **Preserve meaning and voice.** The pass improves accuracy and readability; it doesn't change the argument or flatten the user's register.
3. **Be honest about "ready".** If claims are unresolved, the top line says not-ready — don't bury it under a clean-looking draft.
