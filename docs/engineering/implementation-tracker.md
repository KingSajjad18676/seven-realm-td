# Implementation Tracker

**Last updated:** 2026-06-04  
**Repo truth:** [project-status.md](project-status.md)  
**Design canon:** [design/00-project-index.md](../design/00-project-index.md) through [design/05](../design/05-launch-liveops.md)  
**Onboarding:** [handoff.md](handoff.md) · [game-logic.md](game-logic.md)

---

## How to read this doc

| Label | Meaning |
|-------|---------|
| **Built** | Present and testable in the current repo |
| **Target** | Specified in design canon; not in repo yet |
| **Deferred** | Intentionally after Khan 1 or soft launch |

**Current repo:** scaffold only — almost all rows below are **Target** until [project-status.md](project-status.md) says otherwise.

---

## Core loop (Khan 1)

| Feature | Built | Target reference |
|---------|-------|------------------|
| Boot → menu → world map → battle | ❌ | [handoff.md](handoff.md) §2 |
| Tower place / upgrade / sell | ❌ | [design/02-gameplay-ux.md](../design/02-gameplay-ux.md) |
| Waves + spawner + win/loss | ❌ | [spec/gameplay.md](../spec/gameplay.md) |
| Hero move + skill (Rostam) | ❌ | [design/02-gameplay-ux.md](../design/02-gameplay-ux.md) |
| Battle gold + lives | ❌ | [game-logic.md](game-logic.md) |
| 5 waves + Lion boss | ❌ | [design/00-project-index.md](../design/00-project-index.md) §3 |
| Voluntary replay | ❌ | Khan 1 exit gate |

---

## Signature systems (identity)

| System | Built | Notes |
|--------|-------|-------|
| Regional light + corruption | ❌ Target | MapLightManager pattern in [technical-design.md](technical-design.md) |
| Sacred Fire currency + cleanse | ❌ Target | |
| Tower hijack at light 0 | ❌ Target | |
| Sacred Tether (hero ↔ tower) | ❌ Target | |
| Morale meter | ❌ Target | |
| Pardeh Break / Fate draft | ❌ Target | M5 |
| Ancestral Forge hybrids | ❌ Target | Needs combo `.tres` |

---

## Content (design targets)

| Category | Target count (canon) | In repo |
|----------|----------------------|---------|
| Campaign maps | 8 (Seven Khans + Damavand) | 0 `.tres` |
| Starter towers | Archer, Sacred Fire, Heavy, Control | 0 |
| Heroes (slice) | Rostam (+ Zal later) | 0 |
| Enemy types (slice) | grunt, runner, brute, corruptor, boss | 0 |

Full mechanical detail: [spec/gameplay.md](../spec/gameplay.md). Asset gaps: [art/content-checklist.md](../art/content-checklist.md).

---

## Meta and live-ops

| Feature | Built | Launch note |
|---------|-------|-------------|
| Save / campaign progress | ❌ Target | JSON at `user://` per [technical-design.md](technical-design.md) |
| Roguelite map | ❌ Target | M5 |
| Daily challenge / bazaar | ❌ Target | Post–Khan 1 |
| IAP / subscriptions | ❌ Deferred | Stubs only; see [design/03-monetization.md](../design/03-monetization.md) |
| Hunt / Damavand finale | ❌ Target | Post–campaign slice |

---

## Deep / endgame modules (post–vertical slice)

Planned in design docs; **not** required for Khan 1. Track here when implementing:

| Module | Priority |
|--------|----------|
| Zervan Dial rewind | After M2 teachability |
| Khan escalation / Ahriman director | Boss maps |
| Star Iron / Damavand chains | Hunt arc |
| Nemesis / Zahhak Fury | Endgame |

Historical feature-level tables were removed to avoid implying shipped code. Re-expand this file section-by-section as `scripts/` lands.

---

## Test checklist (when M1 exists)

1. Godot **F5** from `scenes/boot/boot.tscn`.
2. Campaign → Khan 1 → place tower → start wave.
3. Corruption darkens a region → cleanse → hijack recovery.
4. Clear 5 waves → defeat Lion → **replay** without prompt.

---

## Maintenance

- After each milestone: update [project-status.md](project-status.md), then flip rows here from ❌ to ✅.
- Link new mechanics in [spec/gameplay.md](../spec/gameplay.md) if behavior changes.
