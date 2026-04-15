Deep codebase quality cleanup using 8 parallel subagents. Removes AI slop, dead code, weak types, unnecessary defensive programming, circular dependencies, and duplicated logic. Run this on any project to bring code quality to production standard.

## How to Execute

Launch **all 8 subagents in parallel** using worktree isolation. Each agent works independently, produces a report of what it found and changed, and commits atomically. After all agents complete, review their changes and resolve any conflicts.

**IMPORTANT:** Before launching agents, ensure dependencies are installed (`npm install` or equivalent). Several agents depend on tooling (knip, madge, tsc) being available.

---

## Agent 1: DRY & Deduplication

Search the entire codebase for duplicated logic, copy-pasted code blocks, and repeated patterns. Consolidate into shared utilities or abstractions ONLY where it genuinely reduces complexity -- not for the sake of abstraction. Three similar lines are fine; three similar 20-line blocks are not.

Steps:
1. Search for duplicate functions, repeated logic blocks, and copy-pasted patterns across all source files
2. Identify which duplications are worth consolidating (>10 lines, used 3+ times, or likely to diverge)
3. Extract shared code into appropriate locations (utils, helpers, shared modules) following existing project conventions
4. Update all call sites
5. Run the type checker to confirm nothing broke
6. Commit with `[refactor] consolidate duplicated {description}`

---

## Agent 2: Type Consolidation

Find all type definitions, interfaces, and enums across the codebase. Identify types that are defined in multiple places or that should be shared. Consolidate into canonical locations.

Steps:
1. Search for all `type`, `interface`, `enum` definitions across the codebase
2. Identify duplicates, near-duplicates, and types that are redefined in multiple files
3. Determine the canonical location for shared types (existing shared types file, or create one following project conventions)
4. Consolidate duplicates into single definitions and update all imports
5. Run the type checker to confirm nothing broke
6. Commit with `[refactor] consolidate {type name} definitions`

---

## Agent 3: Dead Code Removal (knip)

Use knip (or equivalent tool) to find all unused exports, unused files, unused dependencies, and unreferenced code. Verify each finding before removing.

Steps:
1. Install knip if not present: `npx knip` (or check if already configured)
2. Run knip and collect all findings: unused exports, unused files, unused dependencies
3. For EACH finding, verify it's truly unused by grepping for references (knip can have false positives with dynamic imports, barrel files, and test utilities)
4. Remove confirmed dead code, unused files, and unused dependencies
5. Run the type checker and test suite to confirm nothing broke
6. Commit with `[remove] dead code identified by knip`

---

## Agent 4: Circular Dependency Untangling (madge)

Use madge to detect circular dependencies. Refactor to break cycles by extracting shared interfaces, reorganizing modules, or introducing dependency inversion.

Steps:
1. Install madge if not present, then run: `npx madge --circular --extensions ts,js src/`
2. Map out all circular dependency chains
3. For each cycle, determine the cleanest break point:
   - Extract shared types/interfaces into a separate file
   - Use dependency inversion (depend on abstractions)
   - Reorganize module boundaries
4. Refactor to break each cycle
5. Re-run madge to confirm all cycles are broken
6. Run the type checker to confirm nothing broke
7. Commit with `[refactor] break circular dependency between {modules}`

---

## Agent 5: Strong Typing

Find all `any`, `unknown`, `as any`, type assertions, and weak types. Research what the correct types should be by examining usage, related packages, and upstream type definitions.

Steps:
1. Search for all instances of: `any`, `unknown`, `as any`, `as unknown`, `// @ts-ignore`, `// @ts-expect-error`, `// eslint-disable.*no-explicit-any`
2. For each instance, determine the correct strong type by:
   - Reading how the value is used downstream
   - Checking the source library's type definitions
   - Looking at related code for type hints
   - Checking the framework/library documentation
3. Replace with the correct strong type
4. Remove any `@ts-ignore` or `@ts-expect-error` comments that are no longer needed
5. Run `npx tsc --noEmit` to confirm zero type errors
6. Commit with `[fix] replace weak types with strong types in {area}`

---

