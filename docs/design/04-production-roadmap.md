# Design 04 — Development and Production Roadmap

**Last updated:** 2026-06-04  
**Design canon** — Godot 4.6 mobile implementation plan.  
**Implementation truth:** [engineering/project-status.md](../engineering/project-status.md) · [engineering/architecture.md](../engineering/architecture.md)  
**Project root:** repository folder containing `project.godot`

---

## 1. Development principle

Build the smallest version that proves the game is fun.

**Do not measure progress by:** image count, planned hero count, future mode count, lore database size.

**Measure by:** touch responsiveness, tactical clarity, replay behavior, device stability, production reliability, ability to add content without rewriting code.

---

## 2. Release scope

### Minimum viable vertical slice (Khan 1)

Khan 1 map, Rostam, Rakhsh moment, four starter towers, corrupted jackal/boar, Lion boss, Gold, Lives, Sacred Fire, corruption states + collapse, hijack/recovery, five waves, one Pardeh Break, small Fate pool, replay, analytics stub, settings basics.

### Replayable alpha

Khan 2–3, Zal or Gordafarid, route selection, relics, objectives, Forge prototype, save service, accessibility, large-map camera prototype, performance pass.

### Campaign beta

Maps 4–7, remaining bosses, more Fate cards/relics, collection UI, meta progression, localization foundation, polished onboarding, expanded QA.

### Release candidate

Damavand Binding, Hunt, Endless, Daily Tale, small cosmetic catalog, purchase recovery, privacy disclosures, store assets, crash reporting, final balance, release checklist.

---

## 3. Godot project structure (target)

```text
res://
  assets/          audio, fonts, maps, sprites (characters, enemies, bosses, towers, props, vfx, ui)
  autoload/        audio_manager, analytics_service, content_registry, game_state, save_service, settings_service
  data/            cards, cosmetics, enemies, heroes, maps, objectives, relics, towers, waves
  scenes/          battle, characters, enemies, bosses, towers, ui (battle_hud, pardeh_break, results, settings)
  scripts/         combat, data, debug, mobile, navigation, tests
  shaders/
  tools/           asset_validator, map_validator, performance_overlay
```

Align actual repo layout with [engineering/architecture.md](../engineering/architecture.md) as the port evolves.

---

## 4. Data-driven content

Use Godot `Resource` (`.tres`) with **stable lowercase_snake_case IDs**. Never depend on display names or filenames in gameplay code.

| Resource | Key fields |
|----------|------------|
| Hero | `hero_id`, `display_name_key`, `scene_path`, `portrait_path`, `max_hp`, `move_speed`, `skill_ids`, `tether_radius`, `unlock_rule`, `cosmetic_ids` |
| Tower | `tower_id`, `cost`, `range`, `attack_rate`, `damage_profile`, `upgrade_paths`, `forge_tags`, `corruption_behavior`, … |
| Enemy | `enemy_id`, `max_hp`, `move_speed`, `route_behavior`, `corruption_pressure`, `elite_modifiers`, … |
| Wave | `wave_id`, `spawn_groups`, `spawn_timing`, `route_id`, `boss_phase`, … |
| Map | `map_id`, `tilemap_layers`, `routes`, `build_pads`, `regions`, `camera_anchors`, `sector_activation_rules`, `minimap_bounds`, … |
| Fate card | `card_id`, `title_key`, `description_key`, `art_path`, `effect_ids`, `stacking_rule`, … |

---

## 5. Battle scene hierarchy (target)

```text
BattleScene
  MapRoot (Terrain, Route, Decoration, Collision, CorruptionOverlay, RegionControllers, BuildPads, InteractiveProps)
  UnitsRoot (Enemies, Heroes, Towers, Projectiles)
  VFXRoot / UIWorldIndicators
  Controllers (Wave, Economy, RegionState, Objective, Boss, RunModifier)
  Camera (BattleCamera, CameraAnchorController, ThreatJumpController)
  CanvasLayer (BattleHUD, Alerts, PauseMenu, PardehBreak, ResultsScreen)
```

---

## 6. Implementation milestones

