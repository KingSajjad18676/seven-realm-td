# Implementation Tracker

**Last updated:** 2026-06-07 (Haft-Khan Gauntlet)  
**Repo truth:** [project-status.md](project-status.md)

---

## Core loop (Khan 1)

| Feature | Built | Target reference |
|---------|-------|------------------|
| Boot → menu → world map → battle | ✅ | [handoff.md](handoff.md) §2 |
| Tutorial gates Khan 1 | ✅ | `save_system.gd`, `world_map_controller.gd` |
| Khan 1 onboarding (tutorial + hints) | ✅ | `tutorial_controller.gd`, `contextual_hint_controller.gd`, `seen_hints` in save |
| Tower place / upgrade / sell | ✅ | Free placement beside roads (`TowerPlacementValidator`); build/manage radial at world position; **range ring** on select (`tower_range_ring.gd`) |
| Waves + spawner + win/loss | ✅ | [spec/gameplay.md](../spec/gameplay.md) |
| **Scaled campaign waves** | ✅ | 10-wave master block templates per map; Pardeh every 5 cleared waves; mini-boss every 10th; Hero's Vow after block end; final boss wave |
| **Hero's Vow (10-wave blocks)** | ✅ | `VowOfferController`, `ObjectiveController` vow types, HUD chip, results tally |
| Hero move + skill | ✅ | Rostam + Zal (Khans 2–3) |
| **Rostam Naft traps** | ✅ | `NaftTrapController` — path oil slow + Sacred Fire ignition AoE |
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
| Tower Resonance | ✅ | `TowerResonanceController` — Fire+String burn, Quake+Bind AoE slow; hybrids remain Kaveh meta unlocks only |
| Kaveh's Forge (meta) | ✅ | Elite gate for Hunt; **soft forge gate L3+**; **tower unlock** rows spend per-tower Star Iron |
| Active scavenging | ✅ | `LootDropManager`, `MaterialDrop`, unbanked materials, retreat/defeat rules |
| Rostam companions | ✅ | Rakhsh mount; Shrine pick Cheetah / Simurgh / Zavareh |
| Campaign Run graph | ✅ | `CampaignRunGenerator`, world map panel, node types incl. **Throne of Kavus** |
| Kay Kavus's Folly (Campaign Run) | ✅ | Rare event node; accept arms next battle with 20s sky bombardment (`KavusFollyController`) |
| Tower draft | ✅ | `TowerDraftController` — 3 pre-run, +1 mid-run |
| **Relics of the Shahs** | ✅ | `RelicSlotPickerController`, `RunModifierService` per-tower slots; Jamshid / Hushang + pool; distinct from Kaveh's Forge |
| Ahriman's Shroud (hard mode) | ✅ | Damavand clear unlock; run SF wallet; map reveal gate; battle SF sync |

---

## Campaign & modes

| Feature | Built |
|---------|-------|
| Khans 1–7 + Damavand data | ✅ Procedural waves + per-Khan rosters / mini-bosses |
| World map unlock chain | ✅ Tutorial → Khan 1 → … → Damavand |
| Khan seals (7) | ✅ Campaign clears only |
| Roguelite 5-node run (legacy) | 🟡 Migrated to Campaign Run save v6 |
| Campaign Run | ✅ Save v6 `campaign_run`; branching world map UI |
| Ahriman's Shroud | ✅ Optional Campaign Run toggle after Damavand clear |
| Endless mode | ✅ No campaign progress on victory |
| **Horde mode** | ✅ Per-Khan 15-wave survival; progress tracked separately from campaign seals |
| **Brothers in Arms** | ✅ Local co-op (`CoopPlayerManager`); Zal + Sohrab hero pick; split SF/loot; shared gold/lives |
| **Defend the Throne** | ✅ `level_throne_arena`; radial spawns; 15-wave survival; no campaign seals |
| **Haft-Khan Gauntlet** | ✅ Labours 1–7 chain; timer + ghost PB; no Pardeh/Vow; Rush / early-call overwhelm |
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
| **Haft-Khan Equipment** | ✅ 28 pieces, 7 sets, `EquipmentService` + battle modifiers |
| **Daily Missions** | ✅ `DailyMissionService`, Royal Bounty consumable, save v9 |
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
| Per-map loading screens | 🟡 Functional preload overlay + progress (`battle_loading_overlay`); illustrated splash art still placeholder via `VisualAssetLoader.loading_sprite()` |
