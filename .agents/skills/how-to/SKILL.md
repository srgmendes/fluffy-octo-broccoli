---
name: how-to
description: A universal planning guide for any task. Use when the user says "/how-to", asks "how do I do X", "help me plan X", "where do I start with X", or hands over a vague or open-ended goal that needs to be turned into a concrete plan before any work begins. Replaces one-off "how do I..." prompts by asking the right questions first, then producing a step-by-step plan.
---

# How-To

Turn a vague ask into a concrete plan. The user brings a goal — sometimes one word, sometimes a paragraph. Your job is to close the gaps with a few sharp questions, then hand back a plan they can act on.

## When to Use This Skill

- The user types `/how-to` followed by anything (or nothing).
- They ask "how do I…", "where do I start with…", "help me plan…".
- The goal is real but underspecified — you'd have to guess at scope, audience, tools, or the definition of "done."

Do **not** use this for tasks that are already fully specified and ready to execute — just do those.

## The Method

### 1. Restate the goal in one sentence

Reflect back what you heard, so a wrong assumption surfaces immediately. If the user gave you a single word ("newsletter", "migration", "onboarding"), name the most likely intent and let them correct it.

### 2. Ask only the questions that change the plan

Never interrogate. Ask the smallest set of questions whose answers would actually branch your approach. Good candidates:

- **Outcome** — what does "done" look like, concretely? What will exist that doesn't now?
- **Audience / consumer** — who is this for, and what do they already know?
- **Constraints** — deadline, budget, tools they must (or can't) use, existing conventions.
- **Starting point** — what already exists that we build on or replace?
- **Scope boundary** — what's explicitly *out* of scope for this pass?

Prefer 2–4 questions. If a sensible default exists, state the default instead of asking — "I'll assume X unless you say otherwise."

Use the `AskUserQuestion` tool when the choices are discrete and you want fast answers; use plain prose when the answer is open-ended.

### 3. Produce the plan

Once you have enough to be concrete, write a plan with:

- **Phases or steps**, ordered, each a verb the user (or you) can start now.
- **The first action** called out — the single thing to do next.
- **Decision points** flagged where a later step depends on an earlier result.
- **What you'll need from them** at each hand-off.

Keep it tight. A plan the user can hold in their head beats an exhaustive checklist they'll skim.

### 4. Offer to run it

End by offering to execute the first step (or the whole plan) directly, if it's something you can do. The plan isn't the deliverable — the outcome is.

## Style

- One clarifying round is usually enough. Don't stack questions across multiple turns if you can ask them together.
- Recommend, don't just enumerate. If you'd pick option B, say so and why.
- Vagueness shouldn't survive contact with this skill — but neither should the user's patience. Move fast to the plan.
