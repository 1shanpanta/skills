Core Principles

/Modern & Secure: Generate modern, performant, and secure code. Avoid dead code and unnecessary bloat.

Web Access: Use your web search tool when you need current information on libraries, best practices, or security.

No Execution: Remember, you cannot run servers or execute code. Your output is static; I am responsible for all testing and deployment.

Research: Make a web search when you are not sure of your answer. When brainstorming ideas, suggesting tools/protocols, or making claims about what exists or doesn't exist — ALWAYS do extensive research first. Double and triple check claims before presenting them. Search for existing implementations, prior art, and competing projects BEFORE pitching an idea as novel. It's better to burn extra tokens on thorough research than to lead the user down a path based on unchecked assumptions.

Key Requirements

Design: Use modern, component-based architecture and design systems. For mobile applications, use NativeWind as much as possible. For web-based projects, use shadcn/ui. For icons, use Lucide Icons.

Favicon & Branding: When scaffolding a new project, always remove the default Next.js (or framework) favicon and replace it with a project-specific one. Use an emoji or SVG favicon that matches the project theme. Never ship with the default framework logo.

Code Quality: Eliminate dead code. Write clean, readable code with consistent formatting. Apply `no-unnecessary-condition` — disallow conditionals where the type is always truthy or always falsy.

Avoid Unnecessary useEffect: STOP USING `useEffect` — DO NOT USE `useEffect` UNLESS ABSOLUTELY NECESSARY. Use a `[prevState, setPrevState] = useState()` paradigm and check for changes between the previous value and current value in the render function. Only use `useEffect` to synchronize with external systems (browser APIs, third-party widgets, network requests). Do not use it for derived state, event handling, or React-to-React communication.

Performance: Optimize for speed with efficient code and data handling.

Security: Always validate user input to prevent attacks. Implement robust authentication and authorization. Never hard-code secrets.

Supply Chain Safety: Never run `npm install` without a lockfile present -- lockfiles prevent surprise version bumps. Use `--ignore-scripts` in CI npm installs to block post-install payloads. Pin exact versions for critical dependencies (e.g., `"axios": "1.14.0"` not `"^1.14.0"`) to avoid pulling compromised patch releases.

API Safety: When updating environment variables on services like Render, NEVER use PUT (it replaces all vars). Always use PATCH or individual add/update endpoints to avoid wiping existing vars.

Clarity: Be direct and concise. Explain your reasoning for design and security choices. Do not make assumptions.

Codebase Research First: Research the codebase before editing. Never change code you haven't read. Understand the surrounding context, related files, and how the code fits into the broader system before making any modifications.

Edit Integrity: Before every file edit, re-read the file first. After editing, re-read to confirm the change applied correctly. The Edit tool fails silently when old_string doesn't match due to stale context. After 10+ messages in a conversation, never trust memory of file contents -- always re-read before editing.

Verify Before Claiming Done: Never report a task as complete without running the project's build/type-check (e.g. `npx next build`, `npx tsc --noEmit`). If no type-checker is configured, say so instead of assuming success. Bytes hitting disk does not mean the code compiles.

Dead Code Before Refactors: Before any structural refactor on a file over 300 LOC, first remove dead props, unused exports, unused imports, and debug logs. Commit that cleanup separately, then start the real work with a clean token budget.

Rename Safety: Grep is text matching, not an AST. When renaming or changing any function/type/variable, search separately for: direct calls, type references, string literals containing the name, dynamic imports, re-exports, barrel files, and test mocks. Never assume a single grep caught everything.

Ask Before Running Unfamiliar Commands: For new or unverified CLI tools (not standard ones like git, npm, etc.), show the command first and ask before running it. Don't assume unfamiliar tools are authenticated or working — ask first, run second.

React Keys in `.map()`: Always provide a stable, unique `key` prop when rendering lists with `.map()`. Never rely on array index as the key when list items can be reordered, inserted, or deleted. Use a unique identifier from the data (e.g., `id`, `slug`) instead.

Project Location: All passion projects go in `~/Desktop/Code/Passion-Projects/`. Always create new passion project repos there.

Task Completion: When I ask for changes, complete ALL items in the task list before stopping. Do not leave tasks unfinished - check back against the original requirements before reporting done.

File Targeting: Before editing any file, confirm you're editing the correct file. Check the project structure first - don't assume file paths. For WordPress projects, identify the active theme directory before making changes.

Stand Your Ground: When I question a change, don't automatically revert it. Explain your reasoning and only change if the logic is wrong. Don't flip-flop on correct edits.

Minimal Changes: Don't over-deliver or add extras I didn't ask for. Keep changes minimal and focused on exactly what I requested. When in doubt, do less and ask.

Development Workflow

Auto-Open Browser: When setting up dev scripts, use `concurrently` with `wait-on` to automatically open the browser when the dev server is ready. Pattern: `"dev": "concurrently \"next dev\" \"wait-on http://localhost:PORT && open http://localhost:PORT\""`

Multiple Services: When a project needs multiple services (e.g., dev server + MailHog, dev server + database), use `concurrently` to start them all with one command. Use color-coded prefixes for better output readability.

Development Tools: Integrate development/testing tools (like MailHog for email testing) directly into the dev command so everything starts with one command.

Git Commits

Branch Safety: For git operations, always confirm the correct base branch before creating new branches. Check current branch state before stashing or rebasing.

Atomic Commits: Make small, focused commits. Each commit should do one thing. Never combine unrelated changes (e.g. a bug fix and a new feature) into a single commit — always split them into separate commits with a short pause between each so they don't share the same timestamp.

Commit Message Format: Use lowercase bracket prefixes. Never include "Co-Authored-By" lines from any AI model.
- `[init]` — project scaffolding, first commit
- `[add]` — new feature, file, or functionality
- `[edit]` — update or improve existing code
- `[fix]` — bug fix
- `[remove]` — delete code, files, or dependencies
- `[refactor]` — restructure without changing behavior
- `[style]` — formatting, CSS, UI-only changes
- `[config]` — settings, env, build config, CI/CD
- `[docs]` — documentation changes (README, comments)
- Message should be lowercase, concise, no period. Example: `[fix] prevent null crash on empty profile`

Documentation

Do Not Create Unnecessary .md Files: NEVER proactively create documentation files (*.md) like SETUP-GUIDE.md, MIGRATION-COMPLETE.md, SETUP.md, etc. Only the project README.md should exist. Do not create additional markdown documentation files unless explicitly requested by the user.

LLM-Friendly Project Docs: For every project, create a `docs/` folder containing LLM-friendly markdown files that document the architecture, components, and data model. These files should be concise, structured, and designed so that an LLM can quickly understand the project context and continue from where you left off. Typical files: `docs/architecture.md` (system design, data flow, key decisions), `docs/components.md` (component reference with props and behavior), `docs/data-model.md` (types, schemas, data formats). Keep these updated when making significant changes.

Session Log

At the start of every conversation inside a project directory, check if a `session_log.md` exists in that project's memory folder (`~/.claude/projects/<project-path>/memory/session_log.md`). If it exists, read it silently to understand what happened in previous sessions -- decisions made, blockers, dead ends, next steps, and current project state. Use this context to pick up where we left off without asking Ishan to re-explain things.
