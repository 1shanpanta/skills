Give me a concise summary of this session AND catch me up on the project.

## Instructions

Do two things:

### 1. Check for a project session log

Look for a `session_log.md` in the current project's memory folder (under `~/.claude/projects/`). If one exists, read it and:
- Include a **Project catch-up** section BEFORE the session summary (summarize most recent entry, current state, blockers, next steps)
- Check for an `## Active Goals` section at the top of the file. If present, use those as the session goals below (with progress status). If not present, infer the session goal from the conversation or say "fresh start -- nothing yet".

If no session log exists, skip the catch-up section entirely.

### 2. Summarize the current session

Review the entire conversation from start to now. If the session just started or was cleared, say so honestly -- don't fabricate a summary.

If session goals exist, show progress on each one (done, in progress, not started, blocked).

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

**Session goals:** *(from Active Goals in session_log.md, otherwise inferred or "fresh start -- nothing yet")*
- [ ] Goal not started
- [~] Goal in progress
- [x] Goal completed
- [!] Goal blocked — reason

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
