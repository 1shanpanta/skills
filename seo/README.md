# /seo

Audits a URL for SEO, accessibility, and social previews. Checks meta tags, Open Graph, Twitter cards, structured data, favicons, landmarks, contrast, tap targets, and performance. Reports findings and applies fixes to your codebase.

## Install

```bash
cp -r seo ~/.claude/skills/seo
```

## Usage

```
/seo https://your-site.com
```

## How it works

```mermaid
flowchart TD
    A["Fetch the page HTML"] --> B["Run every check<br/>meta, Open Graph, Twitter, structured data, icons, accessibility, performance, broken assets"]
    B --> C["Report PASS, FAIL or WARN per item"]
    C --> D["Find the local codebase"]
    D --> E["Fix FAIL and WARN items in source<br/>skip third-party and infrastructure"]
    E --> F["Build and type-check"]
    F --> G["Commit and push only if you ask"]
```
