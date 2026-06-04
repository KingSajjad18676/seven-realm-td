# Product Requirements Document — Shahnameh Mobile Landscape TD

**Last updated:** 2026-06-04  
**Design canon:** [design/00-project-index.md](../design/00-project-index.md) · [design/02-gameplay-ux.md](../design/02-gameplay-ux.md)  
**Monetization canon:** [design/03-monetization.md](../design/03-monetization.md)  
**Implementation truth:** [engineering/project-status.md](../engineering/project-status.md) · [engineering/implementation-tracker.md](../engineering/implementation-tracker.md)

## 1. Product Summary

A mobile landscape 2D **active tower-defense roguelite** inspired by the Shahnameh, Persian mythology, Zoroastrian fire symbolism, and Persian miniature manuscript art.

**Engine:** Godot 4.6 (repository root, `project.godot`)

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

Deep systems in code (tether, Forge, rewind, finale) are documented in [spec/gameplay.md](../spec/gameplay.md). Art readability: [art/visual-vfx.md](../art/visual-vfx.md) · [design/01](../design/01-art-phases.md).

## 4. MVP Scope (technical proof)

Per [design/04](../design/04-production-roadmap.md) **Milestone M0–M1**:

- landscape battle scene with one graybox route
- tower placement, waves, gate/lives, one hero, Gold
- touch input and stable frame rate on target devices

## 5. Vertical Slice Scope (Khan 1 — first production target)

Per [design/00](../design/00-project-index.md) — **do not expand campaign art until voluntary Khan 1 replay is proven:**

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

**Campaign:** Seven Khans + **Damavand Binding** (8 maps, scaling grids per [design/02](../design/02-gameplay-ux.md)).

**Heroes (staggered):** Rostam first; then Zal, Gordafarid, Esfandiyar, Sohrab, Kaveh, Simorgh as identities are proven.

**Modes:** Campaign, Hunt for Zahhak, Endless, Daily Tale, roguelite routes.

**Meta:** Relics, collections, Farr mastery, optional objectives, Forge hybrids.

**Monetization (launch):** Cosmetics, Founder’s Supporter Pack, ad removal, limited optional rewarded ads — see [design/03](../design/03-monetization.md). **Not launch:** battle pass, paid combat power, premium overpowered heroes.

**Live-ops:** Small sustainable events per [design/05](../design/05-launch-liveops.md).

## 7. Success Criteria

**Khan 1 vertical slice (primary):**

- Tester answers design/00 success questions (towers, path, Rostam, Sacred Fire, corruption, hijack, win/loss reason)
- **Voluntary replay** after win or fail without prompting

**Prototype (M0–M1):**

- Battle playable start to win/loss; towers target correctly; waves path reliably; hero moves and uses ability

**Soft launch:**

- Tutorial and Khan 1 funnel measurable
- Replay after win/defeat tracked
- Store clarity and fairness metrics (design/03)
- No requirement for battle-pass engagement at launch
