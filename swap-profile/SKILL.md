---
name: swap-profile
description: Move every claude pane in the current herdr tab onto a different Claude account profile, with each pane's context kept. Use when one account hits its usage or spend limit and the work must continue on another account.
---

# /swap-profile - continue the same work on another account

One account hits its limit. This skill moves every claude pane in the current
[herdr](https://herdr.dev) tab onto another account profile. Each pane keeps its
herdr slot and its context.

For each pane the script does this:

1. It sends `/exit` to claude and waits for the shell.
2. It copies the pane transcript into the target profile. Transcripts are per
   profile, so `--resume` finds nothing without the copy.
3. It restarts claude in the same pane with `--resume <session>`.
4. It sends a prompt, `continue` by default.

The script also answers the startup gates in the target profile, because that
profile has never seen this directory. It sets
`projects[<cwd>].hasTrustDialogAccepted` and `bypassPermissionsModeAccepted` in
the profile config, and `permissions.defaultMode: bypassPermissions` in the
profile `settings.json`. The pane resumes with no keypress.

## Requirements

- `herdr`, with the panes in one tab.
- One fish function for each profile, which sets `CLAUDE_CONFIG_DIR`. The script
  reads `~/.config/fish/config.fish` to find them. Example:

  ```fish
  function work
      CLAUDE_CONFIG_DIR=$HOME/.claude-work claude $argv
  end
  ```

- macOS. The login check reads the keychain.

## Steps

1. Run `python3 scripts/swap-profile.py --list-profiles`. Print each profile,
   its account and its login state.
2. Ask the user for the target profile. This is the only question you ask. A
   profile marked `NOT logged in` cannot be a target.
3. Run with `--dry-run`. Print the panes that will move.
4. Run without `--dry-run`.
5. Report the result. Report every pane with status `failed` or `skipped`.

## Swap the calling pane

The script always drops the pane that runs it. A direct run in a one-pane tab
reports `"panes": []`, because a pane cannot restart its own agent. Use a helper
pane. Do not ask the user.

1. Write the report first. The swap stops the agent that writes it.
2. `herdr pane split <self_pane> --direction down --ratio 0.15`
3. `herdr pane run <helper_pane> python3 scripts/swap-profile.py --profile <name> --tab <tab_id> --close-self`

The calling pane keeps its herdr slot. The helper pane closes itself.

## Rules

- The target is always the calling pane's tab. Never ask the user which tab.
  Pass `--tab` only when the user names a tab without being asked.
- Never ask the user to confirm the plan. Run the dry run, print it, then run
  for real.
- Use `--message ""` to send no prompt after the resume.

## Options

```
--profile <name>    target profile, required
--tab <tab_id>      default: the tab the script runs in
--message <text>    prompt sent after resume (default: continue)
--dry-run           show the plan, change nothing
--close-self        close the calling pane at the end
--list-profiles     print name, config dir, login state and account
```

Set `SWAP_PROFILE_DEFAULT` to name the profile that uses the plain `~/.claude`
directory. The default is `cl`.
