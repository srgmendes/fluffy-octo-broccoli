# SKILLS.md

Skills 0–6 (the numbered operating rules) are maintained outside this repository.
This file carries **Appendix A** only — the register of the imported skill
library, recorded here as received. Appendix A does not replace or amend Skills
0–6; where the two conflict, Skill 0 precedence governs and the conflict is
recorded in Part 3.

The 27 skills themselves are **not** vendored into this repo. Unlike the skills
under `.agents/skills/` (see `CLAUDE.md`), they are installed at the account
level from `claude-skills-all.zip`; this appendix is the registry of what was
installed and how it sits against Skills 0–6.

---

# APPENDIX A — IMPORTED SKILL LIBRARY

Imported 2 September 2026 from `claude-skills-all.zip` (27 skills, 199,727 bytes of SKILL.md content). This appendix registers what is installed and how each item sits against Skills 0–6. It does not replace or amend Skills 0–6. Where an imported skill contradicts a numbered skill, the numbered skill wins under Skill 0 precedence, and the conflict is recorded in Part 3 below.

Trigger text below is quoted or condensed from each skill's own frontmatter, not invented.

## Part 1 — Register

### Writing and editing

**humanizer** — rewrites, audits or drafts text so it reads as human-written; kills em dashes, AI-giveaway words, negative-parallelism reframes and formulaic structure. Triggers on /humanizer, /delete-ai-words, "de-AI this", "make this sound less like AI", "fix the AI writing", and proactively on anything sent under my name. Excludes code, legal contracts, academic citations, technical reference docs.

**personal-voice** — calibrates a voice profile from five real writing samples plus explicit rules on sentence length, rhythm, forbidden phrases and tone, then writes and verifies every draft against it. Two modes: one-time calibration, then application. Excludes imitating anyone other than me, and excludes house-style content such as legal filings.

**tighten** — cuts bloat from posts, emails, articles, scripts and landing pages while holding meaning and voice. Triggers on /tighten, "shorten this", "make it punchier", or a word or character limit.

**red-pen** — never returns a first draft; runs draft, harsh-reviewer attack, rewrite, repeat, until a full review pass finds zero flags, then returns the final plus a change log. Triggers on "run the loop", "make it bulletproof", "be brutal".

**ste** (folder `ste-100`) — writes or rewrites in ASD-STE100 Simplified Technical English. Explicit invocation only: "/ste" or "use the ste skill". Does not fire on "simplify this".

**i-have-adhd** — shapes every reply for an ADHD reader: detects task mode against talk mode, leads with the next action, numbered steps, time estimates, no filler openers or closers.

**go-deeper** — drills three "why" layers past the obvious first answer until a non-obvious insight appears. Triggers on /go-deeper, "this feels generic", "what am I missing", "give me a contrarian angle".

### Prompting and skill maintenance

**prompt-master** (folder `prompt-maker`) — restructures brain dumps, voice-dictated text and tangled multi-task messages into a clean task spec before executing. Excludes short clear requests and follow-ups.

**write-a-skill** (folder `skill-creator`) — turns a plain-language description of a wanted behaviour into an installable SKILL.md with a trigger-optimised description, explain-the-why instructions, output templates and anti-trigger calibration.

**skill-audit** — reviews installed skills for overlap, dead weight, vague triggers and gaps, then returns a keep/merge/fix/delete plan. Triggers on /skill-audit or after a batch install.

**grill-me** — interviews me with 10 to 15 questions before building anything, confirms a short spec, then builds. Excludes questions, explanations, debugging and small edits.

**how-to** — walks a stated goal to a finished result one step at a time, refusing to advance until the current step works. Built for non-technical beginners.

### Research and verification

**reddit-researcher** — 30-day deep research across Reddit, X, YouTube, LinkedIn, Hacker News, web and TechCrunch using Apify actors; deduplicates, scores relevance, detects cross-source signal, returns cited reports.

**deep-research-synthesizer** — synthesises large source sets, filters noise, evaluates source quality, returns cited actionable summaries.

**fact-checker** — extracts every factual claim in a draft, verifies each against primary sources by web search, returns a claim-by-claim verdict plus a corrected version. Fires proactively on anything containing statistics, dates, prices, quotes, names, titles, rankings or superlatives.

### Reasoning and decisions

**devils-advocate** — attacks a draft, argument, plan or idea with the strongest realistic counterarguments before the real audience does. Triggers on /devils-advocate, "poke holes in this", and on requests that read as fishing for validation.

**decide** — breaks a stuck decision into options, criteria drawn from my actual priorities, and a recommendation with reasoning. Triggers on /decide, "I'm torn", "I keep putting this off", or two or more options presented for a pick.

**handoff** — compresses the current conversation into a structured handoff document so a new session, a colleague or future-me can resume without losing decisions, constraints or progress. Summarises the conversation itself, not external documents.

### Marketing and social

**linkedin-hook** — generates the first two lines of a LinkedIn post.

**linkedin-post-report** — turns an Apify "LinkedIn profile posts" export (CSV or XLSX) into an analytics report plus a reusable SOP for the next post. Handles the Apify export's misleading columns. Produces two files.

