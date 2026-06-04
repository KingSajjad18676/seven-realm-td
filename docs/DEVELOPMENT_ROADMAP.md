# Development Roadmap

**Last updated:** 2026-06-04  
**Design canon:** [README_04_DEVELOPMENT_PRODUCTION_ROADMAP.md](README_04_DEVELOPMENT_PRODUCTION_ROADMAP.md) · [README_00_MASTER_PROJECT_INDEX.md](README_00_MASTER_PROJECT_INDEX.md)  
**Status:** [IMPLEMENTATION_STATUS.md](IMPLEMENTATION_STATUS.md) · [GODOT_PORT_STATUS.md](GODOT_PORT_STATUS.md)  
**Active engine:** Godot 4.6 — `shahname-td-godot/shahname-td/`

Unity phases below are **historical** (archived in `_archive/unity/`). Current planning uses **Milestones M0–M8** from README_04.

---

## Godot milestones (current plan)

| Milestone | Focus | Exit gate (summary) |
|-----------|--------|---------------------|
| **M0** | Technical proof — viewport, touch, graybox route, one enemy/tower/projectile/gate | Reliable touch; stable mid-range Android |
| **M1** | Khan 1 graybox — 32×18, Rostam, four tower behaviors, jackal/boar, 5 waves | Full battle without final art; one-tap replay |
| **M2** | Signature systems — regional light, corruption, Sacred Fire, hijack, alerts | Corruption seen before collapse; fair hijack recovery |
| **M3** | Lion boss — arena, telegraphs, defeat clarity | Boss changes player behavior |
| **M4** | Visual vertical slice — Phase 0/1 assets integrated | Art improves clarity; stable FPS |
| **M5** | Roguelite foundation — Pardeh Break, Fate draft, objectives/relic prototype | Replay feels tactically different |
| **M6** | Content pipeline — registry, validators, save versioning | Add enemy without rewriting battle core |
| **M7** | Campaign expansion — Khan 2→7→Damavand | Per-map tactical lesson + performance |
| **M8** | Release — Hunt, Endless, Daily Tale, store, privacy, soft launch | Release checklist |

**Stop rule before M7:** voluntary Khan 1 replay (README_00).

---

## Release scope bundles

| Bundle | Contents |
|--------|----------|
| **MVP / M1** | Khan 1 gameplay loop (see [PRD.md](PRD.md) §5) |
| **Replayable alpha** | Khan 2–3, second hero, routes, relics, Forge prototype, save, accessibility |
| **Campaign beta** | Maps 4–7, bosses, collections, meta, localization, QA |
| **Release candidate** | Damavand Binding, Hunt, Endless, Daily Tale, cosmetics catalog, purchase restore, crash reporting |

---

## First priority backlog (build first)

Project skeleton, data registry, Khan 1 graybox, tower placement, pathfinding, waves, gate, Rostam, Gold, Sacred Fire, corruption, hijack recovery, Lion boss, Pardeh Break, replay, analytics stub, performance overlay, **device testing on real phones**.

**Build later:** remaining maps, large collection UI, Hunt/Endless/Daily Tale polish, cosmetics live-ops, authored expansion.

---

## Current focus (Godot port)

1. **M1–M2** — Khan 1 loop + corruption/hijack clarity on device  
2. **M3–M4** — Lion boss + README_01 Phase 0/1 art integration  
3. **M5** — Pardeh Break + Fate draft wired to design ([README_02](README_02_GAMEPLAY_VISUAL_UX_REPLAYABILITY.md))  

Signature identity code exists from Unity port; validate behavior in Godot before new content. Art checklist: [VISUAL_AND_VFX_SPEC.md](VISUAL_AND_VFX_SPEC.md).

---

## Historical — Unity phases (archived)

<details>
<summary>Unity Phase 0–8 (reference only)</summary>

Phases 0–5 covered Unity setup, core TD, hero, economy, content slice (3 placeholder towers, 3 levels), and meta stubs. Phase 5.5–5.6 added signature systems and visual slice goals in `Assets/_Project/`. Phases 6–8 planned replay modes, live-ops, and polish.

Implementation preserved under `_archive/unity/` (tag `unity-final-reference`). Do not use Unity menu workflows for active development.

</details>
