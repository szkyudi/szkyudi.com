# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Personal profile site (szkyudi.com) built with Astro. A single-page, statically-generated profile in Japanese: avatar, bio, social links, and a list of products/links. No backend, no framework UI libraries — plain `.astro` components with scoped styles.

## Commands

```bash
npm run dev      # local dev server with HMR
npm run build    # static build to ./dist/
npm run preview  # serve the production build locally
npm run astro check   # type-check .astro files
```

Both `package-lock.json` and `pnpm-lock.yaml` exist; pick one package manager and keep its lockfile in sync.

## Architecture

- `src/layouts/Layout.astro` — the single shared layout. Wraps every page; takes `title`, `description`, and optional `noindex` props for per-page `<meta>`. Owns the Google Tag Manager snippet (ID `GTM-PNP2X2ZH`) and the global styles (imports `destyle.css` reset, sets the dark theme `#111`/`#f0f0f0` and font stack). All page-level SEO/meta flows through these props.
- `src/pages/` — file-based routing. `index.astro` is the home page (composes `Header` + `Products`). `redirect/my-nfc.astro` is a tracking landing page: it renders `noindex`, then JS-redirects to `/` after 300ms so NFC-tag taps register a pageview before bouncing home.
- `src/components/` — presentational `.astro` components. `Products.astro` is the hardcoded list of product/link cards (each rendered via `Card.astro`); edit the `<Card>` entries there to change what's shown. `Header`/`Socials`/`SnsIconLink` build the profile masthead.
- Images use Astro's `astro:assets` `<Image>` component (e.g. `Header.astro` outputs AVIF via `sharp`). Static files (including `public/images/`) live in `public/`.

## Conventions

- Content is Japanese — keep copy, alt text, and comments consistent with that.
- Analytics: GTM loads in the layout `<head>`; `partytown` (configured in `astro.config.mjs` to forward `dataLayer.push`) is available for offloading third-party scripts. `src/scripts/external-link-tracking.js` sends a `gtag` click event for outbound `http` links.
- TypeScript is `astro/tsconfigs/strict`.
