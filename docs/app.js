const DATA_URL = "data/jobs.json";
const LIVE_API_URL = "https://jobsearch.api.jobtechdev.se/search";
const HIDDEN_KEY = "cp-jobs-hidden-ids";

const DEFAULT_KEYWORD = "Content Producer";
const DEFAULT_LOCATION = "Malmö";

const jobsListEl = document.getElementById("jobsList");
const lastUpdatedEl = document.getElementById("lastUpdated");
const keywordFilterEl = document.getElementById("keywordFilter");
const malmoOnlyEl = document.getElementById("malmoOnly");
const liveSearchBtn = document.getElementById("liveSearchBtn");
const liveSearchStatus = document.getElementById("liveSearchStatus");
const sourceLinksEl = document.getElementById("sourceLinks");

let currentData = { jobs: [], lastUpdated: null };

function getHiddenIds() {
  try {
    return new Set(JSON.parse(localStorage.getItem(HIDDEN_KEY) || "[]"));
  } catch {
    return new Set();
  }
}

function hideJob(id) {
  const hidden = getHiddenIds();
  hidden.add(id);
  localStorage.setItem(HIDDEN_KEY, JSON.stringify([...hidden]));
  render();
}

function formatDate(iso) {
  if (!iso) return "okänt datum";
  try {
    return new Date(iso).toLocaleDateString("sv-SE", {
      year: "numeric",
      month: "short",
      day: "numeric",
    });
  } catch {
    return iso;
  }
}

function jobCardHtml(job) {
  const hiddenIds = getHiddenIds();
  const isHidden = hiddenIds.has(job.id);
  const isNew = currentData.lastUpdated && job.firstSeen === currentData.lastUpdated;

  const badges = [];
  if (isNew) badges.push('<span class="badge new">Ny</span>');
  if (job.remote) badges.push('<span class="badge remote">Distans</span>');

  const location = [job.city, job.region].filter(Boolean).join(", ") || "Okänd ort";
  const deadline = job.applicationDeadline
    ? `Sista ansökningsdag: ${formatDate(job.applicationDeadline)}`
    : "Inget sista ansökningsdatum angivet";

  return `
    <article class="job-card ${isHidden ? "hidden-job" : ""}" data-id="${job.id}">
      <div class="badges">${badges.join("")}</div>
      <h3><a href="${job.url || "#"}" target="_blank" rel="noopener">${escapeHtml(job.title)}</a></h3>
      <p class="job-meta">
        ${escapeHtml(job.employer)} · ${escapeHtml(location)} · Publicerad ${formatDate(job.publicationDate)}<br />
        ${deadline} · Källa: ${escapeHtml(job.source || "Platsbanken")}
      </p>
      ${job.snippet ? `<p class="job-snippet">${escapeHtml(job.snippet)}…</p>` : ""}
      <div class="job-actions">
        <button type="button" class="hide-btn" data-id="${job.id}">Dölj</button>
      </div>
    </article>
  `;
}

function escapeHtml(str) {
  const div = document.createElement("div");
  div.textContent = str ?? "";
  return div.innerHTML;
}

function render() {
  const keyword = keywordFilterEl.value.trim().toLowerCase();
  const malmoOnly = malmoOnlyEl.checked;
  const hiddenIds = getHiddenIds();

  const filtered = currentData.jobs.filter((job) => {
    if (hiddenIds.has(job.id)) return false;
    if (keyword && !job.title.toLowerCase().includes(keyword)) return false;
    if (malmoOnly && !/malm(ö|o)/i.test(job.city || "")) return false;
    return true;
  });

  if (filtered.length === 0) {
    jobsListEl.innerHTML = `<p class="empty-state">Inga annonser matchar just nu. Prova att rensa filtren, eller kolla "Andra källor" nedan.</p>`;
    return;
  }

  jobsListEl.innerHTML = filtered.map(jobCardHtml).join("");

  jobsListEl.querySelectorAll(".hide-btn").forEach((btn) => {
    btn.addEventListener("click", () => hideJob(btn.dataset.id));
  });
}

