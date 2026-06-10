# Wave Spawn Audit

**Date:** 2026-06-11  
**Scope:** Wave spawning, enemy/boss spawning, spawn routes, mode-specific rules, victory/defeat flow across all game modes and maps.

**Pipeline:** `BattleLaunchData` → `battle_bootstrap.gd` → `WaveManager` → `EnemySpawner` → `BattleStateController._check_victory()`.

**Wave data sources:**
- **Authored:** `LevelData.waves` built by `CampaignWaveTemplates.generate()` at catalog build time.
- **Procedural slices:** `CampaignWaveTemplates.generate_horde_slice()` (Horde, Endless, Brothers, Campaign Run skirmish).
- **Throne slices:** `CampaignWaveTemplates.generate_throne_slice()` (Defend the Throne).

---

## Mode × Map Matrix

| Mode | Map | Wave Source | Wave Count | Enemies | Boss | Spawn Routes | Labour Mode | Status | Problem | Fix |
| ---- | --- | ----------- | ---------- | ------- | ---- | ------------ | ----------- | ------ | ------- | --- |
| Tutorial | level_00_tutorial | Authored `_tutorial_waves()` | 2 | jackal, corruptor | none | route_main / spawn_main | Disabled (is_tutorial) | Working | Pardeh/Vow skipped (tutorial flag) | — |
| Campaign | level_01 | `CampaignWaveTemplates.generate` | 30 | jackal, boar, corruptor | enemy_lion_boss (wave 30) | route_main | Active (mode_lion) | Working | — | — |
| Campaign | level_02 | generate | 40 | mirage_shade, salt_crust_brute, corruptor | enemy_thirst_manifest | route_main | Active (mode_thirst) | Working | — | — |
| Campaign | level_03 | generate | 50 | canyon_serpent, scorched_hound, corruptor | enemy_azhdaha | route_main | Active (mode_dragon) | Working | — | — |
| Campaign | level_04 | generate | 60 | illusion_attendant, feast_shade, corruptor | enemy_sorceress | route_main | Active (mode_temptress) | Working | — | — |
| Campaign | level_05 | generate | 70 | mountain_raider, mountain_archer, boar | enemy_olad_champion | route_main + route_2 | Active (mode_demons) | Working | — | — |
| Campaign | level_06 | generate | 80 | div_infantry, div_brute, div_corruptor | enemy_arzhang_div | route_main + route_2 | Active (mode_rescue) | Working | — | — |
| Campaign | level_07 | generate | 90 | white_div_thrall, cavern_boulder_brute, div_corruptor | enemy_white_div | route_main + route_2 | Active (mode_blindness) | Working | — | — |
| Campaign | level_08_damavand | generate | 100 | gauntlet mix → chainbreakers → serpent guards | enemy_zahhak (wave 100) | route_main + route_2 | Active (mode_zahhak) | Working | Wave 1 is gauntlet bait (jackal), not serpent guard | Validator spot-check updated |
| Horde | level_01 | `generate_horde_slice` | 15 | map roster | mini-boss wave 10 only | route_main | Disabled | Working | — | — |
| Horde | level_02 | generate_horde_slice | 15 | L2 roster | mini-boss wave 10 | route_main | Disabled | Working | — | — |
| Horde | level_03 | generate_horde_slice | 15 | L3 roster | mini-boss wave 10 | route_main | Disabled | Working | — | — |
| Horde | level_04 | generate_horde_slice | 15 | L4 roster | mini-boss wave 10 | route_main | Disabled | Working | — | — |
| Horde | level_05 | generate_horde_slice | 15 | L5 roster | mini-boss wave 10 | route_main + route_2 | Disabled | Working | — | — |
| Horde | level_06 | generate_horde_slice | 15 | L6 roster | mini-boss wave 10 | route_main + route_2 | Disabled | Working | — | — |
| Horde | level_07 | generate_horde_slice | 15 | L7 roster | mini-boss wave 10 | route_main + route_2 | Disabled | Working | — | — |
| Horde | level_08_damavand | generate_horde_slice | 15 | Damavand roster | chainbreaker mini-boss wave 10 | route_main + route_2 | Disabled | Working | No final boss (by design) | — |
| Endless | level_01 | `generate_horde_slice` + scaling | ∞ (999 cap) | L1 roster, scales after wave 15 | none (no final boss) | route_main | Disabled | Working | Uses horde slice, not separate generator | Docs updated |
| Daily Tale | level_01 | Authored campaign waves | 30 | L1 roster | enemy_lion_boss | route_main | Disabled | Partial | Daily seed stored but not applied to waves; Pardeh/Vow active | Document only; no feature change |
| Brothers in Arms | level_01–07 (picker) | `generate_horde_slice` via skirmish | 20 | selected map roster | mini-boss wave 10 | map routes | Disabled | Working | 20 waves not 15 (by design) | — |
| Brothers in Arms | level_08_damavand | generate_horde_slice | 20 | Damavand roster | chainbreaker mini-boss | route_main + route_2 | Disabled | Needs Test | — | — |
| Defend the Throne | level_throne_arena | `generate_throne_slice` | 15 | mixed pool → div_brute/corruptor | lion_boss mini-boss wave 10 | 10 radial route_throne_N | Disabled | Working | No final boss; enemies march to center throne | — |
| Campaign Run | level_01–07 skirmish | generate_horde_slice | 15 | node map roster | mini-boss wave 10 | map routes | Disabled | Working | skirmish_waves=15 | — |
| Campaign Run | level_01–07 labour boss | Authored generate | 30–90 | node map roster | map final boss | map routes | Disabled | Working | Full campaign waves, no Labour overlay | — |
| Campaign Run | level_08_damavand finale | Authored generate | 100 | Damavand acts | enemy_zahhak | route_main + route_2 | Disabled | Working | Returns to run map via `complete_campaign_battle` | — |
| Haft-Khan Gauntlet | level_01 | Authored (full Labour 1) | 30 | L1 roster | enemy_lion_boss | route_main | Disabled | Working | Pardeh/Vow disabled; rush/early-call supported | — |
| Haft-Khan Gauntlet | level_02–07 | Authored per Labour | 40–90 | per map | per map boss | map routes | Disabled | Working | 7-boss chain via `GauntletRunState` | — |
| Hunt for Zahhak | level_08_damavand | Authored generate | 100 | Damavand acts + chainbreakers | enemy_zahhak | route_main + route_2 | Disabled | Working | HuntController binding shards; no HuntWaveGenerator | Docs updated |
| Legacy Roguelite | level_01–07 (5-node) | Authored per node | 30–90 | per node map | per map boss | map routes | Disabled | Partial | Superseded by Campaign Run; scene still exists | No change unless still launched |

