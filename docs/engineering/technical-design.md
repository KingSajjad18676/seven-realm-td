# Technical Design Document

**Last updated:** 2026-06-11  
**Design canon:** [design/04-production-roadmap.md](../design/04-production-roadmap.md)  
**Logic overview:** [engineering/game-logic.md](engineering/game-logic.md) · **Implementation truth:** [engineering/implementation-tracker.md](engineering/implementation-tracker.md) · [engineering/project-status.md](engineering/project-status.md)

## 1. Engine

**Active:** Godot 4.6 (GDScript, `.tres` resources, `.tscn` scenes) — repository root (`project.godot`)

Shared product constraints:

- Mobile landscape
- Data-driven content (Godot Resources)
- Scene-based gameplay entities (PackedScene)
- Object pooling for runtime performance

### Godot autoloads (15)

| Autoload | Role |
|----------|------|
| `SaveSystem` | JSON save **v9** at `user://shahnamehtd_save.json` |
| `ForgeService` | Star Iron forge, elite gate, soft difficulty |
| `SceneFlowController` | Async scene load + fade + battle preload |
| `ContentRegistry` | Runtime catalog + `resources/data/` merge |
| `SettingsService` | Audio/settings |
| `AudioManager` | SFX/music hooks (placeholder) |
| `CombatEvents` | Global combat event bus |
| `AnalyticsService` | In-memory session events |
| `LocalizationService` | Stub localization |
| `DailyTaleService` | Daily challenge flag |
| `EquipmentService` | Equipment sets + loadout |
| `DailyMissionService` | 3/day mission rotation |
| `MissionProgressTracker` | Lifetime mission stats |
| `StoreService` | Stub IAP |
| `CrashReporter` | Stub crash reporting |

### Godot scene paths

| Scene | Path |
|-------|------|
| Boot | `scenes/boot/boot.tscn` |
| Main menu | `scenes/main_menu/main_menu.tscn` |
| Kaveh's Forge | `scenes/main_menu/kaveh_forge.tscn` |
| World map | `scenes/world_map/world_map.tscn` |
| Battle | `scenes/battle/battle.tscn` |
| Roguelite map (legacy) | `scenes/roguelite_map/roguelite_map.tscn` |
| Map editor (dev) | `scenes/tools/map_editor.tscn` |
| Battle loading overlay | `scenes/ui/battle_loading_overlay.tscn` |

---

## 2. Scene Strategy

Scenes:

- Boot
- MainMenu
- WorldMap
- Battle
- RogueliteMap
- Shop
- HeroCamp
- EventHub

## 3. Core Runtime Managers

### BootManager

Initializes:

- save system
- asset references
- economy
- settings
- analytics interface
- scene loader

### BattleStateController

Controls:

- pre-battle
- wave active
- paused
- victory
- defeat

### WaveManager

Controls wave schedule and wave completion.

### EnemySpawner

Spawns enemies from WaveData.

### TowerManager

Handles build spots, tower placement, upgrade requests, sell requests.

### HeroManager

Spawns selected hero and routes input to HeroController.

### BattleEconomy

Tracks in-battle gold and rewards.

### StatusEffectSystem

Applies, ticks, and removes effects.

### Battle managers — implemented and wired

| Manager | Role |
|---------|------|
| `MapLightManager` | Regional light, corruption, hijack |
| `MoraleController` | 0–100 battle momentum |
| `ObjectiveController` | Map objectives + Hero's Vow evaluation |
| `TowerResonanceController` | Adjacent tower combo buffs |
| `LootDropManager` | Material scavenging pickups |
| `RunModifierService` | Fate cards, per-tower relic slots |
| `HuntController` | Hunt binding + shard pacing |
| `SpellController` | Forge Token battle spells |
| `EquipmentBattleService` | Equipped set rules in battle |
| `NaftTrapController` | Rostam path oil + SF ignition |
| `CoopPlayerManager` | Brothers in Arms split economy |
| `CompanionManager` / `RakhshMountController` | Run companions + mount |
| `LabourMode` (×8) | Campaign story overlays |
| Boss controllers (×8) | Per-boss phase logic via `boss_controller_factory.gd` |
| `CampaignWaveTemplates` | 10-wave master block generation |
| `KavusFollyController` | Campaign Run Throne of Kavus bombardment |

