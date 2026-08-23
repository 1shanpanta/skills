---
name: ui-laws
description: Audit or design a UI against the 30 psychology laws behind interface decisions (Laws of UX, Jon Yablonski). Two modes. AUDIT takes a screenshot, a URL, a route, or a component file and reports which law each defect violates, with one concrete fix per finding, ordered by cost to the user. DESIGN takes a screen you are about to build and hands back the laws that constrain it before any code exists. Every finding names the law, the mechanism, and the number where the law has one (400ms Doherty, 4-7 chunks of working memory, 7 plus or minus 2). Trigger when the user types /ui-laws or says "audit this screen", "why does this feel off", "check this against the laws of ux", "is this good UX", "review this UI", "reduce cognitive load", "too many options", or asks for the psychology reason a layout is or is not working.
---

# /ui-laws - design and audit against the laws of UX

Interface psychology, used as a decision tool. The laws are only worth carrying because each
one turns a taste argument into a checkable claim. Say which law, say the mechanism, say the
fix. Never post the poster.

## Pick the mode

**AUDIT** when a thing already exists. Input is any of: a screenshot, a URL, a route in a
running dev server, a component file, a `.pen` screen.

**DESIGN** when the thing does not exist yet. Input is a description of the screen and its one
job. Output is the constraints, before code.

If the user gave you a screen without saying which, audit it.

## AUDIT procedure

1. **Name the screen's one job in a sentence.** Everything after this is measured against that
   job. If you cannot name it, that is finding number one and the most expensive one on the
   page.
2. **Look at the actual thing.** Read the component and its children, or open the URL, or read
   the screenshot. Never audit from a filename or a description of the design. If you cannot
   see it, say so and stop.
3. **Count.** Choices on the screen, distinct groups, items in the longest list, taps to finish
   the job, unlabelled icons. Counting is what turns Hick's Law from a slogan into a number.
4. **Walk the table below once, top to bottom.** Most laws will not apply. Skip them silently.
5. **Time it if the screen fetches anything.** Doherty is the only law with a number you can
   hold a build to, so measure instead of guessing: `curl -w '%{time_total}\n' -o /dev/null -s <url>`,
   or a Performance panel reading, or the render timing already in the code.
6. **Cut every finding that does not change what gets built.** A finding that survives is one
   where you can name the fix and the user it costs.

## DESIGN procedure

