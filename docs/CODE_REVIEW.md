# Code Review Report — ShahnamehTD MVP

**Last updated:** 2026-06-04 (historical Unity MVP notes)  
**Current QA matrix:** [README_04_DEVELOPMENT_PRODUCTION_ROADMAP.md](README_04_DEVELOPMENT_PRODUCTION_ROADMAP.md) §11  
**Active engine:** Godot — [GODOT_PORT_STATUS.md](GODOT_PORT_STATUS.md)

Review date: MVP initial implementation pass (Unity).

## 1. Biggest Risks

| Risk | Severity | Notes |
|------|----------|-------|
| **No prefabs/scenes wired** | High | All systems are code-only; nothing runs until Unity setup in `UNITY_SETUP.md` is done. |
| **EnemyRegistry static list** | Medium | `_activeEnemies` list is mutated during iteration in skills/AoE. Currently safe because damage kills don't remove mid-loop, but future effects could cause issues. |
| **Roguelite ↔ Battle scene handoff** | Medium | Blessings passed via static `BattleLaunchData`; works for prototype but fragile for multi-scene async loads. |
| **Daily modifiers partially stubbed** | Low | Only lives reduction applied; enemy speed and tower cost modifiers need spawn/build hooks. |
| **Input uses legacy Input.mouse** | Low | Fine for editor; mobile builds need Input System touch routing. |
| **Per-tower projectile pools** | Low | Each tower creates its own pool; many towers = many pools. Acceptable for MVP. |

## 2. Safest Improvements (Applied)

- **EnemyRegistry**: Added `HashSet` for O(1) register/unregister instead of `List.Contains`.
- **BattleLaunchData**: Added roguelite blessing list for cross-scene handoff.
- **BattleModifierApplicator**: Centralized daily modifier and blessing application.
- **WorldMapController**: Binds `LevelPopupController` on Awake.
- **UI text**: Uses `UnityEngine.UI.Text` instead of TMP to avoid missing package dependency.
- **Removed unused field** in `BattleHUDController`.

## 3. File-by-File Refactor Plan

| File | Action | Priority |
|------|--------|----------|
| `BattleBootstrap.cs` | Extract input handling to `BattleInputController` using Input System | Medium |
| `TowerController.cs` | Move target scan to shared `TargetScanner` service; support TargetMode enum | Medium |
| `EnemyController.cs` | Extract damage calculation to `DamageCalculator` static utility | Low |
| `HeroController.cs` | Split movement, combat, and revive into small components | Low |
| `BattleHUDController.cs` | Split into `BattleHUDTopBar`, `BattleHUDBottomBar` for canvas split | Low |
| `RogueliteRunController.cs` | Replace static blessing handoff with `ScriptableObject` run state asset (runtime instance) | Medium |
| `SaveSystem.cs` | Add versioning and migration for save format changes | Medium |
| `DailyChallengeService.cs` | Inject `SaveSystem` interface instead of static calls for testability | Low |
| `WaveManager.cs` | Add explicit "waiting for clear" state between waves (optional delay) | Low |
| `ObjectPool.cs` | Add max pool size cap and warm-up API | Low |

## 4. What NOT to Change Yet

- **BattleContext injection pattern** — works well, avoids FindObjectOfType; keep until scene complexity grows.
- **ScriptableObject data classes** — stable IDs and structure are correct for designers.
- **Status effect stubs** — intentionally deferred; do not build full system before vertical slice is fun.
- **Shop/monetization** — daily bazaar is soft-currency only; no real-money wiring needed yet.
- **Analytics interface** — not implemented; add when telemetry provider is chosen.
- **Morale / corruption / fate weaving** — design doc features; not MVP scope.

## Manual Test Steps (Post-Setup)

See [UNITY_SETUP.md](UNITY_SETUP.md) section 6 for the full checklist covering battle loop, towers, hero, world map, roguelite, and daily systems.

## MVP Launch-Ready Pass (May 2026)

### New data contracts

| Asset | New fields |
|-------|------------|
| `TowerData` | `targetMode`, `onHitStatusEffect`, `tintColor` |
| `ProjectileData` | `splashRadius`, `splashDamagePercent`, `statusEffect` |
| `LevelData` | `nextLevelId`, `softCurrencyReward` |
| `EnemyData` | `attackDamage`, `attackRange`, `attackCooldown`, `isBoss`, `scaleMultiplier`, `tintColor` |
| `StatusEffectData` | New SO: slow/burn/stun with `duration`, `magnitude`, `tickDamage` |

### New runtime systems

- `RangeIndicator` + `TowerManager` range preview on selected build spot
- `BattleFeedback` floating damage numbers + enemy hit flash
- `StatusEffectInstance` ticking on `EnemyController` (slow/stun/burn)
- `WorldHealthBar` for boss and hero HP
- `SettingsService` + `SettingsPanel` (PlayerPrefs volumes)
- `AudioManager` placeholder SFX hooks
- Campaign victory/defeat navigation + level unlock chain via `nextLevelId`

Regenerate scenes/assets: Unity menu **ShahnamehTD → Generate Project Setup**.
