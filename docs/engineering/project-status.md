# Project Status (Godot)

**Last updated:** 2026-06-06 (Hero's Vow + scaled campaign waves)  
**Milestones:** [design/04-production-roadmap.md](../design/04-production-roadmap.md) · **Identity:** [design/00-project-index.md](../design/00-project-index.md)

---

## Repo snapshot (honest)

| Item                           | Status                                                                                                                                                            |
| ------------------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Godot project                  | ✅ `project.godot` — landscape mobile, main scene boot                                                                                                            |
| Main menu → world map → battle | ✅ Campaign, roguelite, endless, **horde**, hunt, daily tale                                                                                                                 |
| Tutorial gate                  | ✅ Khan 1 locked until tutorial cleared                                                                                                                           |
| Khan 1 onboarding              | ✅ Tutorial teaches objective/morale/boss; one-time contextual hints in battle (tower panel, forge, early call, tether)                                           |
| Campaign levels                | ✅ Tutorial + Khans 1–7 + Damavand; **30–100 procedural waves** (+10 per Khan), mini-boss every 10th wave |
| Hero's Vow (wave challenges)   | ✅ Optional Accept/Decline vow every 10 waves; honor = SF + morale; break = morale penalty (never fails battle) |
| Signature systems              | ✅ Corruption, hijack (SF purify), Pardeh/Fate (skip or pick), Morale at start, Sacred Tether via tower panel, Ancestral Forge nearest-pad fusion                 |
| Roguelite 5-node run           | ✅ Persisted to save v4; resume from world map; defeat clears run                                                                                                 |
| Hunt for Zahhak                | ✅ 7 seals + Elite forge enforced in scene flow; binding shards weaken Zahhak                                                                                     |
| Campaign Damavand              | ✅ After Khan 7 clear; binding guards + chainbreakers before boss                                                                                                 |
| Kaveh's Forge                  | ✅ World map link; Elite notification unlocks Hunt                                                                                                                |
| Save v4                        | ✅ Hunt best, forge notification, roguelite run state, mode-aware battle saves                                                                                    |
| Save v5                        | ✅ Forge Tokens, spells owned, horde progress, unlocked towers, paid entitlements                                                                                 |
| Khan difficulty scaling        | ✅ Per-Khan HP/speed/count mults; procedural wave generator (`ContentCatalog._generate_campaign_waves`) |
| Horde mode                     | ✅ 15 waves per Khan; clear all 8 unlocks Serpent Spire tower                                                                                                     |
| Forge Tokens + Spells          | ✅ Earn on victory; buy in Kaveh's Forge; cast in battle HUD                                                                                                      |
| Paid power store (stub IAP)    | ✅ Tower, spells, token packs via StoreService                                                                                                                      |
| Automated tests                | ✅ GUT v9.6.0 (`tests/`), ContentValidator, SaveMigration, GitHub Actions CI                                                                                      |
| Khan 1 map art                 | ✅ `art/maps/level_01.jpg` + geometry override in `resources/data/levels/level_01.tres`; battle hides green Terrain fallback when map sprite loads                |
| Battle camera / HUD (Khan 1)   | ✅ Full-map fit-locked view; compact HUD; build radial (afford-gated) + manage radial on pad tap; bottom tower bar removed |
| Map editor (dev)               | ✅ Multi-route + multi-spawn editor; `PathRouteData` / `SpawnPointData` in level `.tres`; battle resolves `route_id` / `spawn_id` per wave group |

---

## Milestone alignment

| Milestone | Status | Notes                                                                                                    |
| --------- | ------ | -------------------------------------------------------------------------------------------------------- |
| **M0–M3** | ✅     | Khan 1 slice, corruption, Lion boss telegraphs                                                           |
| **M4**    | 🟡     | Khan 1 production map wired; multi-route/spawn map editor + battle routing; other maps still placeholders |
| **M5**    | ✅     | Pardeh enforced, 8 Fate cards aligned, objectives on results, relics in roguelite                        |
| **M6**    | ✅     | ContentCatalog, validators, smoke_test expanded, save v4                                                 |
| **M7**    | ✅     | Per-Khan enemies/waves, boss phase logic, Zal on Khans 2–3                                               |
| **M8**    | 🟡     | Accessibility + stubs; platform IAP/crash SDK deferred                                                   |

**Product gate:** still validate voluntary **Khan 1 replay** on device before marketing scale.

---

## How to run

1. Open repo root in **Godot 4.6** → **F5**.
2. **Play** → tutorial (first time) → world map → campaign Khans 1–7 → Damavand.
3. Forge Elite at **Kaveh's Forge** (world map button) to unlock **Hunt Zahhak** after 7 seals.
4. **Roguelite Path** — 5-node run with relic picks.
5. **Map editor (debug)** — F6 on `scenes/tools/map_editor.tscn`, or main menu **[DEV] Map Editor** → multiple routes/spawns, pads, gate → **Save .tres** → `resources/data/levels/{level_id}.tres`.

```powershell
powershell -File tools/validate_resources.ps1
godot --headless --path . --import --quit
godot --headless --path . -s res://addons/gut/gut_cmdln.gd -gconfig=res://.gutconfig.json
godot --headless --path . --script res://tools/smoke_test.gd
```

In the editor: **Project → Tools → GUT** (bottom panel) → Run All.

---

## Logic fixes (2026-06-05 audit)

- Battle map art: opaque `Terrain` ColorRect no longer covers `MapBackground` when `map_sprite_path` resolves
- Battle camera: medium maps fit-lock to full 1280×720 canvas; pan/zoom disabled until `uses_large_map_camera`
- Battle HUD: compact top/bottom bars; minimap/threat hidden when map fully visible; build radial disables unaffordable towers; occupied pad opens manage radial (level, upgrade, sell, purify)
- Build pads: circular hammer-style markers; path/gate dev overlays hidden when map art loads
- Map editor: multi-route polylines + multi-spawn markers; optional wave `route_id` / `spawn_id`; legacy `path_points` synced on save
- Wave manager waits for enemy clear before Pardeh / next wave
- Per-spawn `EnemyData`/`HeroData` duplicate — no shared catalog mutation
- Boss debuffs cleared on death; pool reuse resets boss controller
- Tutorial Continue requires victory; world map shows hunt/forge alerts
- Objectives evaluated at victory (no_leaks / no_hijack / cleanse_twice); **Hero's Vow** offered every 10 waves (Accept/Decline) with HUD chip + results tally
- Tutorial adds objective, morale, and boss-warning steps; `ContextualHintController` teaches tower panel, forge, early wave call, and Sacred Tether once per save

## Known deferrals

- Production art/audio (placeholders sufficient for logic QA)
- Projectile-on-impact damage (instant damage today; cosmetic projectiles)
- Full 43 Fate card pool; extra heroes (Gordafarid, Esfandiyar, …)
- Company splash scene (boot → menu directly today)
- Platform IAP, crash SDK, Simorgh continue, Zervan Dial rewind
