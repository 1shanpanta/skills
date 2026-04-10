# /tldr

Quick session summary + project catch-up printed right in the conversation. No files written, no disk changes -- just a clean recap of what happened and where the project stands.

Covers:
- **Project catch-up** -- reads the project's `session_log.md` (if one exists) to summarize the last session, current state, blockers, and next steps
- **Session summary** -- what got done, key decisions, code changes, what's still open, and what to pick up next

Scales to the session -- short session gets a short summary, long session gets more detail. If the session just started, it tells you honestly and still gives you the project catch-up so you can hit the ground running.

## Usage

Copy the skill file into your commands directory:

```bash
cp tldr/SKILL.md ~/.claude/commands/tldr.md
```

Then in Claude Code:

```
/tldr
```

## How is this different from /log?

| | /tldr | /log |
|---|---|---|
| **Output** | Prints to conversation | Writes to disk |
| **Purpose** | Quick "what did we do" recap + project catch-up | Persistent session history for future conversations |
| **Reads session log?** | Yes -- uses it for project context | No -- it writes the log |
| **Persists?** | No -- gone when conversation ends | Yes -- saved in project memory |

Use `/tldr` when you want a quick glance or need to catch up. Use `/log` when you want Claude to remember next time.