### Meta services — implemented

| Service | Role |
|---------|------|
| `CampaignRunState` / `CampaignRunGenerator` | Branching roguelite graph (save v6) |
| `GauntletRunState` | Gauntlet timer + ghost PB (save v8) |
| `EquipmentService` | 28 pieces, 7 sets (save v9) |
| `DailyMissionService` | 3/day missions (save v9) |
| `ForgeService` | Kaveh's Forge progression |
| `StoreService` | Stub IAP SKUs |

### Deferred / stub (not launch-critical)

| Manager | Role |
|---------|------|
| `ZervanDialController` | Rewind snapshots — **not built** |
| `SimorghContinueService` | Feather continue — **not built** |
| `AncestralForgeManager` | Hybrid tower recipes — **deferred** |
| `AhrimanDirector` | Adaptive boss modifiers — **partial/stub** |
| Platform IAP / crash SDK | Wire at soft launch |

## 4. Data Layer

Use Resources:

- HeroData
- EnemyData
- TowerData
- ProjectileData
- WaveData
- LevelData
- RelicData
- QuestData
- ShopItemData
- EventData
- TowerCombinationData
- BossModifierData
- OrganMutationData
- TowerVeterancyConfig
- LineageUpgradeData
- HeroUpgradeData
- ProphecyData
- ChroniclePageData
- JinnEncounterData

## 5. Save System (v9)

Migration chain: `scripts/meta/save_migration.gd` (v4→v9).

| Version | Key fields added |
|---------|------------------|
| v4 | Hunt best, forge notification, roguelite run, mode-aware battle saves |
| v5 | Forge Tokens, spells owned, horde progress, unlocked towers, paid entitlements |
| v6 | `campaign_run`, starter towers in `unlocked_towers` |
| v7 | `tower_relic_slots`, `active_relic_ids` (migrates legacy `relic_ids`) |
| v8 | `gauntlet_best` personal-best splits + ghost trace |
| v9 | Haft-Khan equipment loadout, daily missions, mission lifetime stats |

**Core persisted fields:** tutorial gate, level unlock chain, `khan_seals` (7), Star Iron + per-tower forge levels, `campaign_run`, equipment owned/equipped, accessibility, analytics consent, replay stats, seen hints.

Use stable IDs, not display names.

## 6. Object Pooling

Pool:

- enemies
- projectiles
- VFX
- floating damage text
- status icons
- temporary soldiers

## 7. Input

Mobile input (implemented):

- **virtual stick** → hero move (`VirtualJoystick` → `HeroManager`)
- **Attack / Heavy / Dodge / Skill** → `HeroActionHud` → `HeroController` (manual combat, no auto-attack)
- tap build spot → build radial (empty) or manage radial (occupied) + range ring
- manage radial → **Tether** when hero in range
- tap path when Naft armed → `NaftTrapController.try_place_at()`
- tap cleanse → Sacred Fire spend on selected region
- co-op → focused hero receives stick + buttons (`CoopPlayerManager.focused_player_index`)

**Deferred (design target):** drag hero → Zahhak offensive tether, hold rewind (`ZervanDialController`), Rhyme Window synergy, organ mutation drag, sacrifice tribute tap.

Use `Physics2D.OverlapCircleNonAlloc` for forge adjacency; no 3D physics.

## 8. Analytics Interface

Wrap analytics behind an interface so implementation can change.

Track:

- level start
- level complete
- level fail
- tower built
- tower upgraded
- hero skill used
- shop opened
- daily challenge start/end
- roguelite start/end
- event participation
