---
name: atomic-plan
description: Break a complex multi-step plan into the smallest atomic steps, render as a visual HTML artifact, then execute one step at a time with explicit user approval before AND after each step. Each atomic step is self-contained (its description, files, and verify check do not reference other steps) and has a single owner, a single verifiable outcome, and commit-sized scope. Decisions surface inline at the step that depends on them, never bundled upfront. Use when the user says "atomic plan", "/atomic-plan", "atomic-plan this", "break this into atomic steps", "smallest atomic pieces", "ask before each step", "ask question before each atomic step", "step-by-step with check-ins", or "let's do this slowly with check-ins". Different from /autoplan (parallel reviews) and /plan-eng-review (plan critique): atomic-plan executes an existing plan slowly with max oversight.
---

# atomic-plan

## What this skill does

Takes a complex plan (markdown doc, HTML plan, ClickUp ticket, or described in conversation) and:

1. Breaks it into the smallest atomic execution steps
2. Generates an HTML artifact visualizing every step
3. Executes one step at a time with explicit approval before AND after each step

The user trades execution speed for review depth. A 3-week plan still ships in 3 weeks, but it gets reviewed at ~50 checkpoints instead of 7.

## When to invoke

Trigger phrases:
- "atomic plan", "/atomic-plan", "atomic-plan this"
- "break this into atomic steps", "smallest atomic pieces"
- "ask before each step", "ask question before each atomic step"
- "step-by-step with check-ins"
- "let's do this slowly with check-ins"

Use when the user has a substantial multi-step plan (5+ steps, multi-day work). Do NOT use for one-off tasks or small fixes. The check-in overhead only pays off when blast radius matters.

---

## Phase 1: Plan breakdown (one-time, ~10-15 min)

### Step 1.1: Identify the source plan

It might be:
- A markdown file the user references (e.g. `docs/handoff.md`)
- An HTML plan in the project root
- A ClickUp / Linear / Asana task
- Just described in conversation

If multiple candidate plans exist, ASK which one. Don't guess.

### Step 1.2: Read it fully

Don't skim. Atomic decomposition requires understanding the full arc. If the source plan references other docs, read those too.

### Step 1.3: Decompose into atomic steps

Each step MUST satisfy all five rules:

1. **One owner.** Claude runs it, you run it, or both. Never ambiguous.
2. **One verifiable outcome.** A file exists, a test passes, a curl returns expected JSON, a CI run is green. Always something concrete you can check.
3. **A named, small set of files.** Use `+ path` for new, `~ path` for modified, `- path` for deleted. Avoid "various files" or "the relevant tests".
4. **Commit-sized or less.** If a step deserves its own commit, it's right. If two steps would be one commit, merge them.
5. **Not subdivisible without losing meaning.** "Set up Python venv + install deps" is atomic. "Run the Python script" might be subdivisible into "write the function" + "run it" if those are different days of work.
6. **Self-contained.** The step's description, files, and verify check do not reference other steps. Step 2 must not say "using the schema from step 1" or "after step 3 finishes". It states its own action, its own files, and its own preconditions inline. Ordering between steps is allowed (step 2 can still run after step 1), but cross-references in the step text are not. If a step truly cannot be understood without another step's context, merge them or restate the precondition in the step's own description.

### Step 1.4: Capture per-step metadata

- Step number + short title (one line)
- 2-3 sentence description of the action
- Files touched (with + ~ - markers)
- Success check (the verification)
- Owner (Claude runs / You run / Together)
- Rough time estimate
- Whether this step ends with a commit (and what the commit message would be)

### Step 1.5: Identify inline decisions

If a step has a sub-choice that the user must make (DB vs code, auth scheme, branch strategy), tag it on the step itself. Build a "decision queue" table at the top of the HTML showing WHICH step triggers WHICH decision and what the default is if the user says "just go".

**Do NOT bundle all decisions upfront.** That's the anti-pattern this skill exists to prevent. The user should not face a 5-question wall before step 1.

### Step 1.6: Generate the HTML artifact

Save to `<project-root>/<plan-name>-atomic-plan.html`. Match the visual style of existing plan HTMLs in the repo when present (read one and mirror the CSS variables, fonts, layout). If no existing style, use a clean dark theme with one accent color.

Required sections in order:
1. **Header** - brand, status, source plan link, total step count, calendar estimate
2. **Working protocol explainer** - the per-step flow in numbered form
3. **Legend** - icons/colors for Claude-runs / You-run / Together
4. **Decision queue table** - which step triggers which decision (NOT a wall of upfront questions)
5. **Phase headers + step cards** - one card per step with all metadata
6. **Phase-by-phase effort summary table** at the bottom
7. **"Ready?" callout** with the trigger phrase ("say `proceed to step 1`")

