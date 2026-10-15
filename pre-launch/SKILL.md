---
name: pre-launch
description: Audit an app against a full pre-launch checklist before it touches a paying customer. Covers auth, data, security, compliance, infra, observability, testing, billing, API, AI features, UX, code health and the people the app still needs. Reports each item as PASS, FAIL, UNKNOWN or N/A with evidence from the repo. Use when Ishan says "/pre-launch", "is this ready to launch", "launch checklist", "production readiness", "before we ship to customers", "vibe-coded app audit", or asks what is missing before real users.
---

# pre-launch

A vibe-coded app works on a laptop. A paying customer needs the items in
`checklist.md`. This skill checks the repo against each item and reports the gaps.

## Procedure

1. Read `checklist.md` in this folder. It has 17 sections and 154 items.
2. Scope first. Ask Ishan on a page (`~/.claude/scripts/ask-ishan.py`) only for facts the repo cannot show:
   - Who is the first paying customer, and is it enterprise?
   - Does the app hold patient data, card data or EU personal data?
   - Does the app use an AI model?
   - Does the app take payments?
3. Mark whole sections N/A from the answers. Examples: no payments, skip section 12. No AI model, skip section 14. Say which sections are skipped.
4. Check each remaining item against the repo. Use `grep`, read config, read migrations, run the tests and the build. Never mark PASS from a guess.
5. Give each item one status:
   - `PASS`: evidence found. Quote the file and line.
   - `FAIL`: the repo shows the item is missing or wrong.
   - `UNKNOWN`: the repo cannot show it (a restore test, an on-call rota, a vendor BAA). Ishan must confirm.
   - `N/A`: the scope answers make the item irrelevant.
6. Rank the FAIL items by blast radius:
   - `BLOCKER`: data leak, account takeover, lost money, lost data. Launch stops until fixed.
   - `HIGH`: outage or enterprise deal loss.
   - `LATER`: quality and speed.
7. Report as an HTML page in `~/Desktop/html-docs/YYYY-MM-DD-pre-launch-<project>.html`. Open it with `open -a Comet`. Put the blockers first, one card per section, evidence inside `<details>`. Keep the chat reply to the verdict and the link.

## Rules

- Never print a secret, token, participant name or health reading in the report. Name the file and line only.
- A found secret in the repo is a BLOCKER. Say "rotate it" in the report. Never print the value.
- Do not fix items during the audit. Report first. Fix only what Ishan picks.
- An item that only a human can do (pen test, SOC 2 auditor, on-call rota) stays `UNKNOWN` with the name of the role from section 17.
- List the skipped sections and every `UNKNOWN` at the end. Never bury them as done.
- Do not invent a compliance claim. HIPAA, SOC 2, PCI and GDPR items need a named evidence document, not a code comment.
