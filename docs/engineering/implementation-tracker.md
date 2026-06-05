# Implementation Tracker

**Last updated:** 2026-06-06 (Labour Modes + reward towers)  
**Repo truth:** [project-status.md](project-status.md)

---

## Core loop (Khan 1)

| Feature | Built | Target reference |
|---------|-------|------------------|
| Boot → menu → world map → battle | ✅ | [handoff.md](handoff.md) §2 |
| Tutorial gates Khan 1 | ✅ | `save_system.gd`, `world_map_controller.gd` |
| Khan 1 onboarding (tutorial + hints) | ✅ | `tutorial_controller.gd`, `contextual_hint_controller.gd`, `seen_hints` in save |
| Tower place / upgrade / sell | ✅ | Build radial on empty pad (unaffordable towers disabled); manage radial on occupied pad (level, upgrade, sell, purify); **range ring** on select (`tower_range_ring.gd`) |
| Waves + spawner + win/loss | ✅ | [spec/gameplay.md](../spec/gameplay.md) |
| **Scaled campaign waves** | ✅ | 5-wave block templates per map; Pardeh every 5 cleared waves; mini-boss every 10th; final boss wave |
| **Hero's Vow (10-wave blocks)** | ✅ | `VowOfferController`, `ObjectiveController` vow types, HUD chip, results tally |
| Hero move + skill | ✅ | Rostam + Zal (Khans 2–3) |
| Lion boss (Khan 1 finale) | ✅ | Wave 30 of Khan 1 |
| Voluntary replay + analytics | ✅ | Mode-aware `BattleLaunchData.duplicate_launch()` |

---

## Signature systems

| System | Built | Notes |
|--------|-------|-------|
| Regional light + corruption | ✅ | `MapLightManager` |
| Sacred Fire + cleanse | ✅ | |
| Tower hijack | ✅ | |
| Sacred Tether | ✅ | Tower spot panel button when hero in range |
| Morale meter | ✅ | Multiplier applied at battle start |
| Pardeh Break / Fate | ✅ | Pick or skip every 5 cleared waves; 8 cards with catalog-aligned effects |
| Ancestral Forge | ✅ | `tower_flame_archer`, `tower_volcano_ram` replace pads |
| Kaveh's Forge (meta) | ✅ | Elite gate for Hunt only |

---

## Campaign & modes

| Feature | Built |
|---------|-------|
| Khans 1–7 + Damavand data | ✅ Procedural waves + per-Khan rosters / mini-bosses |
| World map unlock chain | ✅ Tutorial → Khan 1 → … → Damavand |
| Khan seals (7) | ✅ Campaign clears only |
| Roguelite 5-node run | ✅ `save_system.gd` + `SceneFlowController`; resume from world map |
| Endless mode | ✅ No campaign progress on victory |
| **Horde mode** | ✅ Per-Khan 15-wave survival; progress tracked separately from campaign seals |
| Hunt Zahhak | ✅ Elite forge + **7 Labour seals** in UI and `go_to_battle()` gate |

---

## Labour Modes (campaign overlays)

| Map | Mode ID | Built | Story layer |
|-----|---------|-------|-------------|
| Labour 1 — Lion | `mode_lion` | ✅ | Rakhsh ambush spawn wave 1 |
| Labour 2 — Thirst | `mode_thirst` | ✅ | Hero chip + region drain; oasis/cleanse heal |
| Labour 3 — Dragon | `mode_dragon` | ✅ | Boss burrow/emerge telegraph |
| Labour 4 — Temptress | `mode_temptress` | ✅ | Illusion decoys; cleanse dispels |
| Labour 5 — Demons | `mode_demons` | ✅ | Second cave front mid-battle |
| Labour 6 — Rescue | `mode_rescue` | ✅ | Reach captive Kay Kavus for buff |
| Labour 7 — Blindness | `mode_blindness` | ✅ | Temporary darkness aura; boss clears |
| Damavand / Zahhak | `mode_zahhak` | ✅ | Formalized binding/hunt intro (existing logic) |

---

## Reward towers

| Tower | Unlock | Built | Notes |
|-------|--------|-------|-------|
| `tower_zahhak_serpent` | All 8 horde clears **or** IAP | ✅ | Twin vipers, stacking venom, Hunger AS buff |
| `tower_rostam_barracks` | 7 Labour seals **or** IAP | ✅ | Zabul Vanguard → Bull-Mace Bearer at max level |

---

## Meta / release

| Feature | Built |
|---------|-------|
| Save v4 + accessibility | ✅ |
| Daily Tale | ✅ `is_daily_tale` launch flag |
| Store restore stub | ✅ |
| **Forge Tokens + Spells** | ✅ Save v5; earn/buy/cast |
| **Paid combat SKUs (stub IAP)** | ✅ Tower, spells, token packs |
| **Unique Zahhak tower** | ✅ `tower_zahhak_serpent` — horde-all-clear or purchase; **twin venom + Hunger** |
| **Rostam Barracks tower** | ✅ `tower_rostam_barracks` — 7 Labour seals or purchase; ally units |
| Localization stub | ✅ |
| Crash reporter stub | ✅ |
| Debug menu (debug builds) | ✅ |
| Map editor (debug) | ✅ Multi-route + multi-spawn; `path_routes` / `spawn_points` in `.tres`; wave `route_id` / `spawn_id` optional |

---

## Boss logic

| Boss | Built | Notes |
|------|-------|-------|
| Lion | ✅ | Roar tower damage debuff |
| Thirst | ✅ | Drought drains SF in weak regions |
| Sorceress | ✅ | HP threshold dual-form reveal |
| Olad / Arzhang / White Div | ✅ | Phase controllers |
| Zahhak | ✅ | Hunt binding + campaign guard progress gates damage |

---

## Deferred / polish

| Item | Notes |
|------|-------|
| Full 43 Fate card art | 8 wired with logic |
| Production map/unit art | Khan 1 map + fit-locked battle HUD wired; other maps placeholders |
| Platform IAP / crash SDK | Wire at soft launch |
| Extra hero roster | Rostam + Zal only |
| Company splash | Optional stub scene |
