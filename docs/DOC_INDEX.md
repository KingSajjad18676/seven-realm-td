# Shahnameh TD — Documentation Index

**Last updated:** 2026-06-04

Start with **[README_00_MASTER_PROJECT_INDEX.md](README_00_MASTER_PROJECT_INDEX.md)** for identity and locked decisions.

---

## Design canon (from PDFs)

| Doc | Purpose |
|-----|---------|
| [README_00_MASTER_PROJECT_INDEX.md](README_00_MASTER_PROJECT_INDEX.md) | Project promise, loop, Khan 1 target, locked decisions, work order |
| [README_01_PHASE_BASED_ASSET_GENERATION.md](README_01_PHASE_BASED_ASSET_GENERATION.md) | Modular art prompts, phases 0–7, asset IDs, QA |
| [README_02_GAMEPLAY_VISUAL_UX_REPLAYABILITY.md](README_02_GAMEPLAY_VISUAL_UX_REPLAYABILITY.md) | Combat, maps, towers, bosses, UI, replayability |
| [README_03_ETHICAL_MONETIZATION_BUSINESS.md](README_03_ETHICAL_MONETIZATION_BUSINESS.md) | Fair monetization, store, business stages |
| [README_04_DEVELOPMENT_PRODUCTION_ROADMAP.md](README_04_DEVELOPMENT_PRODUCTION_ROADMAP.md) | Godot milestones M0–M8, data model, QA |
| [README_05_LAUNCH_LIVEOPS_COMMUNITY.md](README_05_LAUNCH_LIVEOPS_COMMUNITY.md) | Launch, events, community, post-release ops |

**PDF sources (repo root):** `Shahnameh TD README.pdf`, `Shahnameh TD Gameplay Design.pdf`, `SHAHNAMEH TD - Ethical Monetization and Business Roadmap.pdf`  
**Text extracts:** [docs/_source/](_source/)

---

## Implementation truth (Godot)

| Doc | Purpose |
|-----|---------|
| [GODOT_PORT_STATUS.md](GODOT_PORT_STATUS.md) | What is playable in Godot today; port gaps |
| [IMPLEMENTATION_STATUS.md](IMPLEMENTATION_STATUS.md) | Feature-level status (design target vs built) |
| [GODOT_ARCHITECTURE.md](GODOT_ARCHITECTURE.md) | Folders, autoloads, battle wiring |

---

## Onboarding and specs

| Doc | Purpose |
|-----|---------|
| [GAME_HANDOFF.md](GAME_HANDOFF.md) | **Best onboarding** — flow + code map for collaborators |
| [GAMEPLAY_SPEC.md](GAMEPLAY_SPEC.md) | Detailed mechanics (includes advanced/post-launch systems) |
| [GAME_LOGIC_AND_ESSENTIALS.md](GAME_LOGIC_AND_ESSENTIALS.md) | Architecture, state machine, code pointers |
| [PRD.md](PRD.md) | Product requirements summary |
| [TECHNICAL_DESIGN.md](TECHNICAL_DESIGN.md) | Scenes, managers, services |
| [DEVELOPMENT_ROADMAP.md](DEVELOPMENT_ROADMAP.md) | Milestone-aligned roadmap (links README_04) |

---

## Art and UX

| Doc | Purpose |
|-----|---------|
| [ASSET_PIPELINE.md](ASSET_PIPELINE.md) | Import rules, modular prompts (operational) |
| [VISUAL_AND_VFX_SPEC.md](VISUAL_AND_VFX_SPEC.md) | Readability checklist for deep systems |
| [GAMEPLAY_AND_ASSET_REQUIREMENTS.md](GAMEPLAY_AND_ASSET_REQUIREMENTS.md) | Player-facing overview + asset gaps |

---

## Live-ops and archive

| Doc | Purpose |
|-----|---------|
| [LIVEOPS_AND_RETENTION.md](LIVEOPS_AND_RETENTION.md) | Daily/weekly/events/shops (aligned to README_03/05) |
| [UNITY_ARCHITECTURE.md](UNITY_ARCHITECTURE.md) | **Archived** Unity reference only |
| [UNITY_SETUP.md](UNITY_SETUP.md) | **Archived** Unity setup only |
| [CODE_REVIEW.md](CODE_REVIEW.md) | Review notes |

---

## Recommended reading order

1. README_00 → README_02 (if building gameplay)  
2. GODOT_PORT_STATUS + GAME_HANDOFF (if coding)  
3. README_01 + VISUAL_AND_VFX_SPEC (if art)  
4. README_03 + README_05 (if monetization/live-ops)  
5. README_04 + GODOT_ARCHITECTURE (if engineering/release)
