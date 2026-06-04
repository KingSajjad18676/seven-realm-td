# Godot Port Status

**Last updated:** 2026-06-04  
**Design canon / milestones:** [README_04_DEVELOPMENT_PRODUCTION_ROADMAP.md](README_04_DEVELOPMENT_PRODUCTION_ROADMAP.md) · [README_00_MASTER_PROJECT_INDEX.md](README_00_MASTER_PROJECT_INDEX.md)  
**Primary engine:** Godot 4.6 — `shahname-td-godot/shahname-td/` (`scenes/boot/boot.tscn`)  
**Unity reference:** archived under `_archive/unity/` (tag `unity-final-reference`)

## Milestone alignment (README_04)

| Milestone | Port status (summary) | Exit signal |
|-----------|-------------------------|-------------|
| M0 Technical proof | ✅ | Touch, route, tower, enemy, gate |
| M1 Khan 1 graybox | 🟡 | Playable battle; distinct map art/layout still thin |
| M2 Signature systems | 🟡 | MapLightManager, cleanse, hijack in code; teachability on device TBD |
| M3 Lion boss | 🟡 | Boss waves exist; telegraph polish TBD |
| M4 Visual vertical slice | 🟡 | Placeholder art; README_01 Phase 0/1 assets not integrated |
| M5 Roguelite foundation | 🟡 | Fate/blessing panels partially wired |
| M6–M8 | ❌ / 🟡 | Content pipeline tools exist; campaign expansion + release systems incomplete |

**Primary product gate:** voluntary **Khan 1 replay** without prompting (README_00) — not yet validated in playtests.



## Quick summary



| Question | Answer |

|----------|--------|

| Godot project runs? | **Yes** — Boot → Splash → MainMenu → WorldMap (F5 from `scenes/boot/boot.tscn`) |

| Core TD battle playable? | **Yes** — build/sell/upgrade, dual paths, hero melee, map backgrounds, HUD health/speed |

| Full Unity parity? | **Partial** — ~187 scripts ported; placeholder art; some meta panels stubbed |

| Design data | **115+** `.tres` with cross-refs (waves, levels, towers, projectiles) |

| Unity still in repo? | **Archived** — `_archive/unity/`; re-import via `tools/import_unity_refs.ps1` |



## Phase checklist



| Phase | Status | Notes |

|-------|--------|-------|

| 0 Foundation | ✅ | Autoloads, 30+ Resource types, boot flow |

| 1 Core TD | ✅ | Towers build/shoot/sell/range; hero+enemy stop-fight; dual-path lanes; HUD fixes |

| 2 Vertical slice | 🟡 | 7 Khans on world map + Hunt/Endless entry; **design target 8 maps** (incl. Damavand Binding); layouts mostly shared template |

| 3 Identity pillars | 🟡 | Fate, Morale, MapLightManager, Sacred Tether — HUD wired in battle scene |

| 4 Deep modules | 🟡 | Forge, Zervan, A*, Khan, Hunt, Nemesis — binding mosaic (7 seals + 3 anchors), Hunt finale gated |

| 5 Meta / UI | 🟡 | SaveSystem JSON save; main menu + world map meta/mode buttons wired |

| 6 Content / tools | ✅ | `import_unity_refs.ps1`, `validate_resources.ps1`, smoke tests, Level Map Editor plugin |



## Core TD battle fixes (2026-05-31)



| Area | Change |

|------|--------|

| Towers | `tower.tscn` → Node2D; sprite/fire_point wired; empty spots hide tower; starter `.tres` sprites |

| Tower UI | Selected panel shows level/range/sell/upgrade costs; build cards use adjusted build cost |

| Hero combat | Hero stops in melee range (both-stop with enemies); faces target |

| Multi-path | Colored lane lines + spawn markers; `wave_01` splits grunts/runners by path |

| Maps | Parchment fallback + tint per Khan 1–7; gate marker; camera centers on map bounds |

| HUD | World health bar visuals; hero health getters; skill cooldown signal; speed via `BattleStateController` |



## Validation (2026-05-31)



Automated checks (Godot 4.6.3):



| Check | Command / tool | Result |

|-------|----------------|--------|

| Resource cross-refs | `tools/validate_resources.ps1` | **PASSED** |

| Project parse | `godot --check-only` | Run in editor CI (Godot not on PATH in all shells) |

| Scene load smoke | `godot --script res://tools/smoke_test.gd` | **PASSED** — boot, main_menu, world_map, battle |

| Battle init smoke | `godot --script res://tools/battle_smoke_test.gd` | Paths, build spots, wave start, enemy spawn |



Manual checklist (run in editor):



| Test | Expected | Status |

|------|----------|--------|

| F5 Boot flow | Splash → Main Menu → World Map, no errors | ✅ smoke load |

| Khan 1 battle | Tap spot → build → Start Wave → towers shoot; gold/lives update | ✅ fixed (verify in editor) |

| Dual paths | Wave 1 grunts on top lane, runners on bottom lane | ✅ wave_01 path_index split |

| Hero melee | Move hero into enemies; both stop and fight | ✅ both-stop movement |

| Pause / resume | `BattleStateController` pauses wave logic | ✅ wired via HUD |

| Gate leak | Lives decrease; defeat at 0 | 🟡 manual |

| Victory | All waves cleared → victory UI → map | ✅ panels + SaveSystem.complete_level |

| Save unlock | Complete level 1 → level_02 unlocks after reload | 🟡 manual |

| Hunt / Endless | Loads battle with procedural waves | 🟡 smoke only |

| Binding mosaic | Khan seals on campaign win; Hunt iron/anchors; wave 50 finale | 🟡 manual |

| Mobile export | Landscape APK/IPA stable FPS | ❌ not run |



## How to test



1. Open the repo root (folder with `project.godot`) in Godot 4.6

2. Press **F5** (Boot scene)

3. Main Menu → World Map → **Khan 1**

4. In Battle: tap build spot → choose tower → **Start Wave**

5. Win: clear waves → **Continue** → map; Lose: **World Map** or **Retry**



Headless CI-style checks:



```powershell

powershell -File tools/validate_resources.ps1

godot --headless --path . --check-only

godot --headless --path . --script res://tools/smoke_test.gd

godot --headless --path . --script res://tools/battle_smoke_test.gd

```



## Known limitations



- Roguelite map node graph minimally wired (entry button on world map; graph still placeholder)

- IAP/analytics remain stubs (same as Unity)

- Mobile export preset added; full APK/IPA device test still required

- Final Persian miniature art per `DEVELOPMENT_ROADMAP.md` Phase 5.6 not started (placeholder backgrounds only)

- `level_hunt.tres` spawn/gate at origin still needs dedicated layout



## Next steps



1. Manual playthrough Khan 1–7; fix any runtime edge cases

2. Replace placeholder map backgrounds with manuscript art per Khan

3. Expand roguelite node graph and merchant/shrine nodes

4. Device smoke test on Android/iOS export templates



## Architecture



See [GODOT_ARCHITECTURE.md](GODOT_ARCHITECTURE.md). Shared design specs remain in repo `/docs/`.

