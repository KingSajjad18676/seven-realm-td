---
name: godot-battle-feature
description: >-
  Implement or fix Shahnameh TD battle gameplay in Godot 4.6 following
  BattleContext architecture. Use when working on waves, enemies, towers,
  heroes, bosses, corruption, hijack, objectives, economy, morale, hunt,
  or battle HUD wiring.
---

# Godot Battle Feature — Shahnameh TD

## Before coding

1. Read [docs/engineering/project-status.md](docs/engineering/project-status.md) — confirm the system exists.
2. Read [docs/engineering/game-logic.md](docs/engineering/game-logic.md) for state/ownership.
3. Respect **Khan 1 gate** unless scoped wider ([docs/design/00-project-index.md](docs/design/00-project-index.md)).

## Architecture contract

```
BattleBootstrap → BattleContext (RefCounted service locator)
                → BattleContextBridge (Node signals for UI)
                → Controllers (WaveManager, Economy, Objectives, …)
```

**Ownership (do not cross):**

| Component | Owns |
|-----------|------|
| `WaveManager` | Wave timing; waits for enemy clear before next wave / Pardeh |
| `EnemySpawner` | Spawn from `WaveData`; duplicate `EnemyData` per spawn |
| `EnemyController` | Movement, HP, death, rewards |
| `TowerController` | Targeting, hijack at light=0 |
| `HeroController` | Movement, Sacred Tether (not build UI) |
| `MapLightManager` | Regional light / corruption |
| `BattleEconomy` | Gold + Sacred Fire |
| `BattleStateController` | Win / loss / pause only |
| `ObjectiveController` | Goals; evaluate at **victory** for no_leaks / no_hijack |

UI listens to `BattleContextBridge` signals — controllers do not drive HUD directly.

## Implementation steps

1. Identify the owning controller; extend it, don't bolt logic onto UI or projectiles.
2. Read/write via `BattleContext` references set in `BattleBootstrap`.
3. Use stable IDs from `ContentCatalog` / `ContentRegistry` — never display names.
4. Duplicate runtime `EnemyData`/`HeroData` — never mutate catalog `.tres`.
5. Add GUT coverage: `tests/integration/` for controllers, `tests/unit/` for pure helpers.
6. Manual F5 on affected level; note edge cases (defeat mid-wave, pause during Pardeh).

## Signature systems (Khan 1+)

- **Corruption:** Pressured → Critical → Collapsed; telegraph before harsh punishment.
- **Hijack:** Warning → rescue window → cleanse/recovery; never silent tower disable.
- **Pardeh Break:** Every 5 cleared waves → Fate draft; keep UI under ~40s.
- **Objectives:** `no_leaks`, `no_hijack`, `cleanse_twice` — failure on event; success at victory eval.

## Boss brains

Register in `BossControllerFactory` by `enemy_id`. Boss debuffs clear on death; pool reuse resets controller state.

## Files map

```
scripts/battle/     WaveManager, BattleBootstrap, objectives, hunt, forge, …
scripts/enemies/    EnemyController, PathFollower
scripts/towers/     TowerController, TowerManager
scripts/heroes/     HeroController, HeroManager
scripts/ui/         battle_hud_controller, fate_draft, tower_spot_panel
scenes/battle/      battle.tscn
```

## After coding

- Summarize changed files.
- Run GUT if logic changed ([gut-testing](gut-testing/SKILL.md)).
- Update [project-status.md](docs/engineering/project-status.md) if milestone-level.
