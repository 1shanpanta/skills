---
name: anti-ai
description: Scan anything Ishan points at (a file, a folder, pasted text, a URL, a screenshot, a diff, a page, a doc, a README, a PR body, code comments, a design) for the signs of AI-made work, list each sign with the exact quote, ask whether to remove it, then remove it. Covers writing of every kind (text tells), web design (30 vibe-coded tells) and code (8-agent de-slop pass: duplication, weak types, dead code, circular imports, defensive code, legacy code, AI comments). Also load before writing or building anything, to avoid every tell up front. Flow is SCAN, ASK, FIX, RESCAN. Load when Ishan says "/anti-ai", "anti-AI", "does this look vibe-coded", "does this sound like AI", "is this AI generated", "what makes this AI", "humanize this", or sends a screenshot of text and asks if a person wrote it. Also covers marketing and product copy (16 copy rules): load for any ad, headline, hero, subhead, CTA, store listing, push notification, email subject, cold outreach, social post, product description or tagline, and when Ishan says "/copy-writing", "write copy", "write the ad", "punch this up" or "this sounds like a bot".
---

# Anti-AI

Find the signs of AI-made work in any target. Ask before each removal. Then remove.
The target can be any writing (post, DM, email, doc, README, PR body, ticket, commit message, code comment, copy) or any design (page, screen, screenshot, component file). The banned word list lives in "Copy rules", rule 16. Do not copy that list anywhere else.

## Flow: SCAN, ASK, FIX, RESCAN

1. **SCAN.** Read the whole target first. For a folder or a diff, read every file in it. Pick the tell lists that apply: "The tells" for writing, "Design tells" for UI, both for a page with copy. For ads, headlines, store listings, emails and other customer-facing words, also use "Copy rules" (all 16 rules plus the delivery checklist). For a codebase or a diff, use "Code tells" (the de-slop pass).
2. **ASK.** Print one numbered list of findings. Each finding has three parts: the exact quote or element, the tell name, and the proposed fix (delete, replace with X, or "needs a fact from you"). End with one question: "Remove all, or pick numbers?" Do not edit before the answer.
3. **FIX.** Apply only the approved findings. Use Edit or Write so the diff shows. Change nothing else in the target: no extra polish, no restyle. A fix that needs a fact only the author knows becomes a question to the author. Never invent the fact.
4. **RESCAN.** Read the target again. Report what remains and what the author declined. Stop when no approved finding remains.

Verdict line for pasted text or a screenshot: likely AI, likely human, or unsure. No single tell proves anything. A verdict needs three or more.

Before building, use the lists the other way: write the draft, run SCAN on it, and fix every finding before showing the draft.

## Mode 1: DETECT (text only, no edits)

1. Quote each suspect phrase exactly.
2. Name the tell next to the quote.
3. Give a verdict.
4. Use this mode alone when the target is not editable (a tweet by someone else, a screenshot of text).

## The tells

Ordered by how strongly each one signals AI.

1. **Slogan closer.** The last sentence restates the point as a quotable line. Shape: "X is a different Y than Z."
2. **Aphorism opener.** A bold claim with no setup. A term appears that the text never defines.
3. **Claim, evidence, moral.** Three tidy beats. Each sentence works as a standalone quote.
4. **No specifics.** No name, number, date, tool or story. Every noun is generic ("hours", "the work", "the benchmark").
5. **Pre-answered objection.** A balanced concession clause, such as "even when it loses X".
6. **Stock phrases.** Fluent, common, low-risk wording: "without babysitting", "ends up doing most of the work".
7. **Even rhythm.** Every sentence has about the same length. No fragment, no run-on.
8. **Flawless polish.** No typo, no contraction, no slang, in a casual setting where people type fast.
9. **Contrast frame.** "Not X, but Y", "less about X, more about Y".
10. **Rule of three** where the third item adds nothing.
11. **Em dash or en dash.**
12. **Fits anyone.** Replace the subject with a rival or another topic. If the text still reads fine, it has no content of its own.

## Mode 2: REWRITE (text fixes, used by FIX)

Apply the approved fixes in this order:

1. Add one fact only the author knows: a name, a number, or what happened.
2. Delete the slogan closer. End on the last fact.
3. Delete the pre-answered objection.
4. Replace each stock phrase with the plain thing that happened.
5. Break the rhythm. Allow one fragment and one long sentence.
6. Remove every dash and contrast frame.

Never invent the fact in step 1. Ask the author for it. A made-up detail is a false claim.

## Worked example

Text: "The home is usually the boring one. Whichever model I can leave running for hours without babysitting ends up doing most of the work, even when it loses the benchmark. A long unattended run is a different test than a scored task."

Tells found: 1, 2, 3, 4, 5, 6, 7, 8. Verdict: likely AI. The author confirmed it in the replies.

Likely human version needs a fact, for example: "I run [model] overnight on [task]. It finished [N] of [M] by morning. [Other model] scores higher and I stopped using it."

## Design tells (vibe-coded UI)

