# Implementation Tracker

**Last updated:** 2026-06-06 (Horde mode, Forge Tokens, Spells, paid power)  
**Repo truth:** [project-status.md](project-status.md)

---

## Core loop (Khan 1)

| Feature | Built | Target reference |
|---------|-------|------------------|
| Boot → menu → world map → battle | ✅ | [handoff.md](handoff.md) §2 |
| Tutorial gates Khan 1 | ✅ | `save_system.gd`, `world_map_controller.gd` |
| Khan 1 onboarding (tutorial + hints) | ✅ | `tutorial_controller.gd`, `contextual_hint_controller.gd`, `seen_hints` in save |
| Tower place / upgrade / sell | ✅ | Build radial on empty pad (unaffordable towers disabled); manage radial on occupied pad (level, upgrade, sell, purify) |
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
| **Horde mode** | ✅ Per-Khan 15-wave survival; progress tracked separately from campaign seals |
| Hunt Zahhak | ✅ Elite forge + 7 seals in UI and `go_to_battle()` gate |

---

## Meta / release

| Feature | Built |
|---------|-------|
| Save v4 + accessibility | ✅ |
| Daily Tale | ✅ `is_daily_tale` launch flag |
| Store restore stub | ✅ |
| **Forge Tokens + Spells** | ✅ Save v5; earn/buy/cast |
| **Paid combat SKUs (stub IAP)** | ✅ Tower, spells, token packs |
| **Unique Zahhak tower** | ✅ `tower_zahhak_serpent` — horde-all-clear or purchase |
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
