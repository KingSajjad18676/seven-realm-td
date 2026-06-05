---
name: shahnameh-content
description: >-
  Add or modify Shahnameh TD design data — enemies, towers, heroes, levels,
  waves, fate cards — using ContentCatalog stable IDs and ContentValidator.
  Use when adding content, fixing catalog errors, smoke_test failures, or
  data-driven Resource work.
---

# Shahnameh Content Data — Shahnameh TD

## Rules

- **Stable IDs:** `lowercase_snake_case` (`enemy_jackal`, `tower_archer`, `level_01`).
- **Never** key gameplay off display names or filenames.
- Runtime: build from `ContentCatalog.build_bootstrap()`; optional `.tres` under `resources/data/` merged by `ContentRegistry`.
- **Do not** mutate shared catalog resources at runtime — duplicate per spawn/instance.

## Where content lives

| Type | Primary source |
|------|----------------|
| Bootstrap (code) | `scripts/meta/content_catalog.gd` |
| Resource override | `resources/data/<category>/*.tres` |
| Registry access | `ContentRegistry.get_enemy(id)`, `get_tower(id)`, `get_level(id)` |
| Validation | `ContentValidator.validate(catalog)` → `Array[String]` errors |

## Adding an enemy

1. Add `EnemyData` in `ContentCatalog.build_enemies()` (or `.tres` with matching `enemy_id`).
2. Reference `enemy_id` in level `WaveData.spawn_groups` — every level has **5 waves**.
3. Run validation:

```powershell
godot --headless --path . --script res://tools/smoke_test.gd
```

4. Add boss brain in `BossControllerFactory` if `is_boss`.
5. Extend `tests/validation/test_content_validator.gd` if new invariant needed.

## Adding a level

1. Use `build_khan_level()` patterns in `content_catalog.gd`.
2. Unlock chain: `SaveSystem.unlock_levels_after_clear` (level_01 → … → level_08_damavand).
3. Validator spot-checks: `level_02` wave 2 multi-spawn, Damavand serpent guard opener.

## Minimum catalog counts (enforced)

- Levels ≥ 9, enemies ≥ 20, fate cards ≥ 8, towers ≥ 6, heroes ≥ 2

## Checklist

- [ ] Unique IDs across category
- [ ] All spawn `enemy_id` values resolve
- [ ] 5 waves per campaign level
- [ ] smoke_test / GUT validation pass
- [ ] Placeholder art via `VisualAssetLoader` / `art/_placeholders/` until real art lands

## Related docs

- [docs/spec/entities-and-gameplay.md](docs/spec/entities-and-gameplay.md) — full entity list
- [docs/engineering/architecture.md](docs/engineering/architecture.md) — folder layout
- `.cursor/rules/code-resources.mdc` — Resource conventions
