---
name: gut-testing
description: >-
  Run and write GUT unit/integration tests for Shahnameh TD (Godot 4.6).
  Use when adding tests, fixing test failures, running headless CI checks,
  smoke_test, ContentValidator, SaveMigration, or when the user mentions GUT,
  unit tests, or automated testing.
---

# GUT Testing — Shahnameh TD

## Run tests (CI parity)

From repo root (`project.godot`):

```powershell
godot --headless --path . --import --quit
godot --headless --path . -s res://addons/gut/gut_cmdln.gd -gconfig=res://.gutconfig.json
godot --headless --path . --script res://tools/smoke_test.gd
powershell -File tools/validate_resources.ps1
```

Editor: **Project → Tools → GUT** → directory `res://tests` must be set (enabled). Repo ships [`.gut_editor_config.json`](../../.gut_editor_config.json); the `shahnameh_gut_setup` plugin seeds it on first open. If you still see "no directories set", **restart Godot** once, or in GUT Settings use **Load** → `.gut_editor_config.json`.

CI: `.github/workflows/godot-tests.yml` (import → GUT → smoke_test).

## Layout

```
tests/
  helpers/       battle_test_fixtures.gd, content_test_utils.gd
  unit/          pure RefCounted / static logic
  integration/   Node controllers (ObjectiveController, WaveManager, …)
  validation/    ContentValidator, SaveMigration, ContentRegistry, unlock chain
```

- Prefix: `test_`; extend `GutTest`
- Config: `.gutconfig.json`
- Framework: `addons/gut/` (GUT v9.6.0, vendored)

## Writing tests

**Unit** — no scene tree unless needed:

```gdscript
extends GutTest

func test_example() -> void:
    var run := RogueliteRunState.new()
    run.generate_run()
    assert_eq(run.nodes.size(), 5)
```

**Integration (battle)** — use fixtures; never mutate shared `.tres`:

```gdscript
extends GutTest

var _ctx: BattleContext

func before_each() -> void:
    _ctx = BattleTestFixtures.minimal_context(self)
    BattleTestFixtures.attach_objectives(self, _ctx)

func test_no_leaks() -> void:
    # … assign objective, call controller methods, assert
    pass
```

**Save / forge tests** — reset autoload state:

```gdscript
func before_each() -> void:
    SaveSystem.test_reset_to_defaults()
```

**Async (WaveManager)** — `await` inside test methods:

```gdscript
func test_wave_clear() -> void:
    await _wave_manager._wait_for_wave_clear()
```

## Shared validators (reuse, don't duplicate)

| Script | Role |
|--------|------|
| `scripts/meta/content_validator.gd` | Catalog integrity; used by smoke_test + `tests/validation/` |
| `scripts/meta/save_migration.gd` | Save v1→v4; used by SaveSystem + migration tests |
| `tests/helpers/battle_test_fixtures.gd` | BattleContext, economy, objectives, hunt, relics |

When changing catalog rules, update `ContentValidator` and `tests/validation/test_content_validator.gd`.

When changing save schema, update `SaveMigration`, `SaveSystem`, and `tests/validation/test_save_migration.gd`.

## Checklist after test changes

- [ ] New logic has a matching `test_*.gd` in the right folder
- [ ] Headless GUT passes locally if Godot is on PATH
- [ ] smoke_test still passes (bootstrap + ContentValidator)
- [ ] No tests write to production `user://` save without `test_reset_to_defaults()`

## Manual Khan 1 gate (not automated)

After automated tests pass, manual F5 checks still required: corruption readability, hijack recovery, Lion telegraphs, one-tap replay. See `.cursor/rules/code-testing.mdc`.
