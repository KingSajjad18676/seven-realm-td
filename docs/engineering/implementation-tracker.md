# Implementation Tracker

**Last updated:** 2026-06-04 (full campaign roadmap)  
**Repo truth:** [project-status.md](project-status.md)

---

## Core loop (Khan 1)

| Feature | Built | Target reference |
|---------|-------|------------------|
| Boot → menu → world map → battle | ✅ | [handoff.md](handoff.md) §2 |
| Tutorial mission | ✅ | `level_00_tutorial` |
| Tower place / upgrade / sell | ✅ | [design/02-gameplay-ux.md](../design/02-gameplay-ux.md) |
| Waves + spawner + win/loss | ✅ | [spec/gameplay.md](../spec/gameplay.md) |
| Hero move + skill | ✅ | Rostam + Zal (Khans 2–3) |
| 5 waves + Lion boss | ✅ | Khan 1 |
| Voluntary replay + analytics | ✅ | `replay_stats`, AnalyticsService |

---

## Signature systems

| System | Built | Notes |
|--------|-------|-------|
| Regional light + corruption | ✅ | `MapLightManager` |
| Sacred Fire + cleanse | ✅ | |
| Tower hijack | ✅ | Analytics wired |
| Sacred Tether | ✅ | Tap near tower to tether |
| Morale meter | ✅ | `MoraleController` + HUD |
| Pardeh Break / Fate | ✅ | Reroll, objectives, strategic actions, 8 cards |
| Ancestral Forge | ✅ | Adjacent-pair fuse via battle HUD button |
| Kaveh's Forge (meta) | ✅ | |

---

## Campaign & modes

| Feature | Built |
|---------|-------|
| Khans 1–7 + Damavand data | ✅ `ContentCatalog` |
| World map unlock chain | ✅ `SaveSystem.unlock_levels_after_clear` |
| Khan seals (7) | ✅ |
| Roguelite 3-node map | ✅ |
| Endless mode | ✅ |
| Hunt Zahhak launch | ✅ (Damavand + elite gate) |

---

## Meta / release

| Feature | Built |
|---------|-------|
| Save v3 + accessibility | ✅ |
| Daily Tale stub | ✅ |
| Store restore stub | ✅ |
| Localization stub | ✅ |
| Crash reporter stub | ✅ |
| Debug menu (debug builds) | ✅ |

---

## Campaign depth (roadmap batch)

| Feature | Built | Notes |
|---------|-------|-------|
| Per-Khan wave tables | ✅ | `ContentCatalog` waves 01–08 |
| Per-level default objectives | ✅ | `LevelData.default_objective_id` |
| Boss controllers 2–8 | ✅ | `BossControllerFactory` + per-boss scripts |
| Map terrain tint + sprite path | ✅ | `VisualAssetLoader`, `battle_bootstrap` |
| Path-based region assignment | ✅ | `MapRegionUtils` |
| `.tres` level override | ✅ | `resources/data/levels/level_02.tres` |
| Zal foresight skill | ✅ | `hero_controller.gd` |
| Hunt binding shards | ✅ | `HuntController` |
| Roguelite 5-node run | ✅ | Levels 01–04 variety |
| World map node strip | ✅ | Locked / cleared / seal states |

## Deferred / polish

| Item | Notes |
|------|-------|
| Full 43 Fate card art | Subset in data; expand per playtest |
| Production map/unit art | Placeholders + `generate_map_placeholders.gd` |
| Platform IAP / crash SDK | Wire at soft launch |
| Real device Khan 1 gate proof | QA |
