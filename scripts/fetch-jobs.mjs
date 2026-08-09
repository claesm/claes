#!/usr/bin/env node
// Fetches job ads from Arbetsförmedlingen's public JobSearch API (Platsbanken)
// for Content Producer roles in Malmö / Skåne, merges them into
// docs/data/jobs.json and prunes expired listings.
//
// Run manually with: node scripts/fetch-jobs.mjs
// Run automatically by .github/workflows/fetch-jobs.yml

import { readFile, writeFile, mkdir } from "node:fs/promises";
import path from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const DATA_FILE = path.join(__dirname, "..", "docs", "data", "jobs.json");

const API_BASE = "https://jobsearch.api.jobtechdev.se/search";

// Swedish + English variants of the role we're hunting for.
const SEARCH_TERMS = ["Content Producer", "Innehållsproducent", "Content Creator"];

// Only keep ads whose workplace is in Malmö / Skåne (or explicitly remote).
const LOCATION_MATCH = /malm(ö|o)|sk[åa]ne/i;

const MAX_AGE_DAYS = 45; // prune ads older than this if they have no deadline

async function fetchTerm(term) {
  const url = `${API_BASE}?${new URLSearchParams({
    q: term,
    limit: "100",
    sort: "pubdate-desc",
  })}`;

  const res = await fetch(url, {
    headers: { accept: "application/json" },
  });

  if (!res.ok) {
    console.warn(`[warn] Query "${term}" failed: ${res.status} ${res.statusText}`);
    return [];
  }

  const json = await res.json();
  return Array.isArray(json.hits) ? json.hits : [];
}

function matchesLocation(hit) {
  const addr = hit.workplace_address || {};
  const haystack = [addr.municipality, addr.region, addr.city]
    .filter(Boolean)
    .join(" ");
  if (LOCATION_MATCH.test(haystack)) return true;
  // Some remote-friendly ads have no fixed municipality but mark remote_work.
  if (hit.remote_work === true && LOCATION_MATCH.test(hit.description?.text || "")) {
    return true;
  }
  return false;
}

function normalize(hit) {
  const addr = hit.workplace_address || {};
  return {
    id: hit.id,
    title: hit.headline || "Okänd titel",
    employer: hit.employer?.name || "Okänd arbetsgivare",
    city: addr.municipality || addr.city || null,
    region: addr.region || null,
    remote: Boolean(hit.remote_work),
    publicationDate: hit.publication_date || null,
    applicationDeadline: hit.application_deadline || null,
    url: hit.webpage_url || hit.application_details?.url || null,
    source: "Platsbanken",
    snippet: (hit.description?.text || "").slice(0, 280),
  };
}

function isExpired(job, now) {
  if (job.applicationDeadline) {
    return new Date(job.applicationDeadline).getTime() < now;
  }
  if (job.publicationDate) {
    const ageDays = (now - new Date(job.publicationDate).getTime()) / 86_400_000;
    return ageDays > MAX_AGE_DAYS;
  }
  return false;
}

async function loadExisting() {
  try {
    const raw = await readFile(DATA_FILE, "utf8");
    const parsed = JSON.parse(raw);
    return Array.isArray(parsed.jobs) ? parsed.jobs : [];
  } catch {
    return [];
  }
}

async function main() {
  const now = Date.now();
  const nowIso = new Date(now).toISOString();

  const results = await Promise.all(SEARCH_TERMS.map(fetchTerm));
  const freshHits = results.flat().filter(matchesLocation).map(normalize);

  const existing = await loadExisting();
  const byId = new Map(existing.map((job) => [job.id, job]));

  let newCount = 0;
  for (const job of freshHits) {
    if (!byId.has(job.id)) {
      newCount += 1;
      byId.set(job.id, { ...job, firstSeen: nowIso });
    } else {
      // Refresh mutable fields (deadline can change) but keep firstSeen.
      const prev = byId.get(job.id);
      byId.set(job.id, { ...job, firstSeen: prev.firstSeen });
    }
  }

  const merged = [...byId.values()].filter((job) => !isExpired(job, now));
  merged.sort((a, b) => new Date(b.publicationDate || 0) - new Date(a.publicationDate || 0));

  const output = {
    lastUpdated: nowIso,
    searchTerms: SEARCH_TERMS,
    location: { municipality: "Malmö", region: "Skåne län" },
    jobCount: merged.length,
    jobs: merged,
  };

  await mkdir(path.dirname(DATA_FILE), { recursive: true });
  await writeFile(DATA_FILE, JSON.stringify(output, null, 2) + "\n", "utf8");

  console.log(
    `Done. ${merged.length} aktuella annonser (${newCount} nya sedan senaste körning).`
  );
}

main().catch((err) => {
  console.error(err);
  process.exitCode = 1;
});
