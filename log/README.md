# /log

Save a detailed session recap to a rolling log file. Type `/log` at the end of any coding session and it captures everything -- what you worked on, decisions made, dead ends, blockers, next steps, and project state.

Next time you open the project, Claude reads the log and picks up where you left off. No re-explaining, no wasted context.

- Writes to `~/.claude/projects/<project-path>/memory/session_log.md`
- Keeps the last 8 entries, oldest rotates out
- Creates the file automatically if it doesn't exist
- Updates topic memories when session decisions should be permanent

Each entry includes:

- Summary of the session
- What was worked on (detailed, not just bullet points)
- Key decisions and reasoning
- Code changes made and files touched
- Blockers and open questions
- Dead ends (so you don't retry failed approaches)
- Dependencies and external context
- Current project state snapshot
- Prioritized next steps
- Momentum check

## Setup

### 1. Install the skill

Copy the skill folder into your commands directory:

```bash
cp -r log ~/.claude/commands/
# rename SKILL.md to log.md
mv ~/.claude/commands/log/SKILL.md ~/.claude/commands/log.md
rm -r ~/.claude/commands/log
```

Or just copy the file directly:

```bash
cp log/SKILL.md ~/.claude/commands/log.md
```

### 2. Add the read instruction to your global CLAUDE.md

This is required so Claude actually reads the log at the start of each conversation. Add this to `~/.claude/CLAUDE.md`:

```
Session Log

At the start of every conversation inside a project directory, check if a
session_log.md exists in that project's memory folder
(~/.claude/projects/<project-path>/memory/session_log.md). If it exists,
read it silently to understand what happened in previous sessions --
decisions made, blockers, dead ends, next steps, and current project state.
Use this context to pick up where we left off without asking the user to
re-explain things.
```

Without this step, the log file gets written but never read back. Both pieces are needed.

## Usage

At the end of a session:

```
/log
```

That's it. Claude reviews the full conversation and writes a detailed entry.
