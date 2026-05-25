# CLAUDE.md

Project memory for fast session startup. Read this first — no need to re-explore.

## What this is
Static single-page website for the **Pray Buddy** iOS app (a Muslim daily prayer
companion). The site hosts the **Privacy Policy** and **Support/FAQ**.

- Owner: Muhlis Karaca / RSPKTVLL (likafilm.com)
- Contact email used on the page: info@likafilm.com

## Stack & hosting
- Plain static HTML — no build step, no framework, no dependencies, no package.json.
- All CSS is inline in a `<style>` block; all content is in a single file.
- Hosted on **GitHub Pages**. `CNAME` = `praybuddy.likafilm.com` (custom domain).
- Pushing to the default branch publishes the site.

## Files
- `index.html` — the entire site (hero, `#privacy` section, `#support` section, footer).
- `CNAME` — GitHub Pages custom domain. Do not delete or the domain breaks.

## Design / content conventions
- Dark theme: background `#0a0a0f`, body text `#bbb`/`#e0e0e0`, gold accent `#d4a84b`.
- Headings use a serif stack ('New York', Georgia, serif); body uses the Apple system font stack.
- Privacy policy has a "Last updated" date (line ~90) — bump it when policy text changes.
- Core privacy claim: the app collects/stores/transmits **no** personal data; everything stays on-device.
  Only exception noted: Diyanet/DITIB prayer-time source sends a district ID (no personal data).

## How to preview locally
Just open `index.html` in a browser, or `python3 -m http.server` and visit localhost.

## Working notes
- Keep everything in `index.html` unless the site genuinely grows; this is intentionally minimal.
- When editing privacy/support copy, keep the tone factual and the privacy guarantees consistent.
