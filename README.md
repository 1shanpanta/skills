# skills

Custom slash commands for [Claude Code](https://claude.ai/code).

Inspired by [Matt Pocock's skills repo](https://github.com/mattpocock/skills).

## Available Skills

### `/seo`

Full SEO, accessibility, and social preview audit. Point it at any URL and it will:

- Audit meta tags, Open Graph, Twitter cards, structured data, favicons, PWA metadata
- Check accessibility basics (landmarks, labels, tap targets, contrast)
- Flag performance and CLS issues
- Report findings in a structured table
- Apply fixes directly to your codebase

## Usage

Copy any `SKILL.md` file into your `~/.claude/commands/` directory (rename to `<skill-name>.md`):

```bash
cp seo/SKILL.md ~/.claude/commands/seo.md
```

Then use it in Claude Code:

```
/seo https://your-site.com
```