Source: a reel by nataindata, "how do I see your design was vibe-coded". Use this list in two ways:

- BUILD: before a web page or UI, check the plan against every item. Do not ship an item by default. Keep one only with a stated reason.
- DETECT: audit a page or screenshot. Quote the element, name the item number, give one fix.

Three or more items on one page is a likely vibe-coded page. One item alone proves nothing.

**Color and surface**

1. harsh gradients
3. pure white background
4. rainbow coloring
5. drop shadows
8. liquid glass
19. soft corner radius
20. purple and black
29. neon colors
30. basic pastel colors

**Type and icons**

2. lucide icons
7. emojis
9. em dashes
10. inter / geist / space grotesk
24. sparkle icons
25. animated arrows
16. checkmark bullets

**Layout and decoration**

6. 3 feature cards in a row
11. colored left stripe
13. bento grids
14. terminal window
17. 3 pricing tiers
22. radial orbs
23. dot grids
28. hover animations

**Content and trust**

12. fake testimonials
15. "it's not x, it's y"
18. no real product demos
21. no skeleton loaders
26. no TOS
27. no privacy policy

Fix rule: replace each item with something only this product has. Examples: a real screenshot of the product, a real number, a real customer quote, a loading state that matches the layout, a TOS and privacy page that exist.

Conflict to resolve per project: Lucide is the default icon set in `~/.claude/CLAUDE.md`, but item 2 lists it as a tell. Use Lucide only where a custom or product-specific icon is not worth the cost, and never in the 3-card feature row (item 6).

## Copy rules (marketing and product copy)

Every line of customer-facing copy passes all sixteen rules before it ships. These rules govern the words, not the code, and not chat replies to Ishan (caveman governs those).

1. **Sell the end state.** Write the reader's life after the product works, not the product. "Your dog walks 3km before you finish coffee" beats "GPS walk tracking with route history". The feature is the receipt, the end state is the sale.
2. **Pass the stranger test.** Give the line to somebody who has never heard of the product. If they cannot say what it does and who it is for, the line failed. No inside vocabulary, no acronym the reader must already know, no reference to a screen they have not seen.
3. **Cut, then cut again.** Write it, halve it, halve what survives. Every word left must be load-bearing. If deleting a word does not change the meaning, the word was decoration.
4. **Select your reader.** Good copy repels the wrong reader on purpose. Name the person, the situation or the constraint so the right reader feels seen and everybody else moves on. Copy written for everyone converts no one.
5. **No em dashes, no en dashes.** Anywhere. Use commas, periods, parentheses, colons, hyphens.
6. **Tone matches slot.** A push notification, a hero headline, an App Store subtitle and a cold email are four registers with four lengths. Write for the slot, including its character limit, not for a generic "brand voice".
7. **Kill empty hedges.** Delete "helps you", "designed to", "can assist with", "aims to", "seamlessly", "effortlessly", "simply". They exist to avoid a claim. Make the claim or cut the line.
8. **Angles, not synonyms.** When asked for variants, change the argument, not the wording. Five lines with different adjectives are one line. Vary the angle: fear, status, time saved, money, identity, the objection, the specific moment of use.
9. **One idea each.** One line carries one idea. Two ideas in a headline means neither lands. Split them, or drop the weaker one.
10. **Never invent claims.** No number, percentage, award, user count, testimonial, integration or capability that was not given. Ask for the fact or write around it.
11. **Truth beats style.** When a clever line needs a small distortion to work, kill the line. Accuracy is the constraint, wit is the optimization inside it.
12. **Benefit, not mechanism.** "Notes are there on your phone before you sit down" beats "real-time sync over WebSocket". Put the mechanism in the body only as proof for a benefit already stated.
13. **Numbers beat adjectives.** "Fast" is an opinion, "opens in 200ms" is a fact. Replace "powerful", "robust", "advanced" and "significant" with the real number when there is one. No real number means cut the adjective, never invent the number.
14. **Front-load the point.** The first three words carry the message. No throat-clearing opener, no scene-setting clause, no "In today's world".
15. **Sound unmistakably brand.** The line must be impossible to paste into a competitor's page unchanged. If the copy still works with a rival's logo on it, it says nothing and the work is not done.
16. **No AI lexicon.** Banned outright: delve, elevate, unlock, unleash, seamless, robust, leverage, harness, empower, transform, revolutionize, game-changer, cutting-edge, "in today's fast-paced world", "it's not just X, it's Y", "the result?", "imagine a world where", "dive in", supercharge, tailored, curated, holistic, journey, landscape, realm, testament, "navigate the complexities". Also banned: a rule-of-three list where the third item adds nothing, and a one-word sentence used as a drum beat.

Structural tells to avoid in copy:

- Every sentence the same length.
- A colon in the middle of every headline.
- Perfect parallel structure across all bullets.
- A closing line that summarizes what the reader just read.
- A rhetorical question used as a transition.
- A bolded first phrase on every bullet, in body copy that is not a spec sheet.

Working method:

1. Get the facts first: who the reader is, what changes for them, what is provably true. Ask for missing facts (rule 10).
2. Write more variants than asked for, each a different angle (rule 8).
3. Run the checklist on each survivor.
4. Deliver a shortlist plus one line on the angle each plays. Never one option, never twenty.

Checklist before delivery:

- [ ] End state visible, not just the feature
- [ ] A stranger understands it cold
- [ ] Cut twice, every word load-bearing
- [ ] A specific reader is selected
- [ ] Zero em dashes or en dashes
- [ ] Length and register fit the actual slot
- [ ] No hedge verbs
- [ ] Variants differ by angle, not vocabulary
- [ ] One idea per line
- [ ] Every claim traceable to a supplied fact
- [ ] No accuracy traded for wit
- [ ] Benefit leads, mechanism supports
- [ ] Adjectives replaced with numbers where numbers exist
- [ ] First three words carry the point
- [ ] Fails the competitor swap test
- [ ] Zero words from the banned list

## Code tells (de-slop pass)

Use this section when the target is a codebase or a diff. Run 8 subagents in parallel, one worktree each, on Sonnet. Install dependencies first (`npm install` or equivalent): knip, madge and tsc must run.

Gate: in SCAN, each agent only reports. It changes nothing. After the author approves in ASK, each agent applies its approved findings, runs the type checker and the tests, and commits atomically with the prefix shown. After all agents finish, review the changes and resolve conflicts in favor of the more specific change. Then re-run the type checker.

1. **DRY.** Find duplicated logic and copy-pasted blocks. Consolidate only where it reduces complexity: more than 10 lines, used 3 or more times, or likely to diverge. Three similar lines are fine. Update all call sites. Commit `[refactor] consolidate duplicated {description}`.
2. **Type consolidation.** Find every `type`, `interface` and `enum`. Merge duplicates and near-duplicates into one canonical location that follows project conventions. Update all imports. Commit `[refactor] consolidate {type name} definitions`.
3. **Dead code (knip).** Run `npx knip`. Collect unused exports, files and dependencies. Grep for references to verify each finding, because knip gives false positives with dynamic imports, barrel files and test utilities. Remove only confirmed dead code. Commit `[remove] dead code identified by knip`.
4. **Circular dependencies (madge).** Run `npx madge --circular --extensions ts,js src/`. Map each cycle. Break it with a shared types file, dependency inversion or new module boundaries. Re-run madge to confirm zero cycles. Commit `[refactor] break circular dependency between {modules}`.
5. **Strong typing.** Find `any`, `unknown`, `as any`, `as unknown`, `// @ts-ignore`, `// @ts-expect-error` and `// eslint-disable.*no-explicit-any`. Find the correct type from downstream use, library type definitions and docs. Replace the weak type. Remove each ignore comment that is no longer needed. Run `npx tsc --noEmit` and require zero errors. Commit `[fix] replace weak types with strong types in {area}`.
6. **Defensive code.** Find `try/catch`, `.catch()`, `|| fallback` and `?? fallback`. Keep a handler for genuinely external input (user input, API responses, file I/O). Remove a catch around internal code that should not throw. Remove an empty catch and a log-and-continue catch, or replace it with error propagation. Remove a fallback that hides a bug, such as `|| []` where an empty array means something broke. Commit `[refactor] remove unnecessary defensive programming in {area}`.
7. **Legacy and fallback code.** Find `@deprecated`, `TODO`, `FIXME`, `HACK`, `legacy`, `old`, `fallback`, `backwards`, `compat`, `temporary`, `workaround`, feature flags and environment switches. Check that the new path exists before removing the old one. Remove a shim whose old target is gone. Remove a flag for a shipped feature and keep the feature code. Leave one way to do each thing. Commit `[remove] legacy/fallback code in {area}`.
8. **AI slop and comments.** Find comments that restate the code (`// increment counter`), stubs (`// TODO: implement`, `throw new Error('Not implemented')`, `pass`), transition comments (`// replaced old X with new Y`, `// previously this was...`), section dividers (`// ========`), comments on every line, debug `console.log` or print calls, and commented-out code. Delete all of them. Keep a comment that explains an important WHY, and make it short. For a stub, implement it or delete the function. Commit `[remove] AI slop and unnecessary comments in {area}`.

Report after all agents finish:

```
ANTI-AI CODE REPORT: {project name}

1 DRY:              {X duplications consolidated}
2 Types:            {X types consolidated}
3 Dead code:        {X files, Y exports, Z deps removed}
4 Circular deps:    {X cycles broken}
5 Strong types:     {X weak types replaced}
6 Defensive code:   {X unnecessary try/catch removed}
7 Legacy code:      {X legacy paths removed}
8 AI slop:          {X comments/stubs removed}

Total files changed: X
Type check: PASS/FAIL
Tests: PASS/FAIL
```

## Limits

- Detection by reading is a guess. Say so in the verdict.
- Do not use this skill to pass AI text as human text in a setting that forbids it, such as an exam or a disclosure rule.
