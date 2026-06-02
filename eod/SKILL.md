---
name: eod
description: End-of-day engineering-learning harvest. Mines the day's Claude Code session transcripts for a repo and reports the TRANSFERABLE knowledge the user gained that day - portable principles, tools/commands/flags learned, traps to avoid, reusable domain facts - phrased so they help on a different project. Customizable per run via a focus lens (engineering, process/workflow, domain, product/judgment, or everything), passed as an arg or chosen interactively. Repo-scoped, reading every session that touched the repo that day, not just the current terminal. Output is printed in the terminal as numbered points with short explanations and writes no files. Trigger when the user types /eod or says "what did I learn today", "what did we learn", "what valuable knowledge did I gain", "end of day review", "eod", or asks for the engineering lessons / career-useful takeaways from a day's work in a repo.
---

# /eod - End-of-day learning harvest

Tell the user, as an engineer, the **transferable knowledge they gained today** working in this repo. The goal is career-useful learning they can carry to any project, not a status report of what shipped.

## This is NOT a status recap
Do not output "what got done today" or a list of features/commits. That is `/tldr`, `/retro`, `/handoff`. This skill answers a different question: *"As an engineer, what did I learn that makes me better on the next project?"* If a point only matters inside this one repo, it does not belong in the output. Rewrite it into its portable form, or drop it. (The most common failure here is drifting into project facts; guard against it hard.)

## Step 0: Pick the focus lens (customizable - do this first)
The user decides what KIND of knowledge to surface. Settle the lens before anything else.

1. **If the user passed a focus phrase as an arg, use it verbatim as the lens.** It can be a named lens below or anything free-form: "just my mistakes", "frontend craft", "what tooling did I pick up", "caching", "only the gnarly debugging". Anything in the args that is not a date/range word is the focus phrase.
2. **If no focus was given, ask with AskUserQuestion** (multiSelect: true) which lens(es) they want. Offer these, Engineering first as the default:
   - **Engineering (technical)** - architecture, code patterns, systems design, debugging, tools/commands. The literal-engineering default.
   - **Process & workflow** - git, deploy/CI, how-I-work efficiency, collaboration, what to check first next time.
   - **Domain knowledge** - reusable facts about the problem domain worked in (SEO, payments, auth, caching, browsers, etc.).
   - **Product & judgment** - scoping, prioritization, decision-making, user-value and tradeoff calls.
   The user can always type their own answer; treat "everything", an all-options selection, or a free-form answer as the lens. Default to Everything only if they explicitly pick it.
3. **The chosen lens reshapes the whole run:** the distillation prioritizes it, the output leads with it, and points outside the lens are dropped unless the lens is Everything. The Lesson Test (section 4) still applies inside the lens - keep only transferable knowledge, never project facts.

## 1. Resolve scope (repo-scoped by default)
- Target repo = current working directory unless the user passes a path as an arg.
- Target date = today unless the user passes a date or range (e.g. `/eod 2026-06-01`, `/eod week`).
- Args may combine a date/range and a focus phrase (e.g. `/eod week frontend`). Split them: date/range words set the scope, the remainder is the focus lens for Step 0.
- **Read every session that touched the repo that day, not just the current terminal's session.** The user may run this from an idle terminal while the real work happened in another window; it must still find it. Never privilege the invoking session.

Map the repo path to its transcript folder:
- slug = the absolute repo path with every `/` and `.` replaced by `-`.
  Example: `/Users/ishan/Desktop/Code/DnS/web.d8s.co.jp` -> `-Users-ishan-Desktop-Code-DnS-web-d8s-co-jp`
- Compute it: `slug=$(echo "$PWD" | sed 's#[/.]#-#g')`
- Transcripts live in `~/.claude/projects/<slug>/*.jsonl`.
- Fallback if that folder is missing: `ls ~/.claude/projects/ | grep -i <repo-basename>` and pick the match.

Find the day's transcripts:
- Default (today / this evening): `find ~/.claude/projects/<slug> -maxdepth 1 -name '*.jsonl' -mtime -1` (sessions active in the last 24h). Also `ls -lat` the folder to eyeball which sessions are in range.
- For a specific past date or range: list all `*.jsonl` and have the digest step (3a) keep only lines whose `.timestamp` starts with the target date (add `select((.timestamp//"")|startswith("<date>"))` to the jq). Avoid fragile shell date math.

## 2. Gather sources
Primary source: the session transcripts above. The richest learnings (dead ends, "oh, the CDN overrode it" moments, debugging detours, wrong turns) live in the conversation, NOT in commits. Some of the best learning days produce zero commits.

Corroborate with:
- `git -C <repo> log --since="<date> 00:00" --oneline` and the working diff, to ground the narrative and catch work you might not remember.
- If invoked from the session that did the work, you already have it in your live context, so use that too; the active transcript on disk may be missing the latest turns.

## 3. Distill (cheap: pre-filter to a digest, then a small model reads it)
NEVER feed a raw `.jsonl` to a model. A transcript is 80%+ tool-result blobs (file contents, greps, build output, base64) with near-zero learning signal; raw, a heavy day is 1M+ tokens. Pre-filter first, then read the digest on a cheap model. Opus only does the final merge.

