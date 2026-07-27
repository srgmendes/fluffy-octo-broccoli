---
name: humanizer
description: Rewrites text so it reads like a person wrote it, not an AI. Use when the user says "/humanizer", asks to "humanize this", "remove the AI tells", "get rid of the em-dashes", or wants a draft to sound less generated and more natural. Applies to any prose the user is about to publish or send.
---

# Humanizer

Take text that reads as AI-generated and make it read as human-written — without changing what it says. This is a copy-editing pass, not a rewrite of the argument.

## When to Use This Skill

- The user types `/humanizer`, or asks to "humanize", "de-AI", or "make this sound human".
- A draft has the tells: em-dash overuse, hedge-heavy phrasing, tidy tricolons, a "In today's world…" opener, a "Let's dive in" energy.
- The user is about to publish or send something and wants it to not read as generated.

## The AI Tells to Strip

Work through these. Not every one appears in every draft — fix what's there.

**Punctuation**
- **Em-dashes.** The biggest tell. Replace with a period, comma, colon, or parentheses — whichever the sentence actually needs. Don't just swap one dash for another; recast the sentence.
- Overused semicolons where a full stop is cleaner.

**Words & phrases that scream AI**
- "delve", "dive in", "unpack", "navigate", "leverage", "harness", "elevate", "robust", "seamless", "streamline", "tapestry", "landscape", "realm", "testament", "underscore", "boasts".
- "It's important to note that", "It's worth noting", "That said", "In conclusion", "Ultimately".
- "not only… but also", "whether you're X or Y".
- "In today's fast-paced world", "In the ever-evolving landscape of".

**Structure & rhythm**
- **Tricolons on autopilot** — the reflexive "X, Y, and Z" list of three. Break the pattern; use two, or four, or a single strong noun.
- **Uniform sentence length.** Humans vary it. Add a short one. Then a longer one that carries a real thought. Let it breathe.
- **Symmetrical paragraphs** all the same size — vary them.
- Hedging stacked on hedging ("might potentially perhaps"). Pick one or cut it.

**Tone**
- Empty enthusiasm ("Great question!", "Absolutely!"). Cut.
- Over-explaining the obvious. Trust the reader.
- Perfectly balanced "on one hand / on the other" when the writer actually has a view. Let the view show.

## The Rules

1. **Preserve meaning.** Don't add claims, drop caveats that matter, or shift the argument. If removing a hedge changes the truth of a sentence, keep the hedge.
2. **Preserve the user's voice.** If an `about-me` profile exists, honor it — humanizing means sounding like *the user*, not like a generic "casual" register. A formal writer stays formal; you're removing machine tells, not adding slang.
3. **Don't overcorrect into a new tell.** Stripping every em-dash and adding ten sentence fragments is just a different robot. Aim for natural, not performatively casual.
4. **Light touch on good writing.** If a sentence already reads human, leave it. Don't edit for the sake of editing.

## Output

Return the rewritten text. If the user wants to see what changed, offer a short bulleted list of the categories you fixed (e.g. "removed 6 em-dashes, cut 'leverage' and 'seamless', varied sentence length in ¶2") rather than a full diff — but lead with the clean version.
