Write a detailed session log entry for the current conversation.

## Instructions

1. **Determine the project memory path.** Based on the current working directory, find or create the corresponding `~/.claude/projects/<project-path>/memory/` folder. If a `session_log.md` file doesn't exist there, create one with this frontmatter:

```
---
name: session_log
description: detailed rolling session recaps with full context for project continuity
type: project
---
```

2. **Check for active goals.** Look for an `## Active Goals` section at the top of `session_log.md` (between frontmatter and dated entries). If it exists, include those goals with final status in the log entry. After writing the entry, REMOVE the `## Active Goals` section from the top of the file (the goals are now archived inside the dated entry).

3. **Review the full conversation.** Go through everything discussed in this session -- messages, tool calls, decisions, code changes, dead ends, blockers.

4. **Write a new entry at the TOP of the file** (below the frontmatter, above any existing entries — and above any Active Goals section, which you're about to remove anyway) using this exact format:

```
## YYYY-MM-DD -- [short descriptive title]

**Summary:**
2-3 sentence paragraph describing what this session was about, the goal,
and the outcome. Write it so someone with zero context can understand.

**Session goals:** *(include only if Active Goals section existed)*
- [x] Completed goal
- [~] Partially completed goal — what's left
- [ ] Not started goal
- [!] Blocked goal — reason

**What we worked on:**
- Detailed list of activities, not just "did X" but what specifically
- Include context on why each thing was done

**Key decisions & reasoning:**
- Decision made -- why we chose this over alternatives

**Code changes made:**
- List of concrete changes that shipped (or "none -- planning only")

**Files touched:**
- file/paths/here.ts
- (or "none")

**Blockers / Open questions:**
- Unresolved stuff that needs attention next time

**What didn't work / Dead ends:**
- Approaches we tried and abandoned, so we don't retry them

**Dependencies & external context:**
- Links to other systems, APIs, services, PRs, issues relevant to this work

**Current project state:**
Honest snapshot of where the project stands right now after this session.

**Next steps (prioritized):**
1. Most important thing to do next
2. Second priority
3. Third priority

**Mood / momentum:**
One line -- are we stuck, cruising, exploring, blocked, ready to ship, etc.
```

5. **Rotate old entries.** If there are more than 8 entries in the file, remove the oldest ones (at the bottom) to keep only the 8 most recent.

6. **Update topic memories if needed.** If any key decisions from this session should be permanent knowledge (not session-specific), also save or update the relevant topic memory files.

7. **Confirm when done.** Tell me what you logged and how many entries are in the file now.
