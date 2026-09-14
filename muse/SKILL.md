---
name: muse
description: Hand implementation work to a worker model through opencode, while this session keeps the plan and the spec. Load when the user says "/muse", "use muse", "muse it", "give this to muse", "run it on muse", "hand it to muse", "delegate this", "orchestrate this", or asks for the plan here and the code on a cheaper model.
---

# Muse worker

This session writes the plan and the spec. A worker model writes the code, reads
its own diff, runs the build and the tests, and fixes what fails. The bridge is
`scripts/muse` in this skill folder. It runs `opencode run` headless.

The default worker is `opencode/muse-spark-1.3-contributor-free` at variant
`xhigh`: 1,048,576 token context, 131,072 token output, zero cost on the
opencode contributor tier. Any other model works. `scripts/muse --list` prints
every model opencode can reach. `scripts/muse --list opencode` prints the free
tier.

## Who owns what

| Step | Owner |
|---|---|
| Decide the files, and the change in each file | this session |
| Decide the command that proves the work | this session |
| Write the spec file | this session |
| Write the code | worker |
| Read `git diff` | worker |
| Run the build, the type check and the tests | worker |
| Fix what fails, then run the command again | worker |
| Read the worker's final output block | this session |

The worker is not finished when the code is written. It is finished when the
acceptance command passes and the output of that command is in its last message.
Write that rule into every spec.

## Pick the worker

- Bulk mechanical work, proved by one command: the default free model.
- Work that needs a bigger model: `--model openrouter/<vendor>/<model>`. That
  spends money on the opencode account, not on this session.
- A read-only survey of a repo: add `--plan`.
- A model with no reasoning variants: add `--variant none`.
- A different default for a whole shell: `export MUSE_MODEL=...`.

## When the worker hits a limit

A free tier returns a rate limit, or a quota runs out. Rotate, do not wait.

1. Rotate the model and keep the session. `-c` carries the worker's context and
   `--model` swaps the model under it:
   `scripts/muse --dir <repo> -c --model opencode/mimo-v2.5-free --variant none -m "continue"`
   `scripts/muse --list opencode` prints the free tier to rotate through. Add
   `--variant none` when the next model has no reasoning variants.
2. Read what is left. `opencode stats` reports sessions, tokens and cost, and it
   is first party. A balance plugin adds the provider quota:
   `@bitio/opencode-provider-balance` draws a balance panel in the TUI sidebar,
   `opencode-balance-mcp` serves the quota and the prepaid balance over MCP.
   Install with `opencode plugin <module>`.
3. Rotate the account when the whole provider is exhausted. The
   `opencode-multi-account` plugin marks an account exhausted on a 429, moves to
   the next account by priority, and retries.

Read a plugin before you install it. `opencode-balance-mcp` publishes no
repository link.

## When to delegate

**The test: can you write the acceptance command before the code exists?**

- Yes, and the work is bulk and mechanical: delegate. Ten test files proved by
  one `vitest run` is the shape that pays.
- No: do it here. Design judgement, copy decisions and small edits cost more
  through a worker, because the intent has to be written out in full first.

Delegation does not shrink the conversation. A long session is dominated by the
context that is re-sent every turn, and a worker changes nothing there. It moves
the diff, the test output and the correction loop off this context. It does not
move the plan.

## The loop

1. Plan here. Name the files, the change in each file, and the command that
   proves the work.
2. Write the spec to a file, never into a shell argument. Put the file outside
   the repo, in a scratch directory: `<scratch>/muse-<slug>.md`.
3. Run the worker:
   `scripts/muse --dir <repo> <scratch>/muse-<slug>.md`
4. Read the last block of the worker's output: the acceptance command and its
   result. Read nothing else.
5. Send corrections to the same worker session:
   `scripts/muse --dir <repo> -c -m "<correction>"`

## Spec file shape

One task per spec. Name every file by path. Write the sections in this order:

1. The change in each file.
2. The acceptance command, and the exact output that counts as a pass.
3. The order of work: write the code, read `git diff`, run the command, fix,
   repeat until the command passes.
4. What the worker must not touch.
5. The instruction to end the reply with the output of the acceptance command.

## What the worker reads

opencode loads `AGENTS.md` from the working directory up to the project root,
and the global `~/.config/opencode/AGENTS.md`. It also auto-loads skills from
`~/.claude/skills/`. It does not read `~/.claude/CLAUDE.md`. Put any standard
the worker must follow in the repo `AGENTS.md`, in the `instructions` list in
`~/.config/opencode/opencode.json`, or in the spec itself.

## Cheaper sessions, whatever you delegate

Ranked by real saving, measured against a session that reached 67 MB:

1. **One project per session.** Every turn re-sends the whole context, so cost
   grows with the square of the session, not with the work. End a session when
   its task ends.
2. **Push reading into subagents.** A review agent can spend 109,120 tokens and
   return one page. Those tokens never enter this context. Any "read across many
   files and tell me what you find" job belongs there, not inline.
3. **Keep tool output narrow.** End a command in `grep` or `tail`. A bare test
   run pastes hundreds of lines into context on every call.
4. **Fewer screenshots.** Images are expensive. Take the one that answers the
   question.
5. **Never re-read a file after editing it.** The harness tracks file state and
   `Edit` fails loudly, so the read buys nothing.
6. **Work on the host, not across it.** Copy down, edit, copy back costs a round
   trip per file. Run the session on the machine that holds the repo.

## Rules

- One worker per task. Parallel work needs one git worktree per worker, or two
  workers fight over the same files.
- `--auto` is on by default: the worker approves its own file writes and shell
  commands. Point it at a worktree or a scratch directory when the task is not
  clearly safe, and never at a production checkout.
- `--no-auto` drops that blanket approval and falls back to the permission rules
  in the opencode config. If a rule asks, a headless run has nobody to answer,
  and it stalls. Use `--no-auto` from an interactive terminal.
- A worker that reports a pass without the command output has proved nothing.
  Ask again with `-c`.
