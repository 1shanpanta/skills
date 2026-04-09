# /hackathon-radar

Find open crypto/AI/blockchain hackathons, analyze what wins, and suggest what to build.

Runs 6 sub-agents in parallel:

- **Hackathon Scout** -- searches Devpost, DoraHacks, Superteam Earn, ETHGlobal, and more
- **Portfolio Analyzer** -- reads your existing projects to find reusable code and tech strengths
- **Winner Researcher** -- studies past winners to find what judges actually reward
- **Theme Deep-Diver** -- digs into each hackathon's tracks, judging criteria, and sponsor bounties
- **Idea Generator** -- suggests 2-3 build ideas per hackathon (extend, new build, or remix)
- **Opportunity Ranker** -- scores and ranks everything into a final report

Fault-tolerant: if any agent fails, the pipeline continues with available data.

## Usage

Copy the skill folder into your skills directory:

```bash
cp -r hackathon-radar ~/.claude/skills/hackathon-radar
```

Then in Claude Code:

```
/hackathon-radar
/hackathon-radar DeFi agents
```