| Milestone | Build | Exit gate |
|-----------|-------|-----------|
| **M0** Technical proof | Landscape viewport, touch camera, graybox route, one enemy/tower/projectile/gate, frame overlay | Placement works; enemy follows route; touch reliable; stable on mid-range Android |
| **M1** Khan 1 graybox | 32×18 map, pads, Gold, Lives, Rostam, four graybox towers, jackal, boar, five waves, results | Full battle without art; roles clear by behavior; one-tap replay |
| **M2** Signature systems | Regional light, corruption, Sacred Fire, cleanse, hijack, recovery, alerts, audio warnings | Corruption noticed before collapse; hijack recovery understood; fair punishment |
| **M3** Lion boss | Arena, claw, pounce, roar, hero-response window, defeat, hints | Boss changes tactics; readable telegraphs; clear defeat reason |
| **M4** Visual vertical slice | Approved Rostam, towers, enemies, Lion, woodland map, HUD, icons, VFX, audio draft | Art improves clarity; stable FPS; no hidden critical actions |
| **M5** Roguelite foundation | Pardeh Break, Fate draft, small pool, objectives, relic prototype, route nodes, run summary, replay analytics | Replay feels tactically different; players explain card choice |
| **M6** Content pipeline | Content registry, import presets, sprite/map validators, pooled VFX, save versioning, debug menu, test scene | New enemy without rewriting battle logic; broken atlases caught early |
| **M7** Campaign expansion | Maps Khan 2→7→Damavand in order | Each map: unique lesson, stable FPS, readable route, clear boss, no camera frustration |
| **M8** Release systems | Accessibility, localization foundation, Hunt, Endless, Daily Tale, store catalog, restore, privacy, crash reporting, soft launch | Release checklist complete |

**Primary signal before M7:** voluntary Khan 1 replay (see [design/00](../design/00-project-index.md)).

---

## 7. Mobile performance budget (starting targets)

| Area | Target |
|------|--------|
| Frame rate | Stable 60 FPS where practical; 30 FPS fallback |
| Active enemies | Validate ~60–100 standard enemies before raising |
| Projectiles / VFX | Pool and cap |
| Particles | Restrained; auto-reduce on low settings |
| Atlases | Group by scene/family |
| Large maps | TileMaps + staged sectors, not single bitmaps |
| Audio | Compressed formats; limit simultaneous playback |

Tune on **real devices**, not editor only.

---

## 8. Large-map engineering (maps 5–8)

Layered TileMaps; separate terrain, decoration, collision, corruption, interaction; activate relevant sectors only; pool enemies/VFX; camera anchors; minimap; off-screen warnings; threat-jump; avoid long camera travel; profile every new boss phase.

---

## 9. Save service

Persist: `save_version`, settings, accessibility, campaign progress, unlocks, mastery, Farr, relics, cosmetic/purchase entitlements, lore, daily tale state, analytics consent.

Version saves; migration functions; test clean install, upgrade, corrupted save; **never lose paid entitlements**; offline gameplay where practical.

---

## 10. Analytics foundation (events)

`session_start/end`, `tutorial_step_*`, `battle_started/completed/failed`, `wave_*`, `tower_built/upgraded/sold`, `hero_moved`, `hero_skill_used`, `region_state_changed`, `cleanse_used`, `tower_hijack_started/recovered`, `pardeh_break_opened`, `fate_card_selected`, `objective_*`, `replay_selected`, `store_viewed`, `product_purchased`, `rewarded_ad_offered/completed`.

Document fields; minimize personal data.

---

## 11. QA matrix

**Gameplay:** towers vs enemy classes, hero skills, corruption/hijack, boss telegraphs, objectives, Fate/relic/Forge combos, replay, pause, background/resume.

**Devices:** low/mid/high Android, iOS target range, aspect ratios, notches, touch, battery/thermal.

**Accessibility:** contrast, reduced particles/flashes/shake, UI scale, volume separation, readable text, color-safe corruption.

**Store:** purchase, cancel, restore, reinstall, offline, entitlement recovery, refunds, privacy disclosures, SDK inventory.

---

## 12. First priority backlog

**Build first:** project skeleton, data registry, Khan 1 graybox, tower placement, pathfinding, waves, gate, Rostam, Gold, Sacred Fire, corruption, hijack recovery, Lion boss, Pardeh Break, replay, analytics stub, performance overlay, device testing.

**Build later:** remaining maps, large collection UI, Hunt, Endless, Daily Tale, cosmetics, advanced live-ops, authored expansion.