async function loadCachedData() {
  try {
    const res = await fetch(DATA_URL, { cache: "no-store" });
    const data = await res.json();
    currentData = data;
    updateLastUpdatedLabel(data.lastUpdated, data.jobCount);
    render();
  } catch (err) {
    jobsListEl.innerHTML = `<p class="empty-state">Kunde inte läsa in sparade jobbannonser.</p>`;
    console.error(err);
  }
}

function updateLastUpdatedLabel(lastUpdated, count) {
  if (!lastUpdated) {
    lastUpdatedEl.textContent =
      "Ingen automatisk körning har skett ännu. Kör GitHub Actions-workflowet eller klicka \"Sök live nu\".";
    return;
  }
  const date = new Date(lastUpdated);
  lastUpdatedEl.textContent = `Senast uppdaterad automatiskt: ${date.toLocaleString("sv-SE")} · ${count ?? "?"} annonser bevakas.`;
}

async function runLiveSearch() {
  liveSearchBtn.disabled = true;
  liveSearchStatus.textContent = "Söker direkt mot Platsbankens API…";

  try {
    const url = `${LIVE_API_URL}?${new URLSearchParams({
      q: DEFAULT_KEYWORD,
      limit: "100",
      sort: "pubdate-desc",
    })}`;
    const res = await fetch(url, { headers: { accept: "application/json" } });
    if (!res.ok) throw new Error(`API svarade ${res.status}`);
    const json = await res.json();
    const hits = Array.isArray(json.hits) ? json.hits : [];

    const skaneHits = hits.filter((hit) => {
      const addr = hit.workplace_address || {};
      const haystack = [addr.municipality, addr.region, addr.city].filter(Boolean).join(" ");
      return /malm(ö|o)|sk[åa]ne/i.test(haystack);
    });

    const liveJobs = skaneHits.map((hit) => {
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
        url: hit.webpage_url || null,
        source: "Platsbanken (live)",
        snippet: (hit.description?.text || "").slice(0, 280),
        firstSeen: null,
      };
    });

    // Merge live results into the currently shown list without touching the cached file.
    const byId = new Map(currentData.jobs.map((j) => [j.id, j]));
    for (const job of liveJobs) {
      if (!byId.has(job.id)) byId.set(job.id, job);
    }
    currentData = { ...currentData, jobs: [...byId.values()] };
    render();

    liveSearchStatus.textContent = `Klart. Hittade ${liveJobs.length} annonser i Skåne just nu (${hits.length} totalt för sökordet).`;
  } catch (err) {
    console.error(err);
    liveSearchStatus.textContent =
      "Kunde inte söka direkt mot API:et just nu (t.ex. pga nätverk/CORS i din webbläsare). Den dagliga automatiska bevakningen fungerar ändå via GitHub Actions.";
  } finally {
    liveSearchBtn.disabled = false;
  }
}

function buildSourceLinks(keyword, location) {
  const kw = encodeURIComponent(keyword);
  const loc = encodeURIComponent(location);
  return [
    {
      name: "Platsbanken (webben)",
      url: `https://arbetsformedlingen.se/platsbanken/annonser?q=${encodeURIComponent(`${keyword} ${location}`)}`,
    },
    {
      name: "LinkedIn",
      url: `https://www.linkedin.com/jobs/search/?keywords=${kw}&location=${loc}%2C%20Sweden`,
    },
    {
      name: "Indeed",
      url: `https://se.indeed.com/jobb?q=${kw}&l=${loc}`,
    },
    {
      name: "Monster",
      url: `https://www.monster.se/jobb/sok/?q=${kw}&where=${loc}`,
    },
    {
      name: "Google för jobb",
      url: `https://www.google.com/search?q=${encodeURIComponent(`${keyword} jobb ${location}`)}&ibp=htl;jobs`,
    },
  ];
}

function renderSourceLinks() {
  const links = buildSourceLinks(DEFAULT_KEYWORD, DEFAULT_LOCATION);
  sourceLinksEl.innerHTML = links
    .map((l) => `<a href="${l.url}" target="_blank" rel="noopener">${escapeHtml(l.name)}</a>`)
    .join("");
}

keywordFilterEl.addEventListener("input", render);
malmoOnlyEl.addEventListener("change", render);
liveSearchBtn.addEventListener("click", runLiveSearch);

renderSourceLinks();
loadCachedData();
