Set, view, or clear session goals. Cleans up messy input into proper goal statements.

Goals are stored directly in `session_log.md` as an `## Active Goals` section at the top (below frontmatter, above dated entries).

## Arguments

$ARGUMENTS — session goal(s) in any format, or "clear" to reset, or empty to view current goals

## Instructions

### Determine the file
Based on the current working directory, find `session_log.md` in `~/.claude/projects/<project-path>/memory/`. If it doesn't exist, create it with this frontmatter:

```
---
name: session_log
description: detailed rolling session recaps with full context for project continuity
type: project
---
```

### Handle the three modes

**If $ARGUMENTS is empty or blank:** Read `session_log.md`, find the `## Active Goals` section, and display it. If no goals section exists, say "No session goals set. Run `/goal <your goals>` to set some."

**If $ARGUMENTS is "clear":** Remove the `## Active Goals (YYYY-MM-DD)` section from `session_log.md` (keep everything else). Confirm goals were cleared.

**If $ARGUMENTS is anything else:** Parse it as new goals:

1. The user's input might be:
   - Bad grammar, run-on sentences, shorthand, or stream-of-consciousness
   - Multiple goals jammed together with "and", commas, or no punctuation
   - Informal like "fix that umbra bug and also maybe start on the readme idk"

2. Clean up into clear, actionable goal statements:
   - Each goal: one sentence, properly capitalized, action-oriented (start with a verb)
   - Specific enough to know when it's done
   - Preserve the user's intent — don't add scope they didn't ask for
   - Split compound goals into separate items

3. Check if an `## Active Goals` section already exists in `session_log.md`:
   - **Exists with today's date:** APPEND the new goals to the existing list
   - **Exists with a different date:** REPLACE the old goals (stale from prior session)
   - **Doesn't exist:** Insert one

4. The `## Active Goals` section goes at the TOP of the file (right after frontmatter `---`, before any `## YYYY-MM-DD` entries):
   ```
   ## Active Goals (YYYY-MM-DD)

   - [ ] Goal one
   - [ ] Goal two
   - [ ] Goal three

   ```

5. Print the result:

```
**Session goals set:**

- [ ] Goal one
- [ ] Goal two

_Run `/goal` to view, `/goal clear` to reset. Shows up in `/tldr` and `/log`._
```

### Important
- Keep goals concise — one line each, no paragraphs
- Don't editorialize or add goals the user didn't mention
- If the user's input is genuinely unclear, ask for clarification instead of guessing
