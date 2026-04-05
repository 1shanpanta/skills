# /seo

Full SEO, accessibility, and social preview audit. Point it at any URL and it will:

- Audit meta tags, Open Graph, Twitter cards, structured data, favicons, PWA metadata
- Check accessibility basics (landmarks, labels, tap targets, contrast)
- Flag performance and CLS issues
- Report findings in a structured table
- Apply fixes directly to your codebase

## Usage

Copy the skill folder into your skills directory:

```bash
cp -r seo ~/.claude/skills/seo
```

Then in Claude Code:

```
/seo https://your-site.com
```
