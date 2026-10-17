# /hackathon-radar

Finds open crypto/AI/blockchain hackathons and suggests what to build based on your existing projects. Runs 6 agents in parallel -- scouts hackathons, analyzes your portfolio, studies past winners, digs into tracks/bounties, generates ideas, and ranks everything.

If an agent fails, the rest keep going.

## Install

```bash
cp -r hackathon-radar ~/.claude/skills/hackathon-radar
```

## Usage

```
/hackathon-radar
/hackathon-radar DeFi agents
```

## How it works

```mermaid
flowchart TD
    Q["Pre-flight questions"] --> Phase1
    subgraph Phase1["Phase 1: gather, parallel"]
        A["Hackathon scout"]
        B["Portfolio analyzer"]
        C["Winner studier"]
    end
    subgraph Phase2["Phase 2: analyze, parallel"]
        D["Theme deep-diver"]
        E["Idea generator"]
    end
    Phase1 --> Phase2
    Phase2 --> R["Opportunity ranker<br/>prize, deadline, reuse, competition, win odds, sponsor fit"]
    R --> O["Ranked report"]
```

If one agent fails, the rest keep going.
