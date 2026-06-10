# Godot Architecture

**Last updated:** 2026-06-11  
**Design canon:** [design/04-production-roadmap.md](../design/04-production-roadmap.md)  
**Engine:** Godot 4.6 Mobile  
**Project root:** repository folder containing `project.godot`  
**Logic onboarding:** [engineering/game-logic.md](engineering/game-logic.md)  
**Full inventory:** [product/main-gameplay.md](../product/main-gameplay.md)

## Folder layout

```text
repo root/
  project.godot
  scenes/           boot, main_menu, world_map, battle, roguelite_map, prefabs, ui, tools
  scripts/
    core/           enums, DamageInfo, combat_events
    data/           Resource class definitions (.gd)
    battle/         WaveManager, BattleBootstrap, MapLightManager, labours/, deep systems
    enemies/        EnemyController, PathFollower
    towers/         TowerController, TowerManager, build spots, range ring
    heroes/         HeroController, HeroManager
    companions/     Rakhsh mount, run companion behaviors
    units/          AllyUnitController (barracks summons)
    projectiles/
    status_effects/
    ui/             Battle HUD, VirtualJoystick, HeroActionHud, meta panels
    meta/           SaveSystem, WorldMap, content catalog, liveops services
    tools/          Map editor (dev)
    utilities/      ObjectPool, AudioManager, VisualAssetLoader, LevelAssetCollector
  resources/data/   Sparse .tres overrides (levels, relics, companions)
  art/_placeholders/ + art/maps/level_01.jpg
  addons/gut/       GUT v9.6.0
  tests/            unit, integration, validation
  tools/            validate_resources.ps1, smoke_test.gd
  docs/
```

## Autoloads (15)

| Name | Role |
|------|------|
| `SaveSystem` | JSON save v9 at `user://shahnamehtd_save.json` |
| `ForgeService` | Star Iron forge, elite gate, soft difficulty curve L3+ |
| `SceneFlowController` | Async scene load + fade + battle preload overlay |
| `ContentRegistry` | Runtime catalog from `content_catalog.gd` + `resources/data/` merge |
| `SettingsService` | Audio/settings prefs; UI scale |
| `AudioManager` | Music/SFX buses; procedural tone SFX |
| `CombatEvents` | Global combat signal bus |
| `AnalyticsService` | In-memory session events |
| `LocalizationService` | Stub (~7 English keys) |
| `DailyTaleService` | Daily battle launch flag |
| `EquipmentService` | 7 equipment sets × 4 pieces |
| `DailyMissionService` | 3/day from 10-mission pool |
| `MissionProgressTracker` | Lifetime mission stats |
| `StoreService` | Stub IAP — instant grant to save |
| `CrashReporter` | Stub — warns + analytics event |

## Content pipeline

- **Primary catalog:** `scripts/meta/content_catalog.gd` builds towers, enemies, heroes, levels, waves, fate cards, spells, equipment, missions at runtime.
- **Overrides:** `ContentRegistry._merge_folder_resources()` merges sparse `resources/data/` `.tres` files (e.g. `level_01.tres`, relic overrides).
- **Stable IDs:** `lowercase_snake_case` — never display names in gameplay code.

## Battle wiring

- **`BattleBootstrap`** — scene root; builds `BattleContext`, map, managers; wires `NaftTrapController`, hero stick input via HUD; attaches **`LabourMode`** on campaign launches
- **`BattleContext`** — RefCounted service locator; see [game-logic.md](game-logic.md) §6
- **`LabourMode` + `LabourModeFactory`** — `scripts/battle/labours/`; per-map additive hazards
- **`AllyUnitController`** — barracks melee blockers on `BattleContext.active_allies`
- **`BattleContextBridge`** — Node wrapper exposing signals for UI
- **Ownership rules** — see `.cursor/rules/code-battle.mdc`

## Scene flow

```text
Boot → MainMenu → WorldMap → Battle (via BattleLaunchData)
MainMenu → KavehForge / DailyTale
WorldMap → CampaignRun graph → TowerDraft → Battle
WorldMap → Horde / Brothers / Throne / Gauntlet / Hunt / Endless pickers → Battle
Legacy RogueliteMap → Battle (deprecated; save migrates to Campaign Run)
[DEV] MapEditor → save LevelData .tres
```

**Campaign Run:** `LootDropManager`, `CampaignRunState`, `TowerDraftController` on world map; save v6 `campaign_run`.

## Godot conventions

| Concept | Implementation |
|---------|----------------|
| Prefab | `PackedScene` |
| Manager script | Child `Node` + `.gd` |
| Design data | `Resource` + `.tres` (or runtime catalog) |
| Launch payload | `BattleLaunchData` |
| Time scale | `Engine.time_scale` |

## Build order

Follow [design/04](../design/04-production-roadmap.md) milestones **M0→M8**.

**Khan 1 gate:** voluntary replay before campaign art scale ([design/00](../design/00-project-index.md)).

See [engineering/project-status.md](engineering/project-status.md) for implementation status.