---

## Mode Rules Summary

| Rule | Campaign | Horde | Endless | Daily | Brothers | Throne | Gauntlet | Hunt | Campaign Run |
| ---- | -------- | ----- | ------- | ----- | -------- | ------ | -------- | ---- | -------------- |
| Labour Mode overlay | Yes | No | No | No | No | No | No | No | No |
| Pardeh every 5 waves | Yes | No | No | Yes* | No | No | No | Yes* | Skirmish: No; Boss: Yes* |
| Hero's Vow every 10 | Yes | No | No | Yes* | No | No | No | Yes* | Skirmish: No; Boss: Yes* |
| Mini-boss every 10 | Yes | Yes (slice) | Yes (slice) | Yes | Yes (slice) | Yes (wave 10 lion) | Yes | Yes | Skirmish: Yes; Boss: Yes |
| Final boss on last wave | Yes | No | No | Yes | No | No | Yes (per Labour) | Yes | Boss nodes: Yes |
| Victory condition | Final wave clear | Wave 15 clear | Never (defeat only) | Wave 30 clear | Wave 20 clear | Wave 15 clear | Labour 7 boss clear | Wave 100 + binding | Node-type dependent |
| Can end correctly | Yes | Yes | Yes (defeat) | Yes | Yes | Yes | Yes | Yes | Yes |

\*Daily Tale and Hunt use authored-wave path (`is_campaign_mode()` false but not horde/endless/throne/gauntlet), so Pardeh/Vow **do** trigger. Documented as current behavior; not changed in this pass.

---

## Spawn Route Reference

| Map | Primary Route | Secondary | Special |
| --- | ------------- | --------- | ------- |
| level_00_tutorial | route_main (legacy path_points) | — | — |
| level_01–04 | route_main | — | — |
| level_05–08 | route_main | route_2 / spawn_2 (TRAP_B, PUSH) | — |
| level_throne_arena | route_throne_0..9 | — | Radial to center gate |
| level_01.tres override | route_main, route_2 | spawn_1 (not spawn_2) | Fallback works; naming drift |

