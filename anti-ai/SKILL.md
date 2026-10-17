---
name: anti-ai
description: Scan anything Ishan points at (a file, a folder, pasted text, a URL, a screenshot, a diff, a page, a doc, a README, a PR body, code comments, a design) for the signs of AI-made work, list each sign with the exact quote, ask whether to remove it, then remove it. Covers writing of every kind (text tells) and web design (30 vibe-coded tells). Also load before writing or building anything, to avoid every tell up front. Flow is SCAN, ASK, FIX, RESCAN. Load when Ishan says "/anti-ai", "anti-AI", "does this look vibe-coded", "does this sound like AI", "is this AI generated", "what makes this AI", "humanize this", or sends a screenshot of text and asks if a person wrote it. For marketing copy, load copy-writing as well.
---

# Anti-AI

Find the signs of AI-made work in any target. Ask before each removal. Then remove.
The target can be any writing (post, DM, email, doc, README, PR body, ticket, commit message, code comment, copy) or any design (page, screen, screenshot, component file). The banned word list lives in `copy-writing` (rule 16). Do not copy that list here.

## Flow: SCAN, ASK, FIX, RESCAN

1. **SCAN.** Read the whole target first. For a folder or a diff, read every file in it. Pick the tell lists that apply: "The tells" for writing, "Design tells" for UI, both for a page with copy.
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

## Limits

- Detection by reading is a guess. Say so in the verdict.
- Do not use this skill to pass AI text as human text in a setting that forbids it, such as an exam or a disclosure rule.
