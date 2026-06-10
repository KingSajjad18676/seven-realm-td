# Product Requirements Document — Shahnameh Mobile Landscape TD

**Last updated:** 2026-06-09  
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

**Not required for Khan 1 gate:** production art on maps 2–8, platform IAP SDK, battle pass — logic for many modes is already coded (see §5b).

## 5b. Built beyond Khan 1 gate (repo today)

Per [implementation-tracker.md](../engineering/implementation-tracker.md) — coded and playable, art polish deferred:

| Area | Built |
|------|-------|
| **Campaign** | Tutorial + Labours 1–7 + Damavand; procedural 30–100 waves; 8 Labour modes |
| **Modes** | Campaign Run, Horde, Endless, Hunt, Daily Tale, Brothers in Arms, Defend the Throne, Haft-Khan Gauntlet |
| **Content** | 8 towers, 3 heroes, 22 enemies, 8 Fate cards, 6 spells, 7 relics, 28 equipment pieces |
| **Meta** | Kaveh's Forge, equipment sets, daily missions, relic slots, stub IAP store |
| **Signature** | Corruption/hijack, Pardeh, Morale, Vow, Resonance, scavenging, Naft traps |
| **Tests** | GUT + ContentValidator + CI |

**Full inventory:** [main-gameplay.md](main-gameplay.md) · [entities-and-gameplay.md](../spec/entities-and-gameplay.md)

## 6. Full Launch Feature Set (target vs built)

| Target | Status |
|--------|--------|
| Campaign 8 maps | ✅ Logic; 🟡 Art (Khan 1 map only) |
| Heroes Rostam + Zal + Sohrab | ✅ Rostam/Zal/Sohrab (co-op) |
| Modes: Campaign, Hunt, Endless, Daily, roguelite | ✅ + Horde, Gauntlet, co-op, Throne |
| Meta: Relics, objectives, Forge | ✅ + equipment, daily missions |
| Forge hybrids, 43 Fate cards, premium heroes | ❌ Deferred |
| Farr mastery, collections | ❌ Design target |

**Monetization (launch):** Cosmetics, Founder’s Supporter Pack, ad removal, see [design/03](../design/03-monetization.md). Stub tower/spell IAP exists for testing.

**Live-ops:** Daily Missions + Daily Tale built; broader events per [design/05](../design/05-launch-liveops.md).

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