1. State the screen's one job.
2. Answer the six questions that decide a layout before pixels exist:
   - What is the minimum UI that lets the content be found and understood? (Occam's Razor)
   - Which choices belong on this screen, and which belong after the user commits? (Hick's Law)
   - Who carries the complexity that cannot be removed, the user or you? (Tesler's Law)
   - Which convention am I keeping, and if I break one, is it because the convention encodes a constraint I no longer have? (Jakob's Law)
   - What is the peak moment and the last moment of this flow? (Peak-End Rule)
   - What is the one element that gets emphasis, given emphasis is a fixed budget? (Von Restorff)
3. Then design. Do not enumerate the other 24 laws at someone who asked for a screen.

## The 30 laws, as decisions

### Heuristics, the ones that change a decision

| Law | The claim | Ask on the screen |
| --- | --- | --- |
| Hick's Law | decision time rises with the number and complexity of choices | how many choices, and which could move behind commitment? |
| Fitts's Law | time to acquire a target depends on its distance and size | is the most-used control the largest and nearest? is the destructive one neither? |
| Doherty Threshold | productivity soars when neither human nor machine waits, under 400ms | what is the measured number, and what covers the gap if it cannot be met? |
| Jakob's Law | users expect your product to work like the others they know | which convention am I breaking, and what does it buy? |
| Tesler's Law | complexity is conserved, someone absorbs the remainder | who is carrying it right now? |
| Postel's Law | be liberal in what you accept, conservative in what you send | does the input reject anything a human would reasonably type? |

### Gestalt, how the eye groups before it reads

| Law | The claim | Ask on the screen |
| --- | --- | --- |
| Proximity | near means related | does the spacing group the things that actually belong together? |
| Common Region | a shared boundary beats proximity | is a card drawing a boundary around unrelated things? |
| Similarity | looking alike is a promise of behaving alike | does anything look like a button and not act like one? |
| Uniform Connectedness | an explicit connection outranks every other grouping | is a line or a frame overriding a grouping I meant? |
| Prägnanz | the eye simplifies whatever you give it | if the eye is going to simplify this, did I choose the simplification? |

### Biases, how judgment bends

| Law | The claim | Ask on the screen |
| --- | --- | --- |
| Aesthetic Usability Effect | beauty raises perceived usability and hides real defects | am I calling it good because it is pretty? this one fools the builder first |
| Choice Overload | too many options damages the memory of the whole experience | is any list asking for a comparison nobody can hold? |
| Goal Gradient Effect | effort rises near the goal, and endowed progress works | does the user see how far along they are? |
| Zeigarnik Effect | unfinished tasks are remembered better than finished ones | is an incomplete state visible enough to pull them back? |
| Peak-End Rule | more total pain with a better ending is preferred to less | what is the last thing they see, and is the worst moment softened? |
| Serial Position Effect | first and last are remembered, the middle is not | is anything important buried mid-list? |
| Von Restorff Effect | the different one is remembered | how many things are emphasized? more than one means none |

### The cognitive machinery

| Law | The claim | Ask on the screen |
| --- | --- | --- |
| Cognitive Load | intrinsic load belongs to the task, extraneous load is yours to remove | which load here is mine to delete? |
| Working Memory | 4 to 7 chunks, each fading in 20 to 30 seconds | does the user have to carry anything across a step? show it instead |
| Miller's Law | 7 plus or minus 2, and never a licence to cap a list at seven | am I chunking, or am I limiting? |
| Chunking | grouping scales with the user's expertise | are the groups the ones the user would draw? |
| Cognitive Bias | knowing about a bias does not remove it, including yours | which of my judgments here is untested? |
| Mental Model | a compressed model of one system, applied to a new one | what will they assume this is, before reading? |
| Flow | challenge matched to skill, against a target that moves | is the first success reachable in the first minute? |
| Selective Attention | banner blindness is positional as much as visual | is anything important sitting where ads live? |
| Paradox of the Active User | nobody reads the manual, so guidance must arrive in context | is any guidance blocking the first action? |
| Parkinson's Law | tasks inflate to fill the time available | can this finish faster than the user expects? |
| Pareto Principle | a description of distributions, not a licence to ignore the tail | which 20% of this screen carries the work? |
| Occam's Razor | fewest assumptions **among options that predict equally well** | what is the minimum UI that still communicates? |

## Output format

For an audit, findings only, worst first:

```
1. <what is wrong, one sentence>
   Law: <name>  |  Cost: <who pays and how>
   Fix: <one concrete change, naming the file or element>
```

Then one line, `Kept:` naming what already works and should not be touched. Nothing else. No
score out of ten, no grade, no summary of the laws.

Six findings is a long audit. If you have twenty, you are listing preferences.

## Rules

- **Cite or drop it.** A finding with no law behind it is a preference. Say "this is my taste, not a law" and keep it if it is worth saying, but never dress it as a principle.
- **Never invent a law or a number.** The set is 30 and the numbers are 400ms, 4 to 7 chunks, 20 to 30 seconds, 7 plus or minus 2. Platform minimums such as a 44pt touch target are Apple's guidance, not Fitts's Law; attribute them separately.
- **Measure Doherty, never estimate it.** An unmeasured latency claim is the fastest way to lose the audit's credibility.
- **The project's design system wins.** Match the repo's existing components, spacing scale and type. An audit that recommends a redesign has answered a question nobody asked.
- **No eyebrows.** Never propose a small label above or below a heading. If the label carries information, it belongs in the heading; if not, delete it.
- **These laws are dual-use.** They make an interface intuitive and they make it addictive. Never use them to build against the user's own goal: no manufactured urgency, no obstructed exit, no dark pattern dressed as Goal Gradient or Zeigarnik. If a request needs one, say which law is being turned against the user and propose the honest version.
- **Aesthetic Usability Effect applies to you.** You are the one who just looked at the design. Say so when a judgment is only a first impression.

## Depth on any single law

The vault at `~/Desktop/vault/03-Sources/Laws of UX/` carries a note per law with the takeaways
verbatim, the study it came from, and the eight long-form articles, if this machine has it.
Read the note before quoting a study. Otherwise the source is
[lawsofux.com](https://lawsofux.com/) by Jon Yablonski.
