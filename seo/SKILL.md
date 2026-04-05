Run a full SEO, accessibility, and social preview audit on a website, then apply fixes to the codebase.

If an argument is passed, that's the target URL. If no argument, ask for the URL.

## Audit Process

1. **Fetch the page** using browser tools or WebFetch. Get the full HTML source.
2. **Run every check below** against the live page.
3. **Report findings** in a structured table: status (PASS/FAIL/WARN), category, details.
4. **Identify the local project** -- find the codebase in the current working directory (or ask if unclear).
5. **Apply code fixes** for all FAIL and WARN items that can be fixed in source code.
6. **Skip** anything that's third-party/infrastructure (Vercel headers, CDN compression, TLS config).
7. **Build/type-check** after all fixes to confirm nothing is broken.
8. **Commit and push** only if the user asks.

## Checks to Run

### Meta Information
- [ ] `<title>` exists and is 30-60 characters
- [ ] `<meta name="description">` exists and is 50-160 characters
- [ ] `<meta name="robots">` directive exists
- [ ] `<html lang="...">` attribute is set
- [ ] Canonical URL is defined (`<link rel="canonical">` or meta)

### Favicon & Icons
- [ ] Favicon link tag exists and the file returns HTTP 200
- [ ] Apple touch icon is defined
- [ ] Icons are not default framework logos (Next.js, Vite, etc.)

### Technical SEO
- [ ] `robots.txt` exists and returns 200
- [ ] `sitemap.xml` exists and returns 200
- [ ] `robots.txt` references the sitemap
- [ ] Render-blocking resources -- flag non-critical CSS/JS that blocks first paint
- [ ] Google Fonts or external fonts use `preconnect` and non-blocking loading

### Open Graph (Social Previews)
- [ ] `og:title` exists (10-70 chars, ideally 40-60)
- [ ] `og:description` exists (50-200 chars, ideally 110-160)
- [ ] `og:image` exists with absolute URL (ideally 1200x630px)
- [ ] `og:url` exists with absolute URL
- [ ] `og:type` exists (usually "website")

### Twitter Card
- [ ] `twitter:card` exists (summary_large_image preferred)
- [ ] `twitter:title` exists
- [ ] `twitter:description` exists
- [ ] `twitter:image` exists with absolute URL

### Structured Data
- [ ] JSON-LD `<script type="application/ld+json">` exists
- [ ] Schema type matches page purpose (WebApplication, Article, Product, etc.)
- [ ] Required fields are populated (name, url, description)

### PWA Metadata
- [ ] Web app manifest is linked (`<link rel="manifest">` or manifest.ts/json)
- [ ] `<meta name="theme-color">` is set
- [ ] Manifest includes name, short_name, icons, start_url, display

### Accessibility Basics
- [ ] Semantic landmarks exist: `<header>`, `<nav>`, `<main>`, `<footer>`
- [ ] All form `<input>` elements have associated `<label>` (via `htmlFor`/`id`)
- [ ] All interactive elements (buttons, links) are at least 48x48px tap targets
- [ ] Images have `alt` attributes
- [ ] Skip-to-content link exists (for multi-page apps with navbars)
- [ ] Color contrast meets WCAG AA (4.5:1 for normal text, 3:1 for large)

### Performance & CLS
- [ ] External fonts use `font-display: swap` or `optional`
- [ ] Font fallback metrics are defined (`size-adjust`, `ascent-override`) to reduce layout shift
- [ ] Images/embeds have explicit dimensions or `aspect-ratio` to reserve space
- [ ] No layout-shifting content injected above the fold after load

### Runtime Errors
- [ ] No JavaScript console errors on page load
- [ ] No failed network requests (4xx/5xx) on page load
- [ ] Auth hydration endpoints return 200 (not 401) for anonymous users

## Report Format

```
## SEO Audit: [URL]

| Status | Category | Check | Details |
|--------|----------|-------|---------|
| PASS   | Meta     | Title | "My App - Do Things" (35 chars) |
| FAIL   | Favicon  | File  | /vite.svg returns 404 |
| WARN   | A11y     | Tap targets | 5 buttons below 48px |

### Summary
- X passes, Y failures, Z warnings
- [List of fixes to apply]
```

After the report, proceed to fix all FAIL and WARN items in the source code. Explain each fix briefly as you go.
