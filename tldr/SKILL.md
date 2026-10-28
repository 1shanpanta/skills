Give me a concise summary of this session only.

## Instructions

Read only the current conversation, from its start to now. Do not read `session_log.md`, the memory folder, or any other session. Do not run a tool to look for them.

If the session just started or was cleared, say so. Do not invent a summary.

Infer the session goals from the conversation (the user's first request, a handoff file the user pointed at, or a later change of direction). Show progress on each one (done, in progress, not started, blocked). If no goal is clear, write "fresh start -- nothing yet".

## Output format

Do NOT write anything to disk -- just print it here.

### TLDR

**Session goals:**
- [ ] Goal not started
- [~] Goal in progress
- [x] Goal completed
- [!] Goal blocked, with the reason

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