**viral-recipe** — captures the recipe of one post that outperformed, then reproduces it for a new topic or person. Requires the reference post to be pasted into the skill.

**tc-social-carousel** — builds Instagram carousel slides for TC Social on a fixed six-template system, 1080x1350 artboards, warm neutral backgrounds, single burgundy accent, Bootzy display type.

**infographic-builder** — turns text into a single 1080x1350 PNG infographic for social feeds and reports. Excludes editable decks, dashboards and inline diagrams.

**deck-builder** — builds decks outline-first, then generates in Gamma. Fires on any mention of slides, a talk, a workshop, a keynote or a webinar.

### Commercial

**negotiation** — builds multi-expert negotiation strategy playbooks. Fires on deal prep, pricing strategy, scope discussions, contract terms, anchoring, objections, concessions and walk-away points.

**client-brief** — builds a pre-meeting brief on a prospect from connected tools, web research and pasted material. Triggers on /client-brief and "prep me for my call with X".

### Data

**xlsx** — any task where a spreadsheet is the primary input or output: read, edit, fix, create, convert, clean malformed tabular data. The deliverable must be a spreadsheet file.

## Part 2 — Folder name against invocation name

Three skills invoke under a name that differs from the folder they ship in. Install under the folder name and the trigger still keys off the frontmatter `name`, so the mismatch bites when I try to call them by folder.

- `prompt-maker/` installs a skill named **prompt-master**
- `skill-creator/` installs a skill named **write-a-skill**
- `ste-100/` installs a skill named **ste**

## Part 3 — Collisions with Skills 0–6

Recorded, not resolved. Skill 0 precedence governs: correctness-protecting rule, then more specific skill rule, then Skill 0, then request phrasing.

**Voice work triples up.** humanizer, personal-voice and tighten all overlap Skill 5 (Voice Pass). Skill 5 already fixes the register limits that matter to me: pleadings and affidavits keep formal register and untouched operative language, CVs and applications take the full pass, negotiation messages take the full pass plus stripped politeness. humanizer carries no such register carve-out beyond a blanket exclusion for legal contracts, and its "kill em dashes" rule contradicts Skill 5's "em-dashes sparingly". On any document going out under my name, Skill 5 governs and the imported three are subordinate.

**Adversarial review quadruples up.** red-pen, devils-advocate, go-deeper and skill-audit all overlap Skill 4 (LLM Council) and Skill 0 rules 4 and 5. Skill 0 rule 4 already states the structural limit: the author cannot be its own adversary, and in one session Claude is both. red-pen and devils-advocate are single-session self-critique, so neither satisfies the rule 4 requirement that filings, high-value negotiation and anything Dr Pretorius co-signs go through a genuinely different model. Treat them as pre-filters, never as the external pass.

**Question-asking skills collide with Absolute Mode.** grill-me, prompt-master, decide and how-to are built on asking me questions before producing anything. Absolute Mode bars questions, offers and suggestions. This is the same unresolved conflict already logged against Skill 0 rules 1 and 11 and the coding-ambiguity rule on 1 September 2026. Installing four more question-first skills widens the conflict rather than settling it.

**i-have-adhd fires on every reply.** Its description says "use whenever writing a reply to this person, for any topic", which puts it in direct competition with Absolute Mode and Skill 5 register limits on every single output. Install it only if I want it to win those collisions; otherwise leave it out.

**Two skills ship with unfilled placeholders and will misfire as installed.** negotiation contains "[ YOUR DEAL TYPE — e.g. consulting deals, agency contracts, SaaS enterprise sales, freelance projects ]", "[ YOUR NAME ]" and "[ BUYER ROLE ]". deck-builder contains "DO NOT fire on: [LIST CONTENT TYPES TO EXCLUDE]". viral-recipe requires the reference viral post pasted in before it does anything. Fill these before install.

**Four skills carry external dependencies.** reddit-researcher and linkedin-post-report need Apify actors and an Apify account. deck-builder needs Gamma. tc-social-carousel needs the Bootzy typeface and is built for a brand that is not mine.

**xlsx duplicates the public built-in skill of the same name.** Installing a second copy creates two skills with identical trigger text.

**fact-checker overlaps Skill 0 rule 2 and Skill 1 rule 2.** Its web-search-against-primary-sources method is the right instinct, but Skill 1 rule 2 already treats secondary web sources as suspect and requires statutory citations checked against the primary source. On legal work, Skill 1 governs; fact-checker is for content, not pleadings.

## Part 4 — Surviving risk

Six skills fire proactively on their own description: humanizer, personal-voice, fact-checker, i-have-adhd, grill-me and handoff. Proactive triggers are how a skill library starts overriding Skills 0–6 without anyone deciding that it should. Either narrow those six to explicit invocation, or accept that they outrank the numbered skills in practice whatever this appendix says.

None of the 27 SKILL.md bodies has been read in full. This appendix rests on frontmatter `name` and `description` fields only. The bodies may contain instructions that contradict Skills 0–6 in ways the descriptions do not reveal. [VERIFY] before install.
