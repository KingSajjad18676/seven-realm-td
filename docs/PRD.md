# Product Requirements Document — Shahnameh Mobile Landscape TD

**Last updated:** 2026-06-04  
**Design canon:** [README_00_MASTER_PROJECT_INDEX.md](README_00_MASTER_PROJECT_INDEX.md) · [README_02_GAMEPLAY_VISUAL_UX_REPLAYABILITY.md](README_02_GAMEPLAY_VISUAL_UX_REPLAYABILITY.md)  
**Monetization canon:** [README_03_ETHICAL_MONETIZATION_BUSINESS.md](README_03_ETHICAL_MONETIZATION_BUSINESS.md)  
**Implementation truth:** [GODOT_PORT_STATUS.md](GODOT_PORT_STATUS.md) · [IMPLEMENTATION_STATUS.md](IMPLEMENTATION_STATUS.md)

## 1. Product Summary

A mobile landscape 2D **active tower-defense roguelite** inspired by the Shahnameh, Persian mythology, Zoroastrian fire symbolism, and Persian miniature manuscript art.

**Engine:** Godot 4.6 (`shahname-td-godot/shahname-td/`)

The game combines:

- tactical tower defense with an active hero
- regional Sacred Fire vs corruption (including tower hijacking)
- Seven Khans campaign + Damavand Binding finale (8 battlefields)
- Pardeh Breaks, Fate cards, relics, and roguelite replay modes
- fair cosmetics-first monetization (no pay-to-win at launch)

## 2. Target Audience

**Primary:** mobile strategy players, TD fans, players who want unique mythology and hand-painted art.

**Secondary:** roguelite fans, completionists, daily-challenge players.

## 3. Core Promise

Hold back corruption with **Sacred Fire** while Shahnameh heroes and mythic towers defend a battlefield that can **fight back** — hijacking your towers — across runs shaped by **double-edged Fates**.

| Pillar | Role |
|--------|------|
| **Sacred Fire vs Corruption** | Flagship territory tug-of-war |
| **Fate Weaving** | Roguelite spine — boon + curse modifiers |
| **Morale** | Supporting momentum meter |

Deep systems in code (tether, Forge, rewind, finale) are documented in [GAMEPLAY_SPEC.md](GAMEPLAY_SPEC.md). Art readability: [VISUAL_AND_VFX_SPEC.md](VISUAL_AND_VFX_SPEC.md) · [README_01](README_01_PHASE_BASED_ASSET_GENERATION.md).

## 4. MVP Scope (technical proof)

Per [README_04](README_04_DEVELOPMENT_PRODUCTION_ROADMAP.md) **Milestone M0–M1**:

- landscape battle scene with one graybox route
- tower placement, waves, gate/lives, one hero, Gold
- touch input and stable frame rate on target devices

## 5. Vertical Slice Scope (Khan 1 — first production target)

Per [README_00](README_00_MASTER_PROJECT_INDEX.md) — **do not expand campaign art until voluntary Khan 1 replay is proven:**

| Include | Notes |
|---------|--------|
| Map `map_khan_01_lion_rakhsh` (32×18) | Medium woodland battlefield |
| Rostam + Rakhsh moment | Starting hero |
| Four towers | Archer, Sacred Fire, Heavy, Control |
| Enemies | Corrupted jackal, corrupted boar |
| Boss | Lion of the First Khan |
| Resources | Gold, Lives, Sacred Fire |
| Systems | Corruption states, hijack/recovery, 5 waves, one Pardeh Break, small Fate pool |
| UX | One-tap replay, clear defeat explanation, analytics stub |

**Not required for Khan 1 gate:** full roguelite map, battle pass, subscription economy, seven polished maps, Hunt/Endless/Daily Tale at launch quality.

## 6. Full Launch Feature Set (target)

**Campaign:** Seven Khans + **Damavand Binding** (8 maps, scaling grids per [README_02](README_02_GAMEPLAY_VISUAL_UX_REPLAYABILITY.md)).

**Heroes (staggered):** Rostam first; then Zal, Gordafarid, Esfandiyar, Sohrab, Kaveh, Simorgh as identities are proven.

**Modes:** Campaign, Hunt for Zahhak, Endless, Daily Tale, roguelite routes.

**Meta:** Relics, collections, Farr mastery, optional objectives, Forge hybrids.

**Monetization (launch):** Cosmetics, Founder’s Supporter Pack, ad removal, limited optional rewarded ads — see [README_03](README_03_ETHICAL_MONETIZATION_BUSINESS.md). **Not launch:** battle pass, paid combat power, premium overpowered heroes.

**Live-ops:** Small sustainable events per [README_05](README_05_LAUNCH_LIVEOPS_COMMUNITY.md).

## 7. Success Criteria

**Khan 1 vertical slice (primary):**

- Tester answers README_00 success questions (towers, path, Rostam, Sacred Fire, corruption, hijack, win/loss reason)
- **Voluntary replay** after win or fail without prompting

**Prototype (M0–M1):**

- Battle playable start to win/loss; towers target correctly; waves path reliably; hero moves and uses ability

**Soft launch:**

- Tutorial and Khan 1 funnel measurable
- Replay after win/defeat tracked
- Store clarity and fairness metrics (README_03)
- No requirement for battle-pass engagement at launch
