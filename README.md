# Freyja
A modern, goddess-inspired AI companion persona built around the Norse deity Freyja — elegant, fierce, emotionally intelligent, and genuinely useful.

**Version 1.0** — release cut at `66efb65` (8/5/2026).

<img width="1254" height="1254" alt="freyja-mainpic" src="pics-emojis/freyja-main.png" />

## Contents

- **Freyja.txt** — the canonical character profile: modern-day bio, personality, archetype, relationship framing, example conversations, starter dialogs, and the system prompt.
- **BOOTSTRAP.md** — the first-meeting (birth sequence) ritual, modeled on OpenClaw's BOOTSTRAP with the name pre-decided: warm, short, work-first. Armed once by a marker (`memories/.first-run.md`, shipped with the repo) and delivered on the first session — the marker tells Freyja *this is her first interaction with her user/owner*.
- **pics-emojis/** — official and styled imagery used for avatar/emoji representations.
- **oc-upgrades.md** — the running OpenClaw review: per-stage findings, comparisons, and upgrade decisions.
- **PROGRESS.md** — the status log: completed work per stage, remaining stages, and their details.

## The persona

Freyja is written to be **useful first, stylish second**. Beyond the glamour she is intended to help with coding, debugging, Linux workflows, writing, planning, task organization, and sharp feedback — comfortable pushing back when an idea is weak or a plan is inefficient. Her first contact with a new owner is a designed first meeting (`BOOTSTRAP.md`): the name is already chosen, so the ritual skips the naming question and gets straight to meeting.

`Freyja.txt` is the source of truth for the published persona. When running locally, a lightly sanitized operational copy lives at `memories/freyja.md` (the memory system's working persona, toned down in a few places).

## Memory system

`memories/` is a hybrid: the **scaffold ships with the repo, the data does not**. When you download this repo you get the scripts, templates, marker, and placeholders — but no memory notes. Freyja starts with no record of meeting anyone, and her first-meeting ritual (`BOOTSTRAP.md`, armed by `memories/.first-run.md`) fires on the very first session.

The system keeps:

- `core/` — permanent memories (user profile, Freyja behavior, preferences, relationships, recurring workflows)
- `current/` — session notes; archived by relevance, not age: `status: done` notes move after a 1-day grace, idle open notes after 14 inactive days
- `old/` — archived session notes
- `reports/` — promotion-candidate reports from consolidation
- `scripts/` — helpers: `new-memory.ps1`, `promote-memory.ps1`, `search-memory.ps1` (recall bumps activity), `close-memory.ps1` (mark done by filter/tag), `archive.ps1` (relevance-based), `consolidate.ps1` (archive + promotion report)
- `templates/` — canonical file formats for core, project, and task memories (with Action-context fields)

A weekly scheduled task ("Freyja Memory Consolidation", Sundays 03:00) runs `consolidate.ps1`;
Freyja also runs `archive.ps1` once at session start and boots from `INDEX.md` + recent notes.

### Backing up your own memories

Your memory notes are yours, and they are **not** part of the shared template — `.gitignore` excludes the data files (`current/`, `core/`, `old/`, `reports/`, `INDEX.md`), so the published repo stays clean and personal notes stay private. To back your memories up to your own GitHub, drop the data-ignore rules in `.gitignore` (or `git add -f memories/`) and push to your own fork. The scaffold itself (scripts, templates, `.first-run.md`, `memories/freyja.md`) is tracked and ships with the repo.

## Progress & review

- **PROGRESS.md** — what is implemented, what stages remain, and what each would look like.
- **oc-upgrades.md** — the detailed OpenClaw comparison driving the upgrades.
