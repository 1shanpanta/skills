# /bring-me-up-to-speed

A wise, incredibly effective tutor brings you up to speed on work that already exists: a session's changes, a PR, a subsystem, or any topic you name. It teaches incrementally, gates on mastery, keeps a running checklist, and quizzes you, so you actually understand the work instead of just hearing a summary.

```bash
cp bring-me-up-to-speed/SKILL.md ~/.claude/skills/bring-me-up-to-speed/SKILL.md
```

```
/bring-me-up-to-speed                 # infers the subject from handoff + recent git history
/bring-me-up-to-speed the step ledger # teach a specific topic, file, or PR
```

## When to use

You want to deeply understand something that was already built, not plan something new. The tutor first reconstructs the work (handoff doc, recent commits, the diff), then teaches it one step at a time, covering three pillars:

1. **The problem** - what it was, why it existed, the branches that were considered.
2. **The solution** - what was done, why that way, the design decisions and edge cases.
3. **The broader context** - why it matters and what it impacts downstream.

It gauges your level by having you restate your understanding first, drills into the whys, offers ELI5 / ELI14 / ELII on request, and verifies with quizzes (via `AskUserQuestion`) before checking anything off. The session does not end until you have demonstrated, not just claimed, that you understand every item.

## bring-me-up-to-speed vs grill-me

- `/grill-me` is forward-looking: it interrogates a plan you are still forming, walking the design tree to reach a decision.
- `/bring-me-up-to-speed` is backward-looking: it teaches you work that already exists until you understand it.

Use `grill-me` to figure out what to build. Use `bring-me-up-to-speed` to understand what was built.

## Output

- A running checklist doc (e.g. `docs/up-to-speed.md`) showing the path and what is left.
- An interactive chat session: restate, teach a step, quiz, check off, repeat, until mastery, then a closing summary.
