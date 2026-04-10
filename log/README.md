# /log

Writes a detailed session entry to `~/.claude/projects/<project-path>/memory/session_log.md`. Captures what you worked on, decisions, dead ends, blockers, and next steps. Keeps the last 8 entries.

Next time you open the project, Claude reads the log and picks up where you left off.

If you set goals with `/goal`, they get archived into the entry with final status and then cleared.

## Install

```bash
cp log/SKILL.md ~/.claude/commands/log.md
```

Add this to `~/.claude/CLAUDE.md` so Claude actually reads the log on startup:

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

## Usage

```
/log
```
