# /tldr

Quick session summary printed right in the conversation. No files written, no disk changes -- just a clean recap of what happened.

Covers:
- Session goal
- What got done
- Key decisions
- Code changes (files and paths)
- What's still open
- What to pick up next time

Scales to the session -- short session gets a short summary, long session gets more detail.

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
| **Purpose** | Quick "what did we do" recap | Persistent session history for future conversations |
| **Persists?** | No -- gone when conversation ends | Yes -- saved in project memory |

Use `/tldr` when you want a quick glance. Use `/log` when you want Claude to remember next time.
