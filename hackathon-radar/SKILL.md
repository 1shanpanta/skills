Find open crypto/AI/blockchain hackathons, analyze what wins, and suggest what to build.

If an argument is passed (e.g., `/hackathon-radar DeFi agents`), use it as a focus filter. Otherwise, search broadly for crypto/AI/blockchain hackathons.

## Pre-Flight: Ask the User

Before running anything, ask the user two questions:

1. **"Where are your projects?"** — Ask for the directory path where their existing projects live (e.g., `~/Desktop/Code/Passion-Projects`). If the user says "here" or "current directory", use the current working directory. If they say "skip" or "none", skip the Portfolio Analyzer agent entirely and focus only on new build ideas.

2. **"Any specific focus?"** — Ask if they want to narrow the search (e.g., "DeFi only", "Solana hackathons", "AI agents", "anything crypto"). If they say "no" or "everything", search broadly. If an argument was already passed to the skill (e.g., `/hackathon-radar DeFi agents`), use that as the focus and skip this question.

Once you have both answers, proceed with the pipeline.

## Architecture

This skill runs **6 sub-agents in parallel** with fault tolerance. If any agent fails after retries, the pipeline continues with whatever data is available. No single failure kills the run.

## Agent Pipeline

### Phase 1 — Data Gathering (parallel, independent)

Launch these 3 agents simultaneously. They have no dependencies on each other.

**Agent 1: Hackathon Scout**
- Run 8-10 web searches across these platforms:
  - `site:devpost.com` — blockchain, AI, crypto hackathons
  - `site:dorahacks.io` — hackathon listings
  - `site:earn.superteam.fun` — bounties and hackathons
  - `site:ethglobal.com` — upcoming events
  - `allhackathons.com` — blockchain and AI themes
  - `dev.events/hackathons` — blockchain category
  - `web3.career/crypto-events/hackathon`
  - General: "crypto blockchain AI hackathon 2026 open registration"
- For each hackathon found, extract: name, platform, URL, dates, prize pool, themes/tracks, registration status
- Filter: must have open or upcoming registration, must be relevant to crypto/AI/blockchain/agents
- Deduplicate across platforms (same hackathon often listed on multiple sites)
- Output: structured list of hackathons with all metadata

**Agent 2: Portfolio Analyzer**
- Read the project directories at the path the user provided in the pre-flight step
- If the user skipped this step, do NOT run this agent — mark its output as `[SKIPPED]`
- For each project, read README.md or package.json to understand: what it does, tech stack, current state (complete vs prototype)
- Build a profile: the user's strongest tech stacks, recurring themes, reusable components
- Output: portfolio summary with per-project capsules and a "strengths" section

**Agent 3: Winner Researcher**
- For each major platform, search for past winners and standout projects:
  - "devpost hackathon winners blockchain AI 2025 2026"
  - "dorahacks hackathon winners crypto DeFi"
  - "ETHGlobal finalists 2026"
  - "Superteam hackathon winners Solana"
  - "what makes a winning hackathon project crypto"
- Identify patterns: what types of projects win? What do judges value? Common traits of winners?
- Output: winner patterns summary + specific notable winning projects with why they won

### Phase 2 — Analysis (parallel, depends on Phase 1)

Wait for Phase 1 to complete. Then launch these 2 agents simultaneously.

**Agent 4: Theme Deep-Diver**
- Takes the hackathon list from Agent 1
- For each hackathon (top 10 by relevance), do a focused web search:
  - Search for the hackathon's specific tracks, judging criteria, sponsor prizes
  - Look for "what judges are looking for" or organizer blog posts
  - Check if there are bounty-specific prizes (e.g., "best use of Chainlink", "best Solana integration")
- Cross-reference with Agent 3's winner patterns
- Output: per-hackathon analysis with tracks, what wins, and sponsor alignment

**Agent 5: Idea Generator**
- Takes output from Agents 1, 2, 3, and 4
- For each of the top hackathons, generate 2-3 build ideas:
  - **"Extend" ideas**: take an existing project from the portfolio and adapt/extend it for the hackathon
  - **"New build" ideas**: net-new project ideas inspired by the hackathon theme + market gaps
  - **"Remix" ideas**: combine two existing projects or take a winning pattern and apply it to a different domain
- Each idea should include: one-line pitch, which hackathon track it fits, what can be reused from the portfolio, estimated effort (weekend vs 1-2 weeks), and why it could win
- Output: ranked idea list per hackathon

### Phase 3 — Synthesis (sequential, depends on Phase 2)

**Agent 6: Opportunity Ranker**
- Takes ALL outputs from Agents 1-5
- Scores each hackathon + idea combination on:
  - **Prize pool** (higher = better)
  - **Deadline proximity** (enough time to build?)
  - **Reuse factor** (how much existing code can be leveraged?)
  - **Competition level** (niche hackathons = less competition)
  - **Win probability** (based on winner patterns from Agent 3)
  - **Sponsor alignment** (does the idea use sponsor tech for bounty prizes?)
- Produce the final ranked report

## Fault Tolerance

Each agent follows this retry/fallback protocol:

1. **First attempt**: run the agent normally
2. **If it fails**: retry once with a simplified prompt (fewer searches, broader queries)
3. **If retry fails**: mark that agent's output as `[UNAVAILABLE]` and continue the pipeline
4. **Downstream agents**: if an upstream agent's data is `[UNAVAILABLE]`, work with whatever data IS available and note the gap in the report

Rules:
- Never let one agent's failure crash the entire pipeline
- If Agent 1 (Scout) fails, the skill is effectively dead — tell the user and suggest they run `/hackathon-radar` again later
- If Agent 2 (Portfolio) fails or was skipped, skip "extend existing project" ideas and focus on new builds
- If Agent 3 (Winners) fails, skip win probability scoring and winner pattern analysis
- If Agent 4 (Theme Deep-Diver) fails, use the basic metadata from Agent 1 instead
- If Agent 5 (Idea Generator) fails, output the hackathon list without ideas and suggest the user re-run
- If Agent 6 (Ranker) fails, output the unranked ideas from Agent 5 as-is

## Output Format

Present the final report like this:

```
# Hackathon Radar — {date}

## Top Opportunities

### #1: {Hackathon Name}
- Platform: {platform} | Prize: {amount} | Deadline: {date}
- Tracks: {relevant tracks}
- URL: {link}
- Win pattern: {what wins here, from Agent 3}

#### Build idea A: {name} (Extend {existing project})
- Pitch: {one-liner}
- Track fit: {which track}
- Reuse: {what existing code/infra to leverage}
- Effort: {weekend | 1 week | 2 weeks}
- Why it wins: {reason based on winner patterns + judging criteria}

#### Build idea B: {name} (New build)
- Pitch: {one-liner}
- Track fit: {which track}
- Stack: {suggested tech stack}
- Effort: {weekend | 1 week | 2 weeks}
- Why it wins: {reason}

---
(repeat for top 5-8 hackathons)

## Also Worth Watching
- {hackathon}: {one-liner reason} — registration opens {date}

## Gaps in This Report
- {any agent failures or data gaps}
```

## Notes

- Use the current date to filter out expired hackathons
- Prioritize hackathons with deadlines 1-8 weeks out (enough time to build)
- Always include the hackathon URL so the user can register immediately
- When suggesting ideas, be specific — not "build a DeFi thing" but "build an x402-compatible price oracle that reuses your existing wallet infra"
- If the user provided a portfolio path, reference specific files/components when suggesting reuse
- If no portfolio was provided, focus on new build ideas with concrete tech stack suggestions