Style notes:
- Use color-coded left borders on step cards to group by phase
- Each step card: large step number on left, body on right (title, desc, files, verify, meta)
- Files in monospace, highlighted
- Verify block visually distinct (small green-tinted left border works well)
- Pills/chips for owner (claude / user / together)

**No em-dashes anywhere in the HTML.** Use commas, periods, parentheses, hyphens.

### Step 1.7: Open the HTML

`open <path>` in the user's default browser. Don't continue.

### Step 1.8: STOP

Wait for the user to read it and respond. Do NOT execute any step before explicit approval.

---

## Phase 2: Per-step execution (recurring, one step at a time)

For each step the user approves, follow this loop EXACTLY:

### Step 2.1: Restate before touching anything

In chat (NOT in the HTML), restate:
- "Step N of M: <title>"
- What you'll do (concrete tools/commands)
- Files touched (with + ~ - markers)
- Success check
- Whether this commits (and the commit message if so)

Keep it terse. 4-6 lines max.

### Step 2.2: Ask explicitly

"Ready to execute step N?" Wait for response. Don't proceed on silence.

### Step 2.3: Wait for explicit approval

Accept: "go", "yes", "proceed", "do it", "ship it".

If the user pushes back ("why", "wait", "I don't think", "is there a better way", "couldn't we..."): STOP. Engage on the substance. Don't execute until the question is resolved. If the resolution changes the plan, update the HTML artifact and confirm before continuing.

### Step 2.4: Execute

Use appropriate tools (Bash, Edit, Write, Read). Run all commands the step needs. Don't expand scope beyond what the step described.

### Step 2.5: Report

After execution, in chat:
- What changed (with `path:line` references when applicable)
- Verification output (test results, command output, file diffs)
- Anything unexpected (output that surprised you, warnings, etc.)

If the verification didn't pass, do NOT mark the step done. Fix and re-verify, or stop and escalate.

### Step 2.6: Ask about next

"Proceed to step N+1?" Loop back to step 2.1.

If the user wants to skip ahead, redirect, or pause, do that. Update the HTML decision queue if they re-prioritize.

---

## Critical rules

- **One step at a time.** Never batch, even if the user says "go fast".
- **Always restate.** Even on rapid "go go go" approval, restate the action briefly first.
- **Decisions surface inline at the step they affect.** Never bundle 5 questions upfront.
- **Surface alternatives.** If a step has a debatable approach, mention the alternative briefly before executing.
- **Stop on pushback.** Any "why", "wait", "I don't think" pauses execution.
- **Be terse.** No filler praise ("Great question!"). No em-dashes. Get to substance.
- **HTML for the visual artifact.** Markdown for chat updates. Don't confuse the two.
- **Each step stands alone.** A step's text must not reference other steps. No "after step N", no "using the output from step N", no "continues the work from step N". If the step cannot be understood without that reference, merge the steps or restate the precondition inline.
- **Each step revertible without unwinding others.** If step N depends on step N-1 in a way that makes rollback cascade, split the steps further.
- **No commits during a step unless the step explicitly says "commit at the end".** Default is no commit; let work accumulate, commit at logical checkpoints.

---

## What this skill is NOT

- NOT for one-off tasks. Use direct execution for those.
- NOT a code-review skill. Use `/review` or `/autoplan` for that.
- NOT a planning skill. Use `/plan-eng-review` or `/plan-ceo-review` to critique a plan BEFORE atomic-plan executes it.
- NOT autonomous. The user is in the loop at every step. No "let it run" mode.

## Anti-patterns to avoid

- Asking 5 upfront questions ("answer these before step 1"). Decisions surface inline.
- Generating a 20-step plan that's secretly 5 atomic steps padded out. Steps must be genuinely atomic.
- Cross-referencing other steps in a step's description ("builds on step 2", "uses what we did in step 4"). Each step must be readable on its own; restate any preconditions inline.
- Skipping the restate step on rapid approval. Always restate, even briefly.
- Continuing after a "wait" or "why". Always pause and discuss.
- Bundling commits across multiple steps. Each step is its own commit, or no commit at all.
- Writing the HTML artifact in markdown. The visual plan is HTML for a reason: visual hierarchy, color, density.
- Adding em-dashes to the HTML or chat output. User reads them as AI-generated tells.

## File outputs

- `<project-root>/<plan-name>-atomic-plan.html` (default; user can override the name)

## Example invocation

User: "I have this plan in `docs/migration.md`. Atomic-plan it."

You:
1. Read `docs/migration.md`
2. Read any docs it references
3. Decompose into atomic steps
4. Generate `<project-root>/migration-atomic-plan.html`
5. Open it in browser
6. STOP and wait for approval
7. When approved, restate step 1, ask permission, execute, report, ask about step 2. Loop.
