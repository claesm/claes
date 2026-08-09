# Content Producer job search — Malmö/Skåne

A small, free, self-hosted web tool that automatically watches for **Content
Producer** jobs in **Malmö/Skåne** on **Platsbanken** (Arbetsförmedlingen)
and gives you one-click search links into other job boards that don't offer
a free public search API.

## How it works

- **`scripts/fetch-jobs.mjs`** — a Node script that queries
  [JobTech Dev's JobSearch API](https://jobsearch.api.jobtechdev.se/)
  (the same open data that powers Platsbanken) for "Content Producer",
  "Innehållsproducent" and "Content Creator", keeps only ads located in
  Malmö/Skåne (or explicitly remote), and writes the result to
  `docs/data/jobs.json`. It merges with previous results so nothing is lost,
  marks newly-seen ads, and prunes ads whose application deadline has passed.
- **`.github/workflows/fetch-jobs.yml`** — runs that script once a day
  (06:00 UTC) via GitHub Actions and commits the updated `jobs.json`. This is
  what makes the search run "on its own" — no server needed, and it keeps
  working even when nobody has the page open. You can also trigger it
  manually from the *Actions* tab (`workflow_dispatch`).
- **`docs/`** — a static web page (plain HTML/CSS/JS, no build step) that
  reads `docs/data/jobs.json` and shows the ads as cards, with:
  - a keyword filter and a "Malmö only" toggle,
  - "Ny" (new) and "Distans" (remote) badges,
  - a "Dölj" (hide) button per ad (stored in `localStorage`, so ads you've
    already handled stay hidden on your device),
  - a **"Sök live nu"** button that queries the API directly from your
    browser for the freshest results, on top of the daily cache,
  - an **"Andra källor"** panel with pre-filled search links to LinkedIn,
    Indeed, Monster, Google for Jobs and Platsbanken's own web UI — sites
    that don't expose a free search API and so can't be polled
    automatically, but which you can jump into with one click.

## Setting it up

1. **Enable GitHub Pages**: repo *Settings → Pages → Build and deployment →
   Source: "Deploy from a branch"*, branch `claude/job-search-web-solution-p7d5jg`
   (or `main` after merging), folder **`/docs`**. The page will then be live
   at `https://<user>.github.io/<repo>/`.
2. **Let the workflow run once** (it fires automatically on schedule, or
   trigger it manually from the Actions tab) so `docs/data/jobs.json` gets
   populated for the first time.
3. Open the page — it auto-loads the latest cached results and keeps
   checking Platsbanken daily from then on, no further action needed.

## Running locally

```bash
node scripts/fetch-jobs.mjs   # populates docs/data/jobs.json
npx serve docs                # or: python3 -m http.server -d docs 8000
```

## Customizing the search

Edit the constants at the top of `scripts/fetch-jobs.mjs`:

- `SEARCH_TERMS` — the job titles/keywords to search for.
- `LOCATION_MATCH` — the regex used to keep only relevant municipalities/regions.
- `MAX_AGE_DAYS` — how long to keep an ad that has no listed deadline.

And in `docs/app.js`, `buildSourceLinks()` controls which other job boards
show up in the "Andra källor" panel and how the search URLs are built.

## Limitations

- Platsbanken/Arbetsförmedlingen's data is covered automatically via their
  open API — this is the only source that's truly hands-off.
- Sites like LinkedIn and Indeed don't offer a free, open search API, so
  they're handled as ready-made search links instead of automatic scraping
  (scraping them would violate their terms of service).
- The "Sök live nu" button calls the API straight from your browser; if your
  network blocks that request, the daily GitHub Actions run still keeps
  `jobs.json` up to date.
