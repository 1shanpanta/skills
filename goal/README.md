# /goal

Set, view, or clear session goals. Type messy, stream-of-consciousness goals and it cleans them up into actionable items. Goals are stored directly in `session_log.md` as an `## Active Goals` section -- no extra files.

Integrates with `/tldr` and `/log`:
- **`/tldr`** reads active goals and shows progress (done, in progress, not started, blocked)
- **`/log`** archives goals into the dated entry with final status, then clears the active section

Three modes:
- `/goal fix that umbra bug and also merge prs idk` -- parses messy input into clean goals
- `/goal` (no args) -- shows current goals
- `/goal clear` -- wipes goals

## Setup

### 1. Install the skill

```bash
cp goal/SKILL.md ~/.claude/commands/goal.md
```

### 2. Update /tldr and /log

This skill works best with the updated versions of `/tldr` and `/log` that read from the Active Goals section. Copy them from this repo:

```bash
cp tldr/SKILL.md ~/.claude/commands/tldr.md
cp log/SKILL.md ~/.claude/commands/log.md
```

## Usage

Set goals at the start of a session:

```
/goal debug the umbra uint8array error, merge the stacked prs, and maybe start on the readme
```

Output:

```
Session goals set:

- [ ] Debug the Umbra Uint8Array error
- [ ] Merge the stacked PRs
- [ ] Start drafting the README

Run /goal to view, /goal clear to reset. Shows up in /tldr and /log.
```

Add more goals later:

```
/goal also need to test nfc on android
```

Goals from the same day get appended. New day replaces stale goals.

## How it fits together

```
/goal           --> writes Active Goals to session_log.md
/tldr           --> reads Active Goals, shows progress
/log            --> archives goals into dated entry, clears Active Goals
```

Single file, no extra state. Goals live and die in `session_log.md`.