## Agent 6: Defensive Programming Cleanup

Find all try/catch blocks, fallback patterns, and error-swallowing code. Remove any that don't serve a specific purpose of handling genuinely unknown/external input.

Steps:
1. Search for all `try/catch`, `.catch()`, `|| fallback`, `?? fallback`, and similar defensive patterns
2. For each instance, evaluate:
   - Does this handle genuinely external/unknown input (user input, API responses, file I/O)? KEEP IT.
   - Does this catch errors from internal code that should never throw? REMOVE IT.
   - Does the catch block swallow errors silently (empty catch, `catch(e) {}`, logging and continuing)? REMOVE or replace with proper error propagation.
   - Does it use a fallback value that hides bugs (e.g., `|| []` when empty array means something broke)? REMOVE IT.
3. Remove unnecessary defensive code
4. Ensure remaining error handling is explicit about what it catches and why
5. Run tests to confirm nothing broke
6. Commit with `[refactor] remove unnecessary defensive programming in {area}`

---

## Agent 7: Legacy & Fallback Code Removal

Find deprecated code paths, feature flags for shipped features, backwards-compatibility shims, TODO/FIXME/HACK comments pointing to old decisions, and unused migration code.

Steps:
1. Search for: `@deprecated`, `// TODO`, `// FIXME`, `// HACK`, `// legacy`, `// old`, `// fallback`, `// backwards`, `// compat`, `// temporary`, `// workaround`, feature flags, environment-based code switches
2. For each finding, evaluate:
   - Is this still needed? Check if the "new" path it defers to exists and works.
   - Is this a fallback for an old API version that's no longer supported? Remove.
   - Is this a feature flag for something already shipped? Remove the flag, keep the feature code.
   - Is this a compatibility shim? Check if the old thing it supports still exists. If not, remove.
3. Remove dead paths and simplify branching logic
4. Ensure all remaining code paths are clean and singular (one way to do each thing)
5. Run tests to confirm nothing broke
6. Commit with `[remove] legacy/fallback code in {area}`

---

## Agent 8: AI Slop & Comment Cleanup

Find and remove AI-generated artifacts: boilerplate comments that describe the obvious, stubs that were never implemented, comments describing work-in-progress transitions, and unnecessary verbosity.

Steps:
1. Search for patterns indicating AI slop:
   - Comments that just restate the code: `// increment counter`, `// return the result`, `// handle error`
   - Placeholder/stub implementations: `// TODO: implement`, `throw new Error('Not implemented')`, `pass`
   - Transition comments: `// replaced old X with new Y`, `// previously this was...`, `// migrated from...`
   - Unnecessary section dividers: `// ========`, `// --- Helper Functions ---`
   - Over-commented obvious code where every line has a comment
   - Console.log/print debug statements left in production code
   - Commented-out code blocks
2. For each finding:
   - If the comment describes the obvious: DELETE
   - If the comment describes important WHY context: KEEP (but make concise)
   - If it's a stub: either implement it or delete the entire function
   - If it's commented-out code: DELETE (it's in git history)
   - If it's a debug statement: DELETE
3. Any comment you keep or edit should be helpful to a new developer understanding the codebase. Be concise.
4. Run tests to confirm nothing broke
5. Commit with `[remove] AI slop and unnecessary comments in {area}`

---

## Output Format

After all 8 agents complete, produce a summary:

```
DE-SLOP REPORT: {project name}

Agent 1 - DRY:              {X duplications consolidated}
Agent 2 - Types:            {X types consolidated}
Agent 3 - Dead Code:        {X files, Y exports, Z deps removed}
Agent 4 - Circular Deps:    {X cycles broken}
Agent 5 - Strong Types:     {X weak types replaced}
Agent 6 - Defensive Code:   {X unnecessary try/catch removed}
Agent 7 - Legacy Code:      {X legacy paths removed}
Agent 8 - AI Slop:          {X comments/stubs removed}

Total files changed: X
Type check: PASS/FAIL
Tests: PASS/FAIL
```

If any agent's changes conflict with another's, resolve conflicts favoring the more specific change and re-run the type checker.