**3a. Build a compact digest per transcript (no model, pure shell).** For each transcript file `$F`, run this jq pass. It keeps only the human turns, the assistant's prose, and tool-call headlines, dropping tool outputs and thinking. It compresses roughly 45x (a 2.3MB transcript becomes ~50KB):

```bash
DIGEST="${TMPDIR:-/tmp}/eod-$(basename "$F" .jsonl).txt"
jq -rc '
  if .type=="user" and (.isMeta|not) then
    (.message.content |
      if type=="string" then ("USER: " + (gsub("\n";" ")|.[:600]))
      else (.[]? | select(.type=="text") | "USER: " + (.text|gsub("\n";" ")|.[:600])) end)
  elif .type=="assistant" then
    (.message.content[]? |
      if .type=="text" then ("ASSISTANT: " + (.text|gsub("\n";" ")|.[:800]))
      elif .type=="tool_use" then ("TOOL " + .name + ": " + ((.input|tostring)|gsub("\n";" ")|.[:200]))
      else empty end)
  else empty end
' "$F" > "$DIGEST"
```
(For a specific date, insert `select((.timestamp//"")|startswith("<date>")) |` right after the first `'` to keep only that day's lines.)

**3b. Distill the digest(s) on a CHEAP model.** Reading is grunt work; do not spend Opus on it. Spawn the distillation subagent(s) with `model: 'haiku'` (fall back to `'sonnet'` only if Haiku misses nuance). Digests are tiny, so prefer ONE cheap subagent over all of today's digests; fan out per-digest only if the combined size is large (> ~150KB) or the range is a full week. Brief:

> Read the digest file(s) at `<paths>`. Each is a pre-filtered session: lines tagged `USER:` (the human's turns), `ASSISTANT:` (my prose), and `TOOL <name>:` (tool-call headlines). Focus lens: `<lens>` - surface knowledge of that kind first and drop points outside it (skip the filter only if the lens is Everything). Extract the TRANSFERABLE knowledge the human gained: portable principles, tools/commands/flags learned, traps and wrong assumptions, genuinely reusable domain facts. For each, give a one-line lesson plus a few words on where it came from. Apply the Lesson Test: a point qualifies only if it would help on a DIFFERENT project. Discard project-specific facts unless you can rewrite them into a portable principle. Return a compact bulleted list grouped by: Principles, Tools & techniques, Traps & time-sinks, Domain notes. No project status, no feature recaps.

**3c. Merge on the main model.** You (Opus) take the cheap model's compact output, dedupe near-identical points, apply the altitude rubric (section 4), and write the final answer. You never read the raw transcripts yourself. Delete the temp digests when done.

## 4. The Lesson Test (altitude rubric - the whole point)
A candidate is a real learning only if it transfers to a different project, team, or stack. Rewrite every project-specific observation into its portable form. If it can't be rewritten that way, cut it.

| Project fact (cut or rewrite) | Transferable lesson (keep) |
|---|---|
| "og-image.png 404s on the site" | (cut - no transfer value) |
| "Cloudflare serves a managed robots.txt over the repo's" | "A CDN/edge proxy can shadow committed config files; when a config 'isn't working', check whether something upstream serves its own version." |
| "the fixes branch was 4 commits ahead of main" | "Merged and deployed are different states; confirm which branch the deploy pipeline actually tracks before trusting that work is live." |
| "news/team are SPA fragments" | "Client-side view swaps have no URL, so crawlers and per-page metadata can't see them; anything that must be addressable needs a real route." |

## 5. What to keep, by category
If a focus lens is set, lead with the categories that match it and demote or drop the rest. These are the raw buckets:
- **Principles** - portable mental models and heuristics (the gold).
- **Tools & techniques** - specific commands, flags, libraries learned today (e.g. `curl --resolve host:443:IP`, `git rev-list --left-right --count a...b`). Immediately reusable.
- **Traps & time-sinks** - wrong assumptions made, what cost time, what to check first next time.
- **Domain notes** - reusable facts about a domain (SEO, deploy, auth, caching, etc.) that recur beyond this repo.

## 6. Quality bar
- Quality over volume. A real day yields maybe 5-12 genuine lessons, not 30. Do not pad.
- Cut platitudes ("testing matters") and anything the user obviously already knew.
- If a lesson looks like review / interview / brag-doc material, flag it in one phrase. Recurring lessons reveal real skill gaps or strengths worth naming.
- If a day genuinely produced little learning (routine, mechanical work), say so honestly. Do not manufacture insight.

## 7. Output (terminal only - write no files)
Print directly in the terminal. No journal file, no memory writes, no external posts. Do not offer to save anywhere unless the user asks afterward. Format:
- A one-line header: date, repo, the focus lens, and a 3-5 word theme of the day.
- Numbered points. Each point = a **bold one-line lesson** followed by 1-2 sentences of plain explanation. Tone: a sharp senior engineer debriefing a peer.
- Group under the category headings from section 5 only if there are enough points to warrant it.
- End with one compression line: "If you remember one thing: ..."
- No em-dashes anywhere in the output.

## Edge cases
- No transcripts for the date: say so, list which dates/sessions ARE available for that repo, and offer to run against the nearest one.
- Multiple repos worked that day: this skill is single-repo; mention the others exist and that the user can `cd` there and rerun.
- `/eod week` or a date range: aggregate across days, then add a short closing section surfacing lessons that recurred across the range (those are the highest-signal ones).
