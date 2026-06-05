# Implementation Tracker

**Last updated:** 2026-06-05 (game logic audit fixes)  
**Repo truth:** [project-status.md](project-status.md)

---

## Core loop (Khan 1)

| Feature | Built | Target reference |
|---------|-------|------------------|
| Boot → menu → world map → battle | ✅ | [handoff.md](handoff.md) §2 |
| Tutorial gates Khan 1 | ✅ | `save_system.gd`, `world_map_controller.gd` |
| Tower place / upgrade / sell | ✅ | [design/02-gameplay-ux.md](../design/02-gameplay-ux.md) |
| Waves + spawner + win/loss | ✅ | [spec/gameplay.md](../spec/gameplay.md) |
| Hero move + skill | ✅ | Rostam + Zal (Khans 2–3) |
| 5 waves + Lion boss | ✅ | Khan 1 |
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
| Pardeh Break / Fate | ✅ | Pick or skip; 8 cards with catalog-aligned effects |
| Ancestral Forge | ✅ | `tower_flame_archer`, `tower_volcano_ram` replace pads |
| Kaveh's Forge (meta) | ✅ | Elite gate for Hunt only |

---

## Campaign & modes

| Feature | Built |
|---------|-------|
| Khans 1–7 + Damavand data | ✅ Per-Khan enemy IDs + wave tables |
| World map unlock chain | ✅ Tutorial → Khan 1 → … → Damavand |
| Khan seals (7) | ✅ Campaign clears only |
| Roguelite 5-node run | ✅ `save_system.gd` + `SceneFlowController`; resume from world map |
| Endless mode | ✅ No campaign progress on victory |
| Hunt Zahhak | ✅ Elite forge + 7 seals in UI and `go_to_battle()` gate |

---

## Meta / release

| Feature | Built |
|---------|-------|
| Save v4 + accessibility | ✅ |
| Daily Tale | ✅ `is_daily_tale` launch flag |
| Store restore stub | ✅ |
| Localization stub | ✅ |
| Crash reporter stub | ✅ |
| Debug menu (debug builds) | ✅ |

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
| Production map/unit art | Placeholders |
| Platform IAP / crash SDK | Wire at soft launch |
| Extra hero roster | Rostam + Zal only |
| Company splash | Optional stub scene |
