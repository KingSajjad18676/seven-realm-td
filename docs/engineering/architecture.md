# Godot Architecture

**Last updated:** 2026-06-06  
**Design canon:** [design/04-production-roadmap.md](../design/04-production-roadmap.md)  
**Engine:** Godot 4.6 Mobile  
**Project root:** repository folder containing `project.godot`  
**Logic onboarding:** [engineering/game-logic.md](engineering/game-logic.md)

## Folder layout (target)

```text
repo root/
  project.godot
  scenes/           boot, main_menu, world_map, battle, roguelite_map, prefabs
  scripts/
    core/           enums, DamageInfo, status instances
    data/           Resource class definitions (.gd)
    battle/         WaveManager, BattleBootstrap, MapLightManager, labours/, deep systems
    enemies/        EnemyController, PathFollower
    towers/         TowerController, TowerManager, build spots
    heroes/         HeroController, Sacred Tether
    units/          AllyUnitController (barracks summons)
    projectiles/
    status_effects/
    ui/             Battle HUD + meta panels
    meta/           SaveSystem, WorldMap, liveops services
    utilities/      ObjectPool, AudioManager
  resources/        design data (.tres)
  art/_placeholders/
  addons/           editor plugins (e.g. level map editor)
  tools/            validate_resources, smoke_test.gd
  tests/            GUT unit, integration, validation tests
  addons/gut/       GUT v9.6.0 test framework
  docs/
```

## Autoloads

| Name | Role |
|------|------|
| `SaveSystem` | JSON save at `user://shahnamehtd_save.json` |
| `SceneFlowController` | Async scene load + fade overlay |
| `ContentRegistry` | Loads `bootstrap_content.tres`, `level_catalog.tres` |
| `SettingsService` | Audio/settings prefs |
| `AudioManager` | Placeholder SFX |
| `CombatEvents` | Global combat signal bus |

## Battle wiring

- **`BattleBootstrap`** — scene root; builds `BattleContext`, map, managers; attaches **`LabourMode`** on campaign launches only
- **`BattleContext`** — RefCounted service locator (managers only); holds `labour_mode` and `active_allies`
- **`LabourMode` + `LabourModeFactory`** — `scripts/battle/labours/`; per-map additive hazards via wave/cleanse/boss hooks
- **`AllyUnitController`** — barracks melee blockers tracked on `BattleContext.active_allies`
- **`BattleContextBridge`** — Node wrapper exposing signals for UI
- **Ownership rules** — see `.cursor/rules/code-battle.mdc`

## Data

- Design data: Godot `Resource` subclasses + `.tres` files under `resources/`
- Stable IDs: `lowercase_snake_case` (save/analytics)
- Runtime state on nodes/controllers — never mutate shared `.tres` at runtime

## Scene flow

```text
Boot → CompanySplash → MainMenu → WorldMap → Battle
RogueliteMap → Battle (via BattleLaunchData)
```

## Godot conventions

| Concept | Implementation |
|---------|----------------|
| Prefab | `PackedScene` |
| Manager script | Child `Node` + `.gd` |
| Design data | `Resource` + `.tres` |
| Launch payload | `BattleLaunchData` |
| Time scale | `Engine.time_scale` |

## Build order

Follow [design/04](../design/04-production-roadmap.md) milestones **M0→M8**.

**Khan 1 gate:** voluntary replay before campaign expansion ([design/00](../design/00-project-index.md)).

See [engineering/project-status.md](engineering/project-status.md) for implementation status.
