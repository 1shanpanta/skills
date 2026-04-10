Give me a concise summary of this session AND catch me up on the project.

## Instructions

Do two things:

### 1. Check for a project session log

Look for a `session_log.md` in the current project's memory folder (under `~/.claude/projects/`). If one exists, read it and include a **Project catch-up** section BEFORE the session summary. This section should:
- Summarize the most recent session log entry (what was done, current state, blockers)
- List the prioritized next steps from the log
- Keep it concise -- highlight what matters for picking up where we left off

If no session log exists, skip this section entirely.

### 2. Summarize the current session

Review the entire conversation from start to now. If the session just started or was cleared, say so honestly -- don't fabricate a summary.

## Output format

Do NOT write anything to disk -- just print it here.

### TLDR

---

**Project catch-up** *(from session log -- skip if none exists)*

*Last session (DATE):* One-line summary of what happened.

*Current state:* Where things stand right now.

*Blockers:*
- Active blockers or "none"

*Next steps:*
- Prioritized list from the log

---

**This session:**

**Session goal:** One sentence describing what we set out to do. Or "fresh start -- nothing yet" if the session just began.

**What got done:**
- Concrete things that were accomplished, with specifics (not vague)
- Or "nothing yet -- session just started"

**Key decisions:**
- Decisions made and why (only if any were made)

**Code changes:**
- Files created, edited, or deleted (with paths)
- Or "none -- discussion only"

**Still open:**
- Anything unresolved, blocked, or punted to later
- Or "nothing -- all wrapped up"

**Next time:**
- What to pick up next session (if applicable)

Keep it tight. No fluff. If the session was short, the summary should be short too.
