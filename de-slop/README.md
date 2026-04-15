# /de-slop

Deep codebase quality cleanup using 8 parallel subagents. Removes AI slop, dead code, weak types, unnecessary defensive programming, circular dependencies, and duplicated logic.

## What it does

Launches 8 agents in parallel, each targeting a specific code quality dimension:

1. **DRY & Deduplication** -- consolidate repeated logic
2. **Type Consolidation** -- merge scattered type definitions
3. **Dead Code Removal** -- knip-powered unused code detection + removal
4. **Circular Dependencies** -- madge-powered cycle breaking
5. **Strong Typing** -- replace `any`/`unknown` with real types
6. **Defensive Programming Cleanup** -- remove pointless try/catch and error hiding
7. **Legacy/Fallback Removal** -- clean up deprecated paths and feature flags
8. **AI Slop Removal** -- kill obvious comments, stubs, debug logs, commented-out code

Each agent commits atomically. Produces a summary report at the end.

## Install

```bash
cp -r de-slop ~/.claude/commands/de-slop.md
# or symlink
ln -s "$(pwd)/de-slop/SKILL.md" ~/.claude/commands/de-slop.md
```

## Usage

```
/de-slop
```

Run from any project directory. Requires dependencies to be installed (needs `npx knip`, `npx madge`, `npx tsc`).
