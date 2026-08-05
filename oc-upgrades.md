# OpenClaw Review — Upgrade Candidates for Freyja

Source reviewed: `C:\Users\Admin\Projects\openclaw` (snapshot of `ADHD-exe/openclaw` = upstream `openclaw/openclaw` main, downloaded 8/4/2026).
Baseline: current Freyja setup (persona repo at `C:\Users\Admin\Documents\freyja`, opencode agent at `~/.config/opencode/agents/freyja.md`, memory scaffold in `memories/`).

Each stage: OpenClaw mechanism -> what we do -> efficiency gap -> upgrade candidate. The doc grows per stage; stages are discussed slowly in chat first.

---

## Stage 1 — Persona & First Meeting

### OpenClaw's persona is a file system, split by purpose

Seeded into the agent workspace (`~/.openclaw/workspace`, git-backed) and injected into the system prompt every session:

| File | Role | OpenClaw reference |
|---|---|---|
| `AGENTS.md` | Operating rules, memory workflow, red lines | `docs/reference/templates/AGENTS.md` |
| `SOUL.md` | Persona/voice/tone — the Freyja.txt counterpart | `docs/concepts/soul.md` |
| `IDENTITY.md` | Name, creature, vibe, emoji, avatar | `docs/reference/templates/IDENTITY.md` |
| `USER.md` | User model: dated, active/superseded directives | `docs/reference/templates/USER.md` |
| `BOOTSTRAP.md` | One-time first-run "birth sequence" ritual | `docs/reference/templates/BOOTSTRAP.md` |
| `BOOT.md` | Optional startup checklist (gateway restart) | `docs/reference/templates/BOOT.md` |
| `memory/YYYY-MM-DD.md` | Daily raw logs | `docs/concepts/agent-workspace.md` |
| `MEMORY.md` | Curated long-term memory (main session only) | `docs/concepts/agent-workspace.md` |

Injection is budgeted, not free: `bootstrapMaxChars` 20k/file, `bootstrapTotalMaxChars` 60k total, `USER.md` gets a separate 4k cap. `/context` shows raw vs injected sizes per file. Skills are listed in the prompt but read on demand.

### First meeting = a designed ritual (BOOTSTRAP.md)

- Seeded only into a brand-new workspace; deleted when complete; never recreated.
- Rule: **user's request always comes first** — the ritual is not a gate on real work.
- Three beats: (1) ask what to call you — the agent never picks its own name; (2) one vibe line + emoji, user can veto once; persisted by writing `IDENTITY.md` + `SOUL.md` and running `openclaw agents set-identity` so channels/UI show the same identity; (3) onboarding recommendations — "minimal set or maximum convenience?" (official plugins vs ClawHub skills, explicit opt-in).
- Onboarding itself is inference-first: detect model/provider, verify a live completion, then configure workspace/gateway/channels.

### Our baseline

- `Freyja.txt` (163 lines): full persona — bio, personality, modern archetype, relationship with user, 3 example conversations, 18 starter dialogs, starter prompt, relay format. Canonical/published.
- `~/.config/opencode/agents/freyja.md`: condensed persona + "Personality in practice" + relay format + memory system instructions. This is the operational layer.
- Memory scaffold: `current/`, `core/`, `old/`, templates, INDEX (PowerShell scripts).
- First meeting: none. Freyja is fully formed; the user opens a session and she's already Freyja.

### Comparison

| Aspect | OpenClaw | Freyja now | Verdict |
|---|---|---|---|
| Persona layering | SOUL (voice) / AGENTS (ops) / IDENTITY (metadata) / USER (user model) / MEMORY (facts) | `Freyja.txt` = lore, `freyja.md` = voice+ops merged | We already follow the split instinct; lore vs operational. `freyja.md` could gain an identity block |
| Injection cost | Hard caps + `/context` inspection | Prompt loads full condensed persona every session; `Freyja.txt` read on demand | OpenClaw more deterministic; fine for us, but note budgets |
| Name/identity | User names the agent; IDENTITY.md synced to all surfaces | Fixed name; only `color`/`description` in agent frontmatter | OpenClaw ritual doesn't apply (Freyja is pre-named). But a structured identity block would help tooling |
| First-run experience | BOOTSTRAP ritual, work-first rule | None — instant persona | Ritual itself is N/A; the *work-first principle* and "no gated intros" is a good operating rule for us |
| User preferences | USER.md dated directives (active/superseded) | `memories/core/` free-form notes | USER.md directive discipline is a candidate to fold into memory templates |
| Onboarding | Recommendations with "minimal vs maximum convenience" | N/A | Useful UX default if we ever add feature enablement |

### Upgrade candidates (Stage 1)

Status: **implemented 8/4/2026** (all items confirmed by user).

