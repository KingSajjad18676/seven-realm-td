# Implementation Tracker

**Last updated:** 2026-06-11 (N2 combat feel + perf overlay)  
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
| Hero move + manual combat | ✅ | Virtual stick; Attack / Heavy / Dodge / Skill; equipment/morale/level mults on all hero damage |
| **In-battle hero XP** | ✅ | `HeroLevelService` — kill XP, Lv 1–10, HUD XP bar |
| **Hero skill loadout** | ✅ | Equipment screen skill picker; save `hero_skill_selected`; applied in `HeroManager` |
| **Rostam Naft traps** | ✅ | Wired in `battle_bootstrap`; `NaftTrapController` |
| Sacred Tether via radial | ✅ | Manage radial **Tether** option (tower spot panel deprecated) |
| Battle HUD polish | ✅ | Hero chip (portrait, skill readiness); alert priority; gate-hit feedback; region status chips; subtitles; objective/boss chips |
| Procedural SFX + menu tone | ✅ | `AudioManager` tone cache; settings drive Music/SFX buses |
| Lion boss (Khan 1 finale) | ✅ | Wave 30 of Khan 1 |
| Voluntary replay + analytics | ✅ | Mode-aware `BattleLaunchData.duplicate_launch()` |

---

## Signature systems

| System | Built | Notes |
|--------|-------|-------|
| Regional light + corruption | ✅ | `MapLightManager` |
| Sacred Fire + cleanse | ✅ | |
| Tower hijack | ✅ | |
| Sacred Tether | ✅ | Manage radial **Tether** when hero in range |
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
| **Horde mode** | ✅ Per-Khan 15-wave survival; horde/endless use map rosters + act progression |
| **Brothers in Arms** | ✅ Local co-op; 20-wave skirmish slice; shared gold/lives |
| **Defend the Throne** | ✅ `level_throne_arena`; radial spawns; 15-wave survival; auto-enables throne mode if mis-launched |
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
| Equipment battle rules | ✅ `EquipmentBattleService`, `equipment_set_rules.gd` |
| Daily Missions UI | ✅ `daily_missions_panel_controller.gd` on world map |
| Battle HUD back navigation | ✅ Return to map/menu from battle |

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

---

## Next milestones (N1–N5)

Post–M8 backlog after Khan 1 replay gate. **N1** is pure code; **N3–N5** are gated on device replay proof or release scope.

| Milestone | Scope | Status |
|-----------|-------|--------|
| **N1 — Battle HUD completion** | Alert priority queue; remove legacy bottom-bar Skill/Naft + `TowerSpotPanel`; hero portrait chip; gate-hit feedback; accessibility wiring (contrast/shake/particles/flashes/left-hand/vibration/subtitles); color-safe corruption region chips | ✅ |
| **N2 — Combat feel & perf** | Projectile-on-impact damage; performance overlay; large-map threat-jump | ✅ |
| **N3 — Content depth** | Farr meta currency + HUD; Fate cards 8→16; Simorgh Feather continue; Gordafarid + Esfandiyar heroes | ✅ |
| **N4 — Production maps & art** | Baked `level_02`–`level_08_damavand` geometry; placeholder unit/map/loading generators | ✅ (illustrated art still placeholder per `01-art-phases.md`) |
| **N5 — Release plumbing** | IapProvider + restore; privacy/consent gate; cosmetics store tab; analytics/crash backends (file/HTTP stubs) | ✅ (live platform SDK credentials deferred) |

### N1 gap rows (was missing)

| Item | Target |
|------|--------|
| Alert priority (gate > hijack > collapse > boss > objective > wave) | `battle_hud_controller.gd` queue |
| Hero portrait + skill readiness on chip | `hero_action_hud.gd` |
| Lives-hit flash + optional camera shake | HUD overlay + `TouchCamera.request_shake` |
| Accessibility consumers | `AccessibilityHelper`, settings → VFX/shake/HUD |
| Color-safe corruption HUD | `region_status_hud.gd` when high contrast |
| Legacy UI removal | `battle.tscn` bottom Skill/Naft/Forge; `TowerSpotPanel` |

### N2–N5 gap rows (deferred)

| Item | Notes |
|------|-------|
| Projectile impact timing | ✅ Damage on `ProjectileController` hit in `tower_manager.gd` |
| Performance overlay | ✅ `PerformanceOverlay` — FPS + enemy/tower/proj counts (debug); tap to expand |
| Large-map threat-jump | ✅ Tap off-screen edge indicator in `threat_indicator_controller.gd` |
| Full ~43 Fate cards | 16 wired in `content_catalog.gd`; pool expansion post-N5 |
| Farr + collection UI | ✅ Save v10 + `FarrService`; world map + battle HUD chip |
| Extra heroes | ✅ Gordafarid + Esfandiyar + skills in catalog |
| Simorgh continue | ✅ `simorgh_continue_controller.gd` + modal; Forge hybrids / Memory Div nodes still deferred |
| Maps 2–8 art + geometry | ✅ Baked `.tres` geometry + placeholder pipeline tools |
| IAP / crash / privacy / cosmetics store | ✅ `IapProvider`, `privacy_panel`, Cosmetics tab, analytics/crash backends |
