---
name: review-loop
description: Two independent reviewers read the same change in parallel, the main agent fixes every real finding, and the loop repeats until both reviewers reply CLEAN on the same final code. Load when the user says "/review-loop", "review loop", "two agents review until they agree", "keep reviewing and fixing until clean", or "loop reviewers on this PR".
---

# Review loop

Two reviewers with different angles read one change. You fix what they find. They read again.
The loop ends when both say CLEAN about the same commit.

## Scope

Take the target from the user: a PR number, a branch, or the current diff. If none is named, use the diff
against the base branch. Run the project's own checks yourself first (tests, types, lint) and note the
real exit codes. A reviewer must never be the first to find a red test.

## The two reviewers

Start both in one message so they run in parallel. Both are read-only: no edits, no commits, no push,
no production commands, and no secrets read.

| Reviewer | Model | Angle |
|---|---|---|
| A | the strongest model available, high effort | Adversarial. Semantics of every external API, failure paths, state left behind, ordering of checks, anything destructive before a guard, docs that now lie. |
| B | a different, cheaper model, high effort | The project rules, tests that would still pass if the logic broke, a line-by-line read for wrong variables and swallowed errors, docs against code. It runs the tests and the linter. |

Different models and different angles are the point. Two copies of one reviewer agree for the same reason.

## Prompt for each reviewer

Give each one:

1. The target and the exact diff command.
2. What the change does, in three sentences.
3. What earlier rounds fixed, so it does not report them again.
4. Its angle, from the table.
5. The output contract: a ranked list of `file:line`, a concrete failure scenario and a suggested fix.
   If nothing real is left, the single word `CLEAN` and one line on what it checked. No nitpicks.

## Each round

1. Collect both reports. Merge duplicates.
2. Check every finding against the code yourself. Reproduce it when it is cheap.
3. Fix each real finding. Write one test for a bug that has no test. Break the logic once to see the test go red.
4. Reject a wrong finding only with evidence (the line, the doc, the command output). Tell the reviewer why in the next prompt.
5. Run the project checks again. Quote the real numbers.
6. Commit the round as one commit, then start the next round with both reviewers on the new code.

## Stop rules

- **Done:** both reviewers reply `CLEAN` in the same round, on the code as it now stands. A `CLEAN` from before your last change does not count.
- **No round cap.** Keep going while rounds find real defects. Report progress each round, so the user can stop the loop.
- **Dispute:** if a reviewer repeats a finding you rejected with evidence, in two rounds in a row, stop and ask the user. Never keep arguing.
- **Churn:** if a round only brings style findings, call it done and list them as skipped.

## Never

- Never push, merge, deploy or run an upload from inside the loop. Report and let the user decide.
- Never let a reviewer edit. One writer, so the history stays readable.
- Never count a round as clean because the fix "looks right". The reviewers read the new code.

## Report

End with a short list: rounds run, findings fixed, findings rejected with the reason, anything skipped,
and the final check numbers. Name the commit both reviewers agreed on.
