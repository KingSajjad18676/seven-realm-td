# Project Status (Godot)

**Last updated:** 2026-06-11 (N2 projectile impact + perf overlay + threat-jump)  
**Milestones:** [design/04-production-roadmap.md](../design/04-production-roadmap.md) · **Identity:** [design/00-project-index.md](../design/00-project-index.md)

---

## Repo snapshot (honest)

| Item                           | Status                                                                                                                                                            |
| ------------------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Godot project                  | ✅ `project.godot` — **Rostam 7 Labours: Shahname TD**, landscape mobile                                                                                          |
| Main menu → world map → battle | ✅ Campaign, roguelite, endless, **horde**, **Brothers in Arms**, **Defend the Throne**, **Haft-Khan Gauntlet**, hunt, daily tale                                                                                                                 |
| Tutorial gate                  | ✅ Khan 1 locked until tutorial cleared                                                                                                                           |
| Khan 1 onboarding              | ✅ Tutorial teaches scavenging, materials banking, Campaign Run; contextual hints in battle (tower panel, forge, early call, tether)                            |
| Campaign levels                | ✅ Tutorial + **Labours 1–7** + Damavand; **30–100 block-templated waves** (+10 per Labour), **Pardeh every 5 waves**, mini-boss every 10th wave |
| **Labour Modes (campaign)**    | ✅ Additive per-map story overlays (`scripts/battle/labours/`) — Lion, Thirst, Dragon, Temptress, Demons, Rescue, Blindness, Zahhak |
| **Rostam Tahmtan Barracks**    | ✅ Unlock at 7 Labour seals or store IAP; summons Zabul Vanguard / Bull-Mace Bearer allies (in-battle upgrade) |
| **Serpent Spire behavior**     | ✅ Twin-target venom + Hunger attack-speed (horde-clear or store unlock; no Star Iron forge) |
| Hero's Vow (wave challenges)   | ✅ Optional Accept/Decline vow every 10 waves; honor = SF + morale; break = morale penalty (never fails battle) |
| Signature systems              | ✅ Corruption, hijack (SF purify), Pardeh/Fate (skip or pick), Morale at start, Sacred Tether via tower panel, **Tower Resonance** (adjacent combo buffs), free road-adjacent placement, **Rostam Naft path traps + Sacred Fire ignition** |
| Roguelite 5-node run (legacy)  | 🟡 Superseded by **Campaign Run** graph on world map; save migrates `roguelite_run` → `campaign_run`                                                             |
| **Campaign Run (branching)**   | ✅ `CampaignRunState` + graph on world map; skirmish / anvil / shrine / **Throne of Kavus** / labour boss / Damavand finale; save v6                                                     |
| **Ahriman's Shroud**           | ✅ Endgame Campaign Run hard mode — Damavand clear unlocks toggle; hidden nodes; SF reveal gate; shared run SF wallet into battles                                  |
| **Active material scavenging** | ✅ Physical `MaterialDrop` pickups; hero collection; unbanked HUD; defeat clears 100%; Pardeh **Retreat to Forge** banks loot                                    |
| **Rostam companions**          | ✅ Rakhsh mount (Rostam); Campaign Run Shrine pick: Royal Cheetah / Simurgh Fledgling / Zavareh (max 1 per run)                                                     |
| **Tower draft per run**        | ✅ Pre-run pick 3 from unlocked pool; mid-run +1 on elite nodes; `run_tower_ids` injected at battle bootstrap                                                      |
| **Relics of the Shahs**        | ✅ Per-tower relic slots (run/battle scoped); shrine / Pardeh / roguelite rest discovery; save v7 `tower_relic_slots`                                               |
| **Per-tower forge unlock**     | ✅ `unlock_material_cost` + Kaveh's Forge unlock rows (Flame Archer, Volcano Ram materials)                                                                      |
| Hunt for Zahhak                | ✅ 7 seals + Elite forge enforced in scene flow; binding shards weaken Zahhak                                                                                     |
| Campaign Damavand              | ✅ After Khan 7 clear; binding guards + chainbreakers before boss                                                                                                 |
| Kaveh's Forge                  | ✅ World map link; Elite notification unlocks Hunt                                                                                                                |
| **Forge progression gate**     | ✅ Soft difficulty from Labour 3+; expected forge curve in `ForgeService`; world map + defeat guidance; L1–2 unchanged                                            |
| Save v4                        | ✅ Hunt best, forge notification, roguelite run state, mode-aware battle saves                                                                                    |
| Save v5                        | ✅ Forge Tokens, spells owned, horde progress, unlocked towers, paid entitlements                                                                                 |
| Save v6                        | ✅ `campaign_run`, starter towers seeded in `unlocked_towers` pool                                                                                                |
| Save v7                        | ✅ `tower_relic_slots` + global `active_relic_ids`; migrates legacy `relic_ids`                                                                                  |
| Save v8                        | ✅ `gauntlet_best` personal-best splits + trace for ghost HUD                                                                                                    |
| Save v9                        | ✅ Haft-Khan equipment loadout + daily missions + mission lifetime stats                                                                                          |
| **Haft-Khan Gauntlet**         | ✅ 7-Labour boss rush; 3-tower draft; ms timer + ghost; Rush / early-call overwhelm; save v8 PB                                                                    |
| **Haft-Khan Equipment Sets**   | ✅ 7 sets × 4 pieces; boss + daily drops; set rules in battle; Equipment + Daily Missions UI on world map                                                         |
| **Daily Missions**             | ✅ 3/day rotation; 10-mission pool; Royal Bounty +3; loot chest → helm/talisman                                                                                   |
| Khan difficulty scaling        | ✅ Per-Khan HP/speed/count mults; **10-wave master block generator** (`CampaignWaveTemplates`) |
| Horde mode                     | ✅ 15 waves per Khan; act progression in horde/endless slices; clear all 8 unlocks Serpent Spire tower                                                                                                     |
| Forge Tokens + Spells          | ✅ Earn on victory; buy in Kaveh's Forge; cast in battle HUD                                                                                                      |
| Paid power store (IAP stub)    | ✅ `IapProvider` + combat/cosmetic SKUs via `StoreService`; restore flow wired                                                                                    |
| **Farr meta currency**         | ✅ Save v10 + `FarrService`; first clear / victory / daily mission earn; world map + battle HUD                                                                     |
| **Fate cards (16)**            | ✅ 8 new cards + effect wiring; `ContentValidator.MIN_FATE_CARDS = 16`                                                                                              |
| **Simorgh Feather continue**   | ✅ Once per campaign run at 0 lives; skipped in gauntlet/tutorial/throne                                                                                            |
| **Gordafarid + Esfandiyar**    | ✅ Heroes + `gordafarid_volley` / `esfandiyar_bulwark` skills; Labour 2 / 4 unlocks                                                                               |
| **Maps 2–8 geometry**          | ✅ `resources/data/levels/level_02.tres` … `level_08_damavand.tres` baked; placeholder map/loading generators                                                     |
| **Privacy + consent**          | ✅ Boot gate + settings link; `legal_links.gd`; analytics consent in save                                                                                         |
| **Cosmetics store**            | ✅ Cosmetics tab in Kaveh's Forge; `CosmeticService` tint overrides                                                                                                 |
| Automated tests                | ✅ GUT v9.6.0 (`tests/`), ContentValidator, **WaveSpawnValidator**, SaveMigration, GitHub Actions CI                                                                                      |
| Khan 1 map art                 | ✅ `art/maps/level_01.jpg` + geometry override in `resources/data/levels/level_01.tres`; battle hides green Terrain fallback when map sprite loads                |
| **Hero action controls**       | ✅ Virtual joystick (left); Attack / Heavy / Dodge / Skill (right); manual combat — no auto-attack; enemy telegraphed melee when lane-blocked |
| **In-battle hero leveling**    | ✅ `HeroLevelService` — XP per kill, Lv 1–10, +8% dmg / +10% HP per level; HUD level + XP bar |
| **Hero skill loadout**         | ✅ Pre-battle skill select on Equipment screen (5 skills incl. Gordafarid/Esfandiyar); persisted in save |
| **Battle HUD (Khan 1 polish)** | ✅ Hero chip (portrait + HP/XP/tether + skill readiness); alert priority queue; gate-hit feedback; region status chips (high contrast); subtitle overlay; objective/boss chips; action cluster; pause Restart + Settings |
| **Audio (placeholder tones)**  | ✅ Procedural SFX + menu loop; Music/SFX buses; settings sliders wired |
| **Naft traps wiring**          | ✅ `NaftTrapController` instantiated in `battle_bootstrap` for Rostam |
| Battle camera / HUD (Khan 1)   | ✅ Full-map fit-locked view; compact HUD; build/manage radial; range ring; virtual stick + action buttons; back navigation |
| Map editor (dev)               | ✅ Multi-route + multi-spawn editor; `PathRouteData` / `SpawnPointData` in level `.tres`; battle resolves `route_id` / `spawn_id` per wave group |
| Per-map battle preload         | ✅ `LevelAssetCollector` + threaded preload overlay before battle; map/enemy/hero/tower sprites + `battle.tscn` warmed per `level_id` |

