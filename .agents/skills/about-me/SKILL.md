---
name: about-me
description: Captures who the user is, how they think, and how they write, so responses match their voice and context. Use when the user says "/about-me", asks to set up or update their profile, wants Claude to "sound like me" or "know my context", or asks to turn an existing about-me / bio / style doc into a reusable profile. Once built, apply it whenever drafting or deciding on the user's behalf.
---

# About Me

A durable profile of the user — their role, how they think, and how they write — so drafting and decisions default to *their* voice and context instead of a generic one.

## When to Use This Skill

- The user types `/about-me`, or asks to create/update their profile.
- They say things like "make it sound like me", "you should know my background", "remember how I write".
- They hand over an existing bio, résumé, style guide, or a folder of their past writing and ask to turn it into a profile.
- **Applying it:** once a profile exists (`profile.md` in this skill's folder), read it and honor it whenever you draft prose, make a judgment call, or choose a default *on the user's behalf*.

## Building the Profile

There are two paths. Offer both.

### Path A — Import what already exists

If the user has an about-me doc, bio, résumé, LinkedIn text, or a sample of their writing, ask for it and extract the profile from it. This is the fast path — don't make them answer questions they've already answered in prose. Confirm the extracted profile back to them before saving.

### Path B — The interview

If they're starting fresh, interview them. Don't fire all questions at once — work through the sections below conversationally, and let them skip anything. Dictation is fine and often more honest than typing; tell them they can ramble and you'll structure it.

Cover:

1. **Identity & role** — what they do, for whom, at what kind of org. Seniority, domain, the hats they wear.
2. **How they think** — how they make decisions (data-first? gut? consensus?), what they optimize for, what they have no patience for.
3. **How they write** — tone (warm/direct/formal), sentence length, do they use humor, emoji, jargon? Show, don't just tell: ask for one thing they wrote and liked.
4. **Audiences** — the different people they write to (team, execs, customers, public) and how their register shifts for each.
5. **Hard preferences & red lines** — words they never use, formats they hate (no walls of text? no corporate speak?), things that must always be true.
6. **Context that recurs** — their team, current projects, ongoing themes that come up often enough to be worth remembering.

Keep it lightweight. A good profile is a page, not a dossier — enough to shift defaults, not so much it becomes a straitjacket.

## Saving the Profile

Write the result to `profile.md` alongside this `SKILL.md`. Structure it under clear headings (Identity, Thinking, Voice, Audiences, Red lines, Recurring context) so it's easy to scan and to edit later. Show the user the final file and confirm it's right.

## Applying the Profile

When this skill is active and a `profile.md` exists:

- **Match the voice**, don't caricature it. Capture their register; don't parody their tics.
- **Adapt to audience.** If the profile notes a different tone for execs vs. team, pick the one that fits the task.
- **Honor red lines absolutely.** Never-use words and hated formats are non-negotiable.
- **Stay a default, not a cage.** If the user asks for something off-profile in the moment, the in-the-moment request wins.

## Keeping It Current

Profiles drift. When the user corrects your voice or mentions a new project/role, offer to fold it into `profile.md` so the change sticks.
