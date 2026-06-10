# Rostam 7 Labours: Shahname TD — Documentation

**Last updated:** 2026-06-09  
**Repo:** Godot 4.6 at repository root (`project.godot`)

**One-line pitch:** Active 2D tower-defense roguelite — build towers, move Rostam, cleanse corruption, survive procedural **Labours** campaign, **Campaign Run** roguelite graph, Horde, co-op, **Haft-Khan Gauntlet**, equipment sets, and daily missions — unlock reward towers (Serpent Spire, Rostam Barracks).

**Full game inventory (player-facing):** [product/main-gameplay.md](product/main-gameplay.md) · **All content IDs:** [spec/entities-and-gameplay.md](spec/entities-and-gameplay.md)

Start with **[design/00-project-index.md](design/00-project-index.md)** for product identity and locked decisions.  
For **what exists in the repo today**, read **[engineering/project-status.md](engineering/project-status.md)** first.

---

## Design canon (from PDFs)

| Doc | Purpose |
|-----|---------|
| [design/00-project-index.md](design/00-project-index.md) | Promise, loop, Khan 1 gate, locked decisions |
| [design/01-art-phases.md](design/01-art-phases.md) | Modular art prompts, phases 0–7 |
| [design/02-gameplay-ux.md](design/02-gameplay-ux.md) | Combat, maps, towers, bosses, UI, replay |
| [design/03-monetization.md](design/03-monetization.md) | Fair monetization and business stages |
| [design/04-production-roadmap.md](design/04-production-roadmap.md) | Milestones M0–M8, data model, QA |
| [design/05-launch-liveops.md](design/05-launch-liveops.md) | Launch, community, post-release ops |

**PDF sources (repo root):** `Shahnameh TD README.pdf`, `Shahnameh TD Gameplay Design.pdf`, `SHAHNAMEH TD - Ethical Monetization and Business Roadmap.pdf`  
**Text extracts:** [_source/](_source/)

---

## Engineering (Godot)

| Doc | Purpose |
|-----|---------|
| [engineering/project-status.md](engineering/project-status.md) | **Truth for the repo** — what runs today |
| [engineering/implementation-tracker.md](engineering/implementation-tracker.md) | Design target vs built (feature tables) |
| [engineering/handoff.md](engineering/handoff.md) | Onboarding: flow + target code map |
| [engineering/architecture.md](engineering/architecture.md) | Folders, autoloads, battle wiring |
| [engineering/technical-design.md](engineering/technical-design.md) | Scenes, managers, services |
| [engineering/game-logic.md](engineering/game-logic.md) | State machine, ownership, pointers |

---

## Product and spec

| Doc | Purpose |
|-----|---------|
| [product/main-gameplay.md](product/main-gameplay.md) | **Main gameplay** — maps, modes, Labour hazards, unlocks |
| [product/prd.md](product/prd.md) | Product requirements summary |
| [product/roadmap.md](product/roadmap.md) | Milestone backlog and release bundles |
| [spec/entities-and-gameplay.md](spec/entities-and-gameplay.md) | All towers & maps (every phase) + built entities + assets needed |
| [spec/gameplay.md](spec/gameplay.md) | Full mechanics spec (incl. post-launch) |

---

## Art and live-ops

| Doc | Purpose |
|-----|---------|
| [spec/entities-and-gameplay.md](spec/entities-and-gameplay.md) | **All towers & maps (every phase)** + built entities + assets needed |
| [prompts/README.md](../prompts/README.md) | **AI sprite prompts** — phase 0–7, chroma green review |
| [art/pipeline.md](art/pipeline.md) | Import rules and AI sprite workflow |
| [art/visual-vfx.md](art/visual-vfx.md) | Readability checklist for signature systems |
| [art/content-checklist.md](art/content-checklist.md) | Player-facing flow + asset gaps |
| [liveops/retention.md](liveops/retention.md) | Daily/weekly/events/shops |

---

## Reading order

| Role | Path |
|------|------|
| Anyone new | `design/00` → `engineering/project-status` → `product/main-gameplay` |
| **What the game has today** | `product/main-gameplay` + `spec/entities-and-gameplay` + `engineering/implementation-tracker` |
| Gameplay / design | `product/main-gameplay` → `design/02` → `spec/entities-and-gameplay` → `spec/gameplay` |
| Programmer | `engineering/architecture` → `engineering/game-logic` → `design/04` |
| Artist | `design/01` → `prompts/README` → `spec/entities-and-gameplay` → `art/pipeline` → `art/visual-vfx` |
| Monetization / ops | `design/03` → `design/05` → `liveops/retention` |

---

## Naming convention

| Folder | Use |
|--------|-----|
| `design/` | Locked product canon (numbered 00–05) |
| `engineering/` | Godot implementation and status |
| `product/` | PRD and planning summaries |
| `spec/` | Detailed gameplay specification |
| `art/` | Asset pipeline and checklists |
| `liveops/` | Retention and events |
| `_source/` | PDF text extracts (reference only) |

**Renamed from older files?** See [RENAME_MAP.md](RENAME_MAP.md).

**Cursor rules:** `.cursor/rules/` — `always-*`, `code-*`, `art-pipeline`, `liveops-economy`, `docs-editing` ([RULES_MAP.md](../.cursor/rules/RULES_MAP.md))