---

## Milestone alignment

| Milestone | Status | Notes                                                                                                    |
| --------- | ------ | -------------------------------------------------------------------------------------------------------- |
| **M0–M3** | ✅     | Khan 1 slice, corruption, Lion boss telegraphs                                                           |
| **M4**    | 🟡     | Khan 1 production map + L2–8 baked geometry; illustrated art still placeholder pipeline                   |
| **M5**    | ✅     | Pardeh enforced, 8 Fate cards aligned, objectives on results, relics in roguelite                        |
| **M6**    | ✅     | ContentCatalog, validators, smoke_test expanded, save v4                                                 |
| **M7**    | ✅     | Per-Khan enemies/waves, boss phase logic, Zal on Khans 2–3                                               |
| **M8**    | 🟡     | Accessibility ✅; IAP/privacy/cosmetics/analytics plumbing ✅; live store SDK credentials deferred        |

**Product gate:** still validate voluntary **Khan 1 replay** on device before marketing scale.

---

## How to run

1. Open repo root in **Godot 4.6** → **F5**.
2. **Play** → tutorial (first time) → world map → campaign **Labours 1–7** → Damavand.
3. Forge Elite at **Kaveh's Forge** (world map button) to unlock **Hunt Zahhak** after **7 Labour seals**.
4. **Campaign Run** — branching graph (draft 3 towers, scavenge, reach Damavand). Legacy 5-node roguelite scene deprecated.
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
- Battle HUD: compact top/bottom bars; minimap/threat hidden when map fully visible; build radial disables unaffordable towers; occupied pad opens manage radial (level, upgrade, sell, purify); **attack-range ring** on pad select (preview on build, live on manage, grows on upgrade)
- Build pads: circular hammer-style markers; path/gate dev overlays hidden when map art loads
- Map editor: multi-route polylines + multi-spawn markers; optional wave `route_id` / `spawn_id`; legacy `path_points` synced on save
- Wave manager waits for enemy clear before Pardeh / next wave
- Per-spawn `EnemyData`/`HeroData` duplicate — no shared catalog mutation
- Boss debuffs cleared on death; pool reuse resets boss controller
- Tutorial Continue requires victory; world map shows hunt/forge alerts
- Objectives evaluated at victory (no_leaks / no_hijack / cleanse_twice); **Hero's Vow** offered every 10 waves (Accept/Decline) with HUD chip + results tally
- **Rostam 7 Labours rebrand:** player-facing "Khan" → "Labour"; project title `Rostam 7 Labours: Shahname TD`
- **LabourMode framework:** campaign-only additive hazards wired in `battle_bootstrap._attach_labour_mode`
- **Reward towers:** Barracks (7 seals / IAP); Serpent Spire twin venom + Hunger (8 horde clears / IAP); neither uses Star Iron forge materials
- **10-wave master block campaign waves:** `CampaignWaveTemplates` — Bait/Trap/Hijack/Push roles per 10-wave block; act progression per Labour; Pardeh every 5 cleared waves; Hero's Vow every 10 cleared waves
- **Forge progression gate:** `ForgeService.expected_forge_level_for()` drives Labour 3+ / Damavand / Horde HP+count scaling; replay earlier Labours for Star Iron; no hard map locks
- **Wave spawn audit:** [WAVE_SPAWN_AUDIT.md](../WAVE_SPAWN_AUDIT.md) — mode × map matrix; `WaveSpawnValidator` in smoke_test + debug menu (F3)

## Known deferrals

- Production illustrated art (placeholder PNG generators: `generate_khan1_placeholders.gd`, `generate_map_placeholders.gd`)
- Full ~43 Fate card pool (16 wired post-N3)
- Forge hybrids; Memory Div / Blood Oath run nodes; Zervan Dial rewind (not in codebase)
- Company splash scene (boot → menu directly today)
- Live Google Play Billing / StoreKit credentials and production analytics/crash HTTP endpoints