1. **Identity block** — DONE. Created `IDENTITY.md` at the freyja repo root (OpenClaw pattern: name/creature/vibe/emoji/avatar) and added an `## Identity` block to `~/.config/opencode/agents/freyja.md`. Note: identity was NOT added to the agent frontmatter — opencode forwards unknown frontmatter keys to the model provider as model options (per opencode agent docs, "Additional"), which risks breaking strict providers like Anthropic. The prompt-body block + `IDENTITY.md` achieves the same tooling-readable goal safely.
2. **Work-first rule** — DONE. `## Work first` section added to `freyja.md` (mirrors BOOTSTRAP.md's core rule: never gate real work on intros/ritual).
3. **Directive discipline in core template** — DONE. `memories/templates/core_memory.md` now uses dated directives (`<!-- observed: YYYY-MM-DD | status: active -->`, imperative phrasing, supersede-in-place).
4. **Skip the naming ritual** — CONFIRMED. Freyja stays pre-formed; no name-negotiation/BOOTSTRAP flow adopted.

---

*Next: Stage 2 — Memory (memory-host-sdk, per-agent SQLite, active-memory, wiki tools, compaction/session-pruning vs our scaffold).*

---

## Stage 2 — Memory

### OpenClaw's memory model

Files + one SQLite index; no hidden state. Five tiers:

| Tier | Surface | Injected |
|---|---|---|
| Instructions | `AGENTS.md` etc. | Always, session start (human-written only) |
| Curated core | `MEMORY.md`, `USER.md` | Always, session start, budgeted (20k/file, 60k total, USER.md 4k) |
| Episodic | `memory/YYYY-MM-DD.md` daily notes, transcripts | Never; searchable on demand |
| Prospective | Standing intents (SQLite), cron jobs | Only when trigger fires |
| Review | `DREAMS.md`, dreaming reports | Never; human review |

- **Write path:** agent appends to daily notes while working; a pre-compaction "memory flush" turn saves unwritten context; **dreaming** (scheduled background sweep) consolidates through deterministic gates + a bounded model rewrite into `MEMORY.md`/`USER.md`. Provenance (owner/agent/untrusted/system) is recorded in SQLite columns at write time; cron/heartbeat/subagent sessions can never promote; recalled content is never re-extracted (recall-loop prevention).
- **Recall lane 1 (zero model calls):** bootstrap injection of curated files (refreshes per turn), ranked `memory_search` (hybrid embeddings+keyword, 30-day recency half-life, importance multiplier), trigger-phrase auto-injection (max 3/turn, curated tier only). **Lane 2:** escalation sub-agent for temporal/multi-hop recall.
- **User model:** `USER.md` dated imperative directives, supersede-in-place.
- **Tools/CLI:** `memory_search`, `memory_get`, `intent`; `openclaw memory status|search|index`. Default backend is SQLite (keyword + vector + hybrid, zero deps).
- Action-sensitive memories capture *when it is safe to act* (approval, expiry, handoff, timing), not just the fact.

### Our baseline

- `memories/current/` (session notes) ≈ episodic; `memories/core/` ≈ curated; `memories/old/` ≈ archive; `INDEX.md` grep index; scripts `new-memory` / `promote-memory` / `search-memory` / `archive`. Global opencode memory plugin (memory_write/memory_recall, grep-based).
- Flow is fully manual: end-of-session note -> occasional promote to core -> archive after 7 days.

### Comparison

| Aspect | OpenClaw | Freyja now | Verdict |
|---|---|---|---|
| No hidden state | Files + SQLite index | Files only | Aligned (simpler) |
| Tier model | Instructions/curated/episodic/prospective/review | current/core/old + templates | Aligned conceptually |
| Curated injection | Always at session start, budgeted, refreshes per turn | Not automatic; agent must remember to read memory | **Gap — startup bootstrap rule** |
| Recall | Hybrid semantic+keyword, recency+importance, trigger injection, escalation lane | Grep `search-memory.ps1` | Grep fine for keywords; semantic = future |
| Write/curation | Append while working + pre-compaction flush + scheduled gated consolidation | Manual write/promote/archive | **Gap — curation unscheduled** |
| User model | USER.md directives, supersede-in-place | Core template directives (Stage 1) | Aligned |
| Prospective memory | Standing intents -> cron/event triggers | None | Out of scope for now |
| Provenance/trust | Origin classes, session-kind gating, anti-poisoning | None | Low risk single-user; optional source field |
| Action-sensitive memory | Timing/authority/expiry guidance | Not in templates | **Candidate — add to templates** |
| Review surface | DREAMS.md + Dreams UI | Promote/archive logs | Minor |

### Upgrade candidates (Stage 2)

Status: **implemented 8/4/2026** (session-start bootstrap rule, action-sensitive template fields, consolidation script built — scheduling deferred per user).

1. **Session-start bootstrap rule** — DONE. `freyja.md` "Your home and memory system" rules now begin with a bootstrap rule: at session start read `INDEX.md`, today's + yesterday's `current/` notes, scan `core/`, and keep it fast (never block real work). Mirrors OpenClaw lane-1 bootstrap injection.
2. **Action-sensitive + provenance fields** — DONE. `core_memory.md`, `project_memory.md`, `task_memory.md` all gained an `## Action context (optional)` section: `Source / Owner`, `Action when`, `Expires`.
3. **Scheduled consolidation** — DONE 8/4/2026. `memories/scripts/consolidate.ps1` runs `archive.ps1` then writes a promotion-candidate report to `memories/reports/promotion-candidates-YYYY-MM-DD.md` (DREAMS.md-style review surface) with copy-paste promote commands. Registered as Task Scheduler task **"Freyja Memory Consolidation"** — weekly Sundays 03:00, run only when user is logged on, `-ArchiveDays 7 -CandidateDays 2`, 15-min execution limit, start-if-missed. Tested on-demand (LastTaskResult 0, report generated). Uses the WindowsApps `pwsh.exe` package path because Task Scheduler can't reliably launch app-execution aliases.
4. **Defer semantic search** — CONFIRMED. Grep stays; embeddings only if recall degrades.

Notes: `memories/` remains gitignored/local-only, so templates + consolidate.ps1 are not committed (by design); `freyja.md` lives outside the repo. Only `oc-upgrades.md` is committed for this stage.

*Next: Stage 3 — Gateway & sessions (pending Stage 2 implementation).*
