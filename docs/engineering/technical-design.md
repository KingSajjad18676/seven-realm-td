# Technical Design Document

**Last updated:** 2026-06-04  
**Design canon:** [design/04-production-roadmap.md](../design/04-production-roadmap.md)  
**Logic overview:** [engineering/game-logic.md](engineering/game-logic.md) · **Implementation truth:** [engineering/implementation-tracker.md](engineering/implementation-tracker.md) · [engineering/project-status.md](engineering/project-status.md)

## 1. Engine

**Active:** Godot 4.6 (GDScript, `.tres` resources, `.tscn` scenes) — repository root (`project.godot`)

Shared product constraints:

- Mobile landscape
- Data-driven content (Godot Resources)
- Scene-based gameplay entities (PackedScene)
- Object pooling for runtime performance

### Godot autoloads

| Autoload | Role |
|----------|------|
| `SaveSystem` | JSON persistence at `user://shahnamehtd_save.json` |
| `SceneFlowController` | Async scene load + fade overlay |
| `ContentRegistry` | Bootstrap + level catalog |
| `SettingsService` | Audio/settings |
| `AudioManager` | SFX/music hooks |
| `CombatEvents` | Global combat event bus |

### Godot scene paths

| Scene | Path |
|-------|------|
| Boot | `scenes/boot/boot.tscn` |
| Main menu | `scenes/main_menu/main_menu.tscn` |
| World map | `scenes/world_map/world_map.tscn` |
| Battle | `scenes/battle/battle.tscn` |
| Roguelite map | `scenes/roguelite_map/roguelite_map.tscn` |

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

### Deep-system battle managers (implemented)

| Manager | Role |
|---------|------|
| `MapLightManager` | Regional light, corruption, hijack triggers (`BattleContext.Corruption`) |
| `AncestralForgeManager` | Adjacency recipes → hybrid tower upgrade |
| `ZervanDialController` | 50-slot chrono ring buffer + rewind |
| `CoupletComboManager` | Rhyme Window + Epic Couplet payoff |
| `KhanEscalationManager` | Boss HP phase steps |
| `AhrimanDirector` | Adaptive boss modifiers on phase |
| `PlayerTacticsAnalyzer` | Dominant `TowerFamily` tally |
| `AStarPathfinder` | Light-weighted paths (per-level flag) |
| `PathRecalcListener` | Throttled enemy path refresh |
| `ZahhakTributeManager` | Serpent sacrifice timer |
| `FateMechanics` | Static tuning from Fate boons/curses |
| `StarIronShardService` | Shard accrual, chain forging (100→1) |
| `PremiumGateway` / `IAP.StubPurchaseProvider` | IAP stub — **deferred** for launch ([design/03](../design/03-monetization.md)) |
| `SimorghBlessingService` | Subscription stub — **not** launch catalog |
| `KavehForgeService` | Offline shard production |
| `SimorghContinueService` | One-per-run feather continue |
| `FateRerollService` | Fate/blessing draft reroll economy |
| `HeroOwnershipService` | Premium hero gates |
| `ZahhakFuryService` | Post-finale heat scaffold |

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

## 5. Save System

Save:

- player level
- campaign progress
- hero ownership and levels
- hero upgrade ranks (Hero Camp)
- tower unlock progress
- tower family souls and lineage levels
- chronicle pages (collected + inserted)
- relic inventory
- currencies
- settings
- daily streak
- event progress
- star iron shards + chain progress
- simorgh blessing expiry, feather count
- kaveh forge offline accumulator
- owned premium hero ids

`GlobalBattleModifierService` aggregates inserted chronicle pages + lineage for battle bootstrap.

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

Mobile input:

- tap build spot → build / upgrade / sell UI
- tap max-level tower during tribute → sacrifice
- **drag hero → tower** → Sacred Tether (`HeroSacredTetherDrag`; separate from tap)
- drag hero → Zahhak → offensive tether
- tap ground → hero move (`HeroManager.HandleGroundTap`)
- hold rewind UI → `ZervanDialController` (`RewindButtonHandler` + `BattleOverlayUI` pulse)
- Khan organ drop → drag `OrganMutationDragUI` onto tower → `OrganMutationManager`
- rhyme / couplet / tribute / director banners → `BattleOverlayUI`
- tap cleanse / brazier → Sacred Fire spend on selected spot
- tap Qanat (when hero at well) → select destination node → SF teleport
- tap ability → hero skill (Rhyme Window synergy)

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
