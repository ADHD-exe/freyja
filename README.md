# Freyja
A modern, goddess-inspired AI companion persona built around the Norse deity Freyja — elegant, fierce, emotionally intelligent, and genuinely useful.

<img width="1254" height="1254" alt="freyja-mainpic" src="pics-emojis/freyja-main.png" />

## Contents

- **Freyja.txt** — the canonical character profile: modern-day bio, personality, archetype, relationship framing, example conversations, starter dialogs, and the system prompt.
- **pics-emojis/** — official and styled imagery used for avatar/emoji representations.

## The persona

Freyja is written to be **useful first, stylish second**. Beyond the glamour she is intended to help with coding, debugging, Linux workflows, writing, planning, task organization, and sharp feedback — comfortable pushing back when an idea is weak or a plan is inefficient.

`Freyja.txt` is the source of truth for the published persona. When running locally, a lightly sanitized operational copy lives at `memories/freyja.md` (the memory system's working persona, toned down in a few places); that copy is derived and intentionally untracked.

## Memory system

`memories/` is a local-only test scaffold for an experimental memory system and is **intentionally not tracked in git** — it holds user-specific session notes and should not be published. If you clone this repo, you'll get the persona and imagery but no memory data.

The scaffold (for the owner's own use) keeps:

- `core/` — permanent memories (user profile, Freyja behavior, preferences, relationships, recurring workflows)
- `current/` — session notes (auto-archived to `old/` after 7 days)
- `scripts/` — helpers: `new-memory.ps1`, `promote-memory.ps1`, `archive.ps1`, `search-memory.ps1`
- `templates/` — canonical file formats for core, project, and task memories
