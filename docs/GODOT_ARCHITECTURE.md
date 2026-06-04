# Godot Architecture

**Last updated:** 2026-06-04  
**Design canon:** [README_04_DEVELOPMENT_PRODUCTION_ROADMAP.md](README_04_DEVELOPMENT_PRODUCTION_ROADMAP.md)  
**Engine:** Godot 4.6 Mobile  
**Project root:** `shahname-td-godot/shahname-td/`  
**Reference:** Unity implementation in `_archive/unity/Assets/_Project/Scripts/`  
**Logic onboarding:** [GAME_LOGIC_AND_ESSENTIALS.md](GAME_LOGIC_AND_ESSENTIALS.md)
## Folder layout

```text
shahname-td/
  scenes/           boot, main_menu, world_map, battle, roguelite_map, prefabs
  scripts/
    core/           enums, DamageInfo, status instances
    data/           Resource class definitions (.gd)
    battle/         WaveManager, BattleBootstrap, MapLightManager, deep systems
    enemies/        EnemyController, PathFollower
    towers/         TowerController, TowerManager, build spots
    heroes/         HeroController, Sacred Tether
    projectiles/
    status_effects/
    ui/             Battle HUD + meta panels
    meta/           SaveSystem, WorldMap, liveops services
    utilities/      ObjectPool, AudioManager
  resources/        design data (.tres) — mirrors ScriptableObjects
  art/_placeholders/
  addons/level_map_editor/
  tools/            Unity .asset importers
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

- **`BattleBootstrap`** — scene root; builds `BattleContext`, map, managers
- **`BattleContext`** — RefCounted service locator (managers only)
- **`BattleContextBridge`** — Node wrapper exposing signals for UI
- **Ownership rules** — same as Unity (see `.cursor/rules/12-godot-gameplay-architecture.mdc`)

## Data

- Unity `ScriptableObject` → Godot `Resource` (`.tres`)
- Stable IDs: `lowercase_snake_case` (save/analytics compatible with Unity)
- Runtime state on nodes/controllers — never mutate shared `.tres` at runtime

## Scene flow

```text
Boot → CompanySplash → MainMenu → WorldMap → Battle
RogueliteMap → Battle (via BattleLaunchData)
```

## Unity → Godot mapping

| Unity | Godot |
|-------|-------|
| Prefab | PackedScene |
| MonoBehaviour manager | Child Node + script |
| ScriptableObject | Resource |
| BattleLaunchData static | `BattleLaunchData` class |
| Time.timeScale | `Engine.time_scale` |

## Build order (new systems)

Follow [README_04](README_04_DEVELOPMENT_PRODUCTION_ROADMAP.md) milestones **M0→M8**. Legacy sequence: Resource types → path → waves → towers → projectiles → economy → hero → HUD → win/loss → meta → identity pillars → deep modules.

**Khan 1 gate:** voluntary replay before campaign art expansion ([README_00](README_00_MASTER_PROJECT_INDEX.md)).

See [GODOT_PORT_STATUS.md](GODOT_PORT_STATUS.md) for implementation status.