---

## Confirmed Defects (pre-fix)

| ID | Severity | Description | Fix |
| -- | -------- | ----------- | --- |
| D1 | High | `ContentValidator.WAVES_PER_LEVEL = 5` stale; fails all levels | Update to per-level expectations |
| D2 | High | Damavand spot-check expects wrong wave-1 enemy | Match gauntlet-act template |
| D3 | Medium | `wave_count_for()` returns 30 for unknown level IDs | Explicit match; unknown → 0 |
| D4 | Low | Docs reference `EndlessWaveGenerator` / `HuntWaveGenerator` | Update handoff + game-logic |
| D5 | Low | `level_01.tres` uses spawn_1 vs spawn_2 convention | Document; optional normalize |
| D6 | Info | Daily seed not applied to wave generation | Document only |
| D7 | Info | `mode_zahhak.gd` phase alerts never run in Hunt | Labour Mode campaign-only by design |

---

## Victory / Defeat Flow

- **Per-wave clear:** `WaveManager._wait_for_wave_clear()` polls `get_active_enemy_count() == 0`.
- **Battle victory:** `BattleStateController._check_victory()` when `all_waves_spawned && active_enemies == 0`.
- **Horde/Throne/Brothers/Skirmish:** `notify_all_waves_spawned()` after final wave clears (wave 15/15/20/15).
- **Endless:** Never calls `notify_all_waves_spawned()`; loops until defeat.
- **Gauntlet:** Victory chains via `SceneFlowController.advance_gauntlet_after_victory()`; PB saved on Labour 7 clear.
- **Campaign Run:** Returns to world map via `complete_campaign_battle()` → run graph reopens.
- **Hunt:** Victory on wave 100 clear + binding; `HuntController` tracks shards.

---

## Manual Test Checklist (Godot 4.6 F5)

1. **Tutorial:** Main menu Play (first run) → 2 waves, hold between waves, victory unlocks world map.
2. **Campaign L1:** World map Labour 1 → 30 waves, Pardeh at 5/10/15, mini-boss at 10/20, Lion boss wave 30.
3. **Horde:** World map Horde → pick Labour → 15 waves, no Pardeh, victory at wave 15.
4. **Endless:** World map Endless (7 seals) → waves continue past 15, no victory screen until defeat.
5. **Daily Tale:** Main menu Daily → Labour 1 layout, 30 waves, completion flag set on win.
6. **Brothers:** World map Brothers → pick heroes + map → 20 waves.
7. **Throne:** World map Defend the Throne → 15 waves from radial spawns toward center.
8. **Gauntlet:** World map Gauntlet → draft 3 towers → 7 Labour bosses in sequence.
9. **Hunt:** World map Hunt (7 seals + Elite forge) → Damavand 100 waves, binding shards on kills.
10. **Campaign Run:** World map Campaign Run → skirmish (15 waves) and boss nodes (full waves) → return to graph on win.

**Debug:** F3 debug menu → "Validate wave spawns" (debug builds) or run `godot --headless --script res://tools/smoke_test.gd`.

---

## Files Inspected

- `scripts/battle/wave_manager.gd`
- `scripts/battle/battle_bootstrap.gd`
- `scripts/battle/battle_launch_data.gd`
- `scripts/battle/enemy_spawner.gd`
- `scripts/battle/battle_state_controller.gd`
- `scripts/battle/hunt_controller.gd`
- `scripts/meta/campaign_wave_templates.gd`
- `scripts/meta/content_catalog.gd`
- `scripts/meta/content_validator.gd`
- `scripts/meta/campaign_run_generator.gd`
- `scripts/meta/gauntlet_run_state.gd`
- `scripts/meta/daily_tale_service.gd`
- `scripts/meta/world_map_controller.gd`
- `scripts/battle/labours/labour_mode_factory.gd`
- `scripts/data/level_data.gd`
- `resources/data/levels/level_01.tres`, `level_02.tres`
- Existing tests: `test_wave_generator.gd`, `test_campaign_wave_templates.gd`, `test_pardeh_cadence.gd`, `test_gauntlet_wave_rules.gd`, `test_horde_act_progression.gd`, `test_throne_defense_mode.gd`
