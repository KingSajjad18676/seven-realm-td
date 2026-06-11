# Entities, Gameplay & Assets — Shahnameh TD

**Last updated:** 2026-06-11  
**Purpose:** **All towers (every phase)**, **all campaign maps/tilesets**, entities in the repo, gameplay rules, and gameplay assets still needed. **AI image prompts:** [prompts/README.md](../../prompts/README.md) (per-asset specs by phase). Style canon: [design/01-art-phases.md](../design/01-art-phases.md) · [art/pipeline.md](../art/pipeline.md).

**Repo truth:** [engineering/project-status.md](../engineering/project-status.md) · [engineering/implementation-tracker.md](../engineering/implementation-tracker.md)

---

## 1. Which doc to read

| Need | Document |
|------|----------|
| **This file** | **§5 all towers**, **§6 all maps**, built entities, assets needed, doc map |
| **Full mechanics** (all systems, formulas, post-launch) | [spec/gameplay.md](gameplay.md) |
| **Design UX** (pillars, towers, maps, bosses, replay) | [design/02-gameplay-ux.md](../design/02-gameplay-ux.md) |
| **Product scope & Khan 1 gate** | [design/00-project-index.md](../design/00-project-index.md) · [product/prd.md](../product/prd.md) |
| **Code ownership & battle flow** | [engineering/game-logic.md](../engineering/game-logic.md) |
| **Scenes, autoloads, save** | [engineering/handoff.md](../engineering/handoff.md) · [engineering/architecture.md](../engineering/architecture.md) |
| **Player flow + meta features** | [art/content-checklist.md](../art/content-checklist.md) (§1–6 gameplay; ignore §7 art) |
| **Milestones M0–M8** | [design/04-production-roadmap.md](../design/04-production-roadmap.md) |

**PDF extracts (reference):** [docs/_source/README_02_extracted.txt](../_source/README_02_extracted.txt) (gameplay design)

---

## 2. Game identity (short)

- **Genre:** Active 2D tower-defense roguelite, landscape mobile (Godot 4.6). Market title: **Rostam 7 Labours: Shahname TD**.
- **Campaign:** Seven Labours of Rostam + **Damavand Binding** (8 battlefields); each map has an additive **Labour Mode** overlay (campaign only).
- **First production gate:** Khan 1 only until voluntary replay is proven.
- **Signature systems:** Regional corruption + tower hijack, Sacred Fire cleanse, Pardeh Break / Fate cards (boon + curse).
- **Stable IDs:** `lowercase_snake_case` in `.tres` / runtime catalog — never display names in gameplay code.

**Three pillars**

| Pillar | Player-facing |
|--------|----------------|
| Sacred Fire vs Corruption | Regions have light; darkness weakens or hijacks towers |
| Fate Weaving | Pardeh Break picks: reward + cost |
| Morale | Battle momentum meter — applied at battle start; vow honor/break |

---

## 3. Core battle loop (implemented today)

1. Load `LevelData` → path, build spots, regions, waves.
2. **PreBattle:** place towers (gold), move hero (**virtual stick**), manual combat, optional cleanse (Sacred Fire).
3. **Start wave** → enemies spawn, path to gate.
4. Towers attack; corruptors pressure regions; at light **0** tower **hijacks** (attacks allies) until cleansed.
5. Hero fights manually (Attack / Heavy / Dodge / Skill); leaks reduce **lives**.
6. Every **5 cleared waves** → **Pardeh Break** → pick 1 of 3 **Fate cards** (campaign; tutorial uses a scripted break).
7. Mini-boss every 10th wave; campaign boss on final wave → **Replay** or return to world map.

**Currencies in battle**

| ID | Role |
|----|------|
| `gold` | Build towers |
| `lives` | Gate integrity |
| `sacred_fire` | Cleanse regions / anti-hijack |

**Meta (outside battle):** per-tower **Star Iron** → **Kaveh's Forge** (permanent damage/range levels 1–30 + 5 elite steps). Not the same as in-battle **Ancestral Forge** hybrids (deferred).

---

## 4. Data model (Resource types)

| Resource | Script | Key ID field | Loaded by |
|----------|--------|--------------|-----------|
| `TowerData` | `scripts/data/tower_data.gd` | `tower_id` | `ContentRegistry` |
| `EnemyData` | `scripts/data/enemy_data.gd` | `enemy_id` | `ContentRegistry` |
| `HeroData` | `scripts/data/hero_data.gd` | `hero_id` | `ContentRegistry` |
| `LevelData` | `scripts/data/level_data.gd` | `level_id` | `ContentRegistry` |
| `WaveData` | `scripts/data/wave_data.gd` | `wave_id` | embedded in level |
| `FateCardData` | `scripts/data/fate_card_data.gd` | `card_id` | `ContentRegistry` |
| `BootstrapContent` | `scripts/data/bootstrap_content.gd` | — | `res://resources/bootstrap_content.tres` or runtime fallback |

**Runtime catalog:** `scripts/meta/content_registry.gd` — primary content from `ContentCatalog.build_bootstrap()`; sparse `resources/data/` overrides merged at load.

**Enums:** `scripts/core/game_enums.gd` — `BattleState`, `TowerFamily`, `RegionLightState`, `HijackPhase`, `DamageType`, `TargetMode`, `EnemyTag`.

---

## 5. All towers (every production phase)

Canonical `tower_id` list from [design/01](../design/01-art-phases.md) Phase 1–2 and [spec/gameplay.md](gameplay.md). **Every tower** needs base art + six animation states unless noted: `idle`, `attack`, `construction`, `corruption_warning`, `hijacked`, `purification` ([design/01](../design/01-art-phases.md) §8.3).

| tower_id | Display name | Art phase | Tower kind | Family (design) | In repo code | Role |
|----------|--------------|-----------|------------|-----------------|--------------|------|
| `tower_archer` | Archer Tower | **1** | Starter | Arrow / `ARCHER` | ✅ | Fast single-target DPS |
| `tower_sacred_fire` | Sacred Fire Tower | **1** | Starter | Fire / `SACRED_FIRE` | ✅ | Burn, cleanse synergy, Sacred Fire |
| `tower_heavy` | Heavy Tower | **1** | Starter | Siege / `HEAVY` | ✅ | Armor break, impact |
| `tower_control` | Control Tower | **1** | Starter | Command / `CONTROL` | ✅ | Slow, stagger, path control |
| `tower_zahhak_serpent` | Serpent Spire | **5** | Reward | Fire / `SACRED_FIRE` | ✅ | Twin venom, Hunger AS; horde-clear or IAP |
| `tower_rostam_barracks` | Rostam Tahmtan Barracks | **5** | Reward | Barracks / `BARRACKS` | ✅ | Ally blockers; 7 seals or IAP |
| `tower_support` | Support Tower | **2** | Advanced | Support | ❌ | Range, speed, repair, adjacent utility |
| `tower_mystic` | Mystic Tower | **2** | Advanced | Mystic | ❌ | Corruption response, magical utility |
| `tower_flame_archer` | Flame Archer | **2** | Forge unlock | Fire + Arrow | ✅ | Rapid burn stacking; Star Iron `iron_serpent` |
| `tower_volcano_ram` | Volcano Ram | **2** | Forge unlock | Fire + Siege | ✅ | Heavy explosive anti-armor; Star Iron `iron_volcano` |
| `tower_qanat_weaver` | Qanat Weaver | **2** | Ancestral hybrid | Control + utility | ❌ | Slow, reposition, route support |
| `tower_derafsh_bastion` | Derafsh Bastion | **2** | Ancestral hybrid | Command + defense | ❌ | Morale and defensive aura |
| `tower_azar_oracle` | Azar Oracle | **2** | Ancestral hybrid | Fire + Sacred | ❌ | Sacred Fire economy, purification |
| `tower_phoenix_bow` | Phoenix Bow | **2** | Ancestral hybrid | Fire + Arrow | ❌ | Example hybrid in code spec ([gameplay.md](gameplay.md) §6); distinct merged silhouette — may align with `tower_flame_archer` recipe |

**Full-game families** ([visual-vfx.md](../art/visual-vfx.md)) — author as `tower_*` when added; IDs not yet in art bible:

| Planned family | Silhouette (design) | Suggested ID when authored |
|----------------|---------------------|----------------------------|
| Barracks | Tent / gate, blocker units | `tower_rostam_barracks` ✅ (Rostam Tahmtan Barracks) |
| Shrine | Dome + Simorgh motif | `tower_shrine` |
| Forge (Damavand) | Anvil + chain; Hunt binding | `tower_forge` |

**Phase 3+:** tower skins in cosmetic previews (`cosmetic_tower_skin_preview`) — not new gameplay towers.

**Kaveh's Forge (meta):** upgrades the eleven `tower_id` rows above via `forge_material_id` — not separate battlefield entities.

---

## 6. All maps and tilesets (every production phase)

Eight campaign battlefields + tutorial graybox ([design/00](../design/00-project-index.md), [design/02](../design/02-gameplay-ux.md) §13). Large maps use **layered TileMaps**, staged sectors, camera anchors ([design/01](../design/01-art-phases.md) §6).

| Art phase | `level_id` (gameplay) | `map_id` (art package) | Display name | Grid | Scale | `tileset_id` | Boss (campaign) | Labour mode | In repo |
|-----------|----------------------|--------------------------|--------------|------|-------|--------------|-----------------|-------------|---------|
| **0–1** | `level_00_tutorial` | `map_khan_01_lion_rakhsh` *(shared layout)* | Sacred Fire Training | 32×18 | Medium | `tileset_woodland` | — (tutorial waves) | — | ✅ level only |
| **1** | `level_01` | `map_khan_01_lion_rakhsh` | Labour 1 — Lion and Rakhsh | 32×18 | Medium | `tileset_woodland` | Lion of the First Khan | `mode_lion` | ✅ logic + map art (`level_01.tres`, `art/maps/campaign/khan_01_map.png`) |
| **2** | `level_02` | `map_khan_02_desert_thirst` | Labour 2 — Desert of Thirst | 36×20 | Medium | `tileset_desert` | Manifestation of Thirst | `mode_thirst` | ✅ logic; 🟡 art |
| **2** | `level_03` | `map_khan_03_azhdaha_canyon` | Labour 3 — Azhdaha Canyon | 40×22 | Medium-large | `tileset_dragon_canyon` | Azhdaha | `mode_dragon` | ✅ logic; 🟡 art |
| **2** | `level_04` | `map_khan_04_sorceress_feast` | Labour 4 — Sorceress Feast | 42×24 | Medium-large | `tileset_enchanted_glade` | Sorceress (illusion + fiend) | `mode_temptress` | ✅ logic; 🟡 art |
| **2** | `level_05` | `map_khan_05_olad_camp` | Labour 5 — Olad Camp | 48×27 | Large | `tileset_mountain_camp` | Olad champion | `mode_demons` | ✅ logic; 🟡 art |
| **2** | `level_06` | `map_khan_06_arzhang_fortress` | Labour 6 — Arzhang Fortress | 52×30 | Large | `tileset_div_fortress` | Arzhang Div | `mode_rescue` | ✅ logic; 🟡 art |
| **2** | `level_07` | `map_khan_07_white_div_cavern` | Labour 7 — White Div Cavern | 56×32 | Very large | `tileset_white_div_cavern` | Div-e Sepid | `mode_blindness` | ✅ logic; 🟡 art |
| **5** | `level_08_damavand` *(typical)* | `map_damavand_binding` | Damavand Binding (finale) | 64×36 | Very large | `tileset_damavand` | Zahhak binding sequence | `mode_zahhak` | ✅ logic; 🟡 art |
| — | `level_throne_arena` | — | Defend the Throne arena | radial | Arena | — | — | — | ✅ logic; 🟡 art |

**Hunt mode (Phase 5):** repeatable survival — may use `level_hunt` + Damavand assets (`boss_zahhak`, anchor VFX); not a ninth campaign Khan map.

**Per-map deliverables (each `map_id`):** terrain, path, build pads, regional-light sectors, corruption mask, collision, camera anchors; sector overlays on large maps ([design/01](../design/01-art-phases.md) §5.5).

**Shared Khan 1 environment assets (Phase 1):** `tileset_woodland`, `props_shared_vertical_slice` (16 props — design/01 §8.5).

**Phase 2 environment animations (per biome):** `env_brazier_flame`, `env_corrupted_brazier`, `env_qanat_flow`, `env_stream_ripple`, `env_desert_heat_distortion`, `env_sand_drift`, `env_dragon_scorch_embers`, `env_illusion_shimmer`, `env_fortress_banner_sway`, `env_cavern_mist`, `env_falling_cave_dust`.

---

## 7. Entities in repo today (built)

**Source:** `scripts/meta/content_catalog.gd` (primary) + sparse `resources/data/` overrides.  
**Player-facing map/wave summary:** [product/main-gameplay.md](../product/main-gameplay.md) §5.

### 7.1 Heroes (3)

| hero_id | display_name | Used in | Notes |
|---------|--------------|---------|-------|
| `rostam` | Rostam | Campaign default; L1, L4–7, Damavand; co-op host | Naft path traps + SF ignition; Rakhsh mount |
| `zal` | Zal | Labours 2–3; Brothers in Arms co-op pick | Alternate campaign hero |
| `sohrab` | Sohrab | Brothers in Arms co-op pick only | Second-player hero |

**Design target (not in repo):** Gordafarid, Esfandiyar, Kaveh, Simorgh — [design/02](../design/02-gameplay-ux.md) §12.

---

### 7.2 Towers (8)

| tower_id | family | forge_material_id | Unlock / notes |
|----------|--------|-------------------|----------------|
| `tower_archer` | ARCHER | `iron_falcon` | Starter |
| `tower_sacred_fire` | SACRED_FIRE | `iron_ember` | Starter |
| `tower_heavy` | HEAVY | `iron_anvil` | Starter |
| `tower_control` | CONTROL | `iron_frost` | Starter |
| `tower_flame_archer` | SACRED_FIRE | `iron_serpent` | Kaveh's Forge Star Iron unlock |
| `tower_volcano_ram` | HEAVY | `iron_volcano` | Kaveh's Forge Star Iron unlock |
| `tower_zahhak_serpent` | SACRED_FIRE | — | Horde 8/8 clears or IAP; twin venom + Hunger AS |
| `tower_rostam_barracks` | BARRACKS | — | 7 Labour seals or IAP; ally summons |

**Ally units (barracks):**

| unit_id | Role |
|---------|------|
| `unit_zabul_vanguard` | Cleave melee; reduced burn/corruptor/fire damage |
| `unit_bull_mace_bearer` | Armor shatter + stun; at barracks max level |

---

### 7.3 Enemies (22)

**Shared grunts:** `enemy_jackal`, `enemy_boar`, `enemy_corruptor`

| enemy_id | Labour / use | Role |
|----------|--------------|------|
| `enemy_mirage_shade` | L2 | Runner / illusion |
| `enemy_salt_crust_brute` | L2 | Mini-boss |
| `enemy_canyon_serpent` | L3 | Burrow telegraph |
| `enemy_scorched_hound` | L3 | Rush |
| `enemy_illusion_attendant` | L4 | Decoy |
| `enemy_feast_shade` | L4 | Mini-boss |
| `enemy_mountain_raider` | L5 | Mini-boss |
| `enemy_mountain_archer` | L5 | Ranged |
| `enemy_div_infantry` | L5–6 | Grunt |
| `enemy_div_brute` | L6 | Mini-boss |
| `enemy_div_corruptor` | L6–7 | Corruptor |
| `enemy_white_div_thrall` | L7 | Grunt |
| `enemy_cavern_boulder_brute` | L7 | Mini-boss |
| `enemy_zahhak_serpent_guard` | Damavand | Guard |
| `enemy_chainbreaker_div` | Damavand | Mini-boss |

**Bosses:** `enemy_lion_boss`, `enemy_thirst_manifest`, `enemy_azhdaha`, `enemy_sorceress`, `enemy_olad_champion`, `enemy_arzhang_div`, `enemy_white_div`, `enemy_zahhak`

---

### 7.4 Levels (10)

| level_id | Waves (campaign) | Hero | Labour mode |
|----------|------------------|------|-------------|
| `level_00_tutorial` | 2 | Rostam | — |
| `level_01` … `level_07` | 30–90 (`20 + index×10`) | Rostam / Zal (L2–3) | `mode_lion` … `mode_blindness` |
| `level_08_damavand` | 100 | Rostam | `mode_zahhak` |
| `level_throne_arena` | 15 (Throne mode) | Rostam | — |

Waves are **procedural** via `CampaignWaveTemplates` (10-wave master blocks). See [main-gameplay.md](../product/main-gameplay.md) §5.

---

### 7.5 Fate cards (8 wired / 43 design target)

| card_id | title |
|---------|-------|
| `card_flame_of_azar` | Flame of Azar |
| `card_golden_bounty` | Golden Bounty |
| `card_sacred_wind` | Sacred Wind |
| `card_iron_rain` | Iron Rain |
| `card_derafsh_oath` | Derafsh Oath |
| `card_qanat_blessing` | Qanat Blessing |
| `card_lion_s_legacy` | Lion's Legacy |
| `card_twilight_pact` | Twilight Pact |

---

### 7.6 Spells (6)

`spell_gold_rush`, `spell_purify_blast`, `spell_morale_surge`, `spell_fire_storm`, `spell_tower_overcharge`, `spell_serpent_bane`

Purchased with Forge Tokens at Kaveh's Forge; cast from battle HUD.

---

### 7.7 Relics (7)

`relic_derafsh_fragment`, `relic_ember_coil`, `relic_qanat_stone`, `relic_cup_of_jamshid`, `relic_flame_of_hushang`, `relic_feridun_mace`, `relic_ring_of_kay_kavus`

Per-tower slots via `RunModifierService`; shrine + alternating Pardeh discovery. `.tres` overrides: `relic_cup_of_jamshid`, `relic_flame_of_hushang`.

---

### 7.8 Companions (3 — Campaign Run shrine)

`companion_royal_cheetah`, `companion_simurgh_fledgling`, `companion_zavareh` (+ `.tres` overrides). Rostam's **Rakhsh** mount is separate (`rakhsh_mount_controller.gd`).

---

### 7.9 Equipment (28 pieces / 7 sets)

Sets: `set_rakhsh_vigor`, `set_thirst_turan`, `set_azhdaha_scale`, `set_mazandaran_venom`, `set_kaveh_iron`, `set_arzhang_fury`, `set_simurgh_talon`

Boss drops: weapon + armor per Labour clear. Daily mission chest: helm + talisman. Full IDs in `content_catalog.gd` → `build_equipment_pieces()`.

---

### 7.10 Daily missions (10 pool, 3 active/day)

`mission_slayer_demons`, `mission_untouchable`, `mission_master_architect`, `mission_hoarder`, `mission_light_bringer`, `mission_pristine_defense`, `mission_blacksmith_patron`, `mission_close_quarters`, `mission_rain_of_arrows`, `mission_earth_shaker`

---

## 8. Design target beyond built (future content)

**Built campaign roster:** see **§7.3–7.4**. Below: extra enemy/boss variants and families not yet in `content_catalog.gd`.

| Planned | Notes |
|---------|-------|
| `enemy_div_stone_thrower`, `enemy_div_sorcerer`, `enemy_div_standard_bearer` | Labour 6 design extras |
| `enemy_scorched_cave_hound` | Art alias for `enemy_scorched_hound` |
| `tower_support`, `tower_mystic`, hybrid recipes (Qanat Weaver, Derafsh Bastion, …) | Ancestral Forge hybrids — deferred |
| `tower_shrine`, `tower_forge` | Shrine + Damavand Forge families |
| 35 additional Fate cards | 8/43 wired |
| Premium hero roster | Gordafarid, Esfandiyar, Kaveh, Simorgh |

---

## 9. Play modes and launch flags

| Mode | `BattleLaunchData` flag | Labour overlay |
|------|-------------------------|----------------|
| Campaign | default (`is_campaign_mode()`) | ✅ |
| Campaign Run | `is_campaign_run` | ❌ |
| Horde | `is_horde_mode` | ❌ |
| Endless | `is_endless_mode` | ❌ |
| Hunt | `is_hunt_mode` | ✅ `mode_zahhak` |
| Daily Tale | `is_daily_tale` | ❌ |
| Brothers in Arms | `is_brothers_mode` | ❌ |
| Defend the Throne | `is_throne_defense_mode` | ❌ |
| Haft-Khan Gauntlet | `is_gauntlet_mode` | ✅ per boss |
| Roguelite (legacy) | `is_roguelite_run` | ❌ — deprecated |

**Scavenging** (`is_scavenge_mode()`): Campaign, Campaign Run, Horde, Hunt, Brothers, Throne.

Detail: [product/main-gameplay.md](../product/main-gameplay.md) §4–6.

---

## 10. Gameplay systems

### 10.1 Built (✅ in repo)

| System | Owner / notes |
|--------|----------------|
| Wave spawn & win/loss | `WaveManager`, `BattleStateController`, `EnemySpawner` |
| 10-wave campaign templates | `CampaignWaveTemplates` — Bait/Trap/Hijack/Push roles |
| Tower place / radial build & manage | `TowerManager`, `TowerRadialBuildController`, range ring |
| Gold, lives, Sacred Fire, materials | `BattleEconomy`, `LootDropManager` |
| Regional light & corruption | `MapLightManager` |
| Tower hijack + purify | `TowerController` |
| Sacred Tether | Manage radial **Tether** when hero in range (`tower_radial_build_controller.gd`) |
| Hero action controls | `VirtualJoystick`, `HeroActionHud`, manual combat in `HeroController` |
| Battle camera | `TouchCamera`, `MapCameraUtils` — locked COVER (medium) vs pan/zoom (large); `playable_screen_rect` HUD anchoring |
| Battle HUD polish | Hero chip, objective chip, boss HP bar, pause Restart/Settings |
| Audio (placeholder tones) | `AudioManager` — Music/SFX buses, procedural tones |
| Morale + Hero's Vow | `MoraleController`, `VowOfferController` |
| Pardeh / Fate + relic alternation | `FateDraftController` — every 5 cleared waves |
| Tower Resonance | `TowerResonanceController` — adjacent combos |
| Labour modes (8) | `scripts/battle/labours/` |
| All 8 campaign bosses + phases | `boss_controller_factory.gd` |
| Kaveh's Forge + soft gate L3+ | `ForgeService` |
| Campaign Run + Shroud | `CampaignRunState`, `CampaignRunGenerator` |
| Hunt binding | `HuntController` |
| Spells + Forge Tokens | `SpellController`, save v5 |
| Equipment battle rules | `EquipmentBattleService` |
| Co-op | `CoopPlayerManager` |
| Gauntlet timer + ghost | `GauntletRunState`, battle HUD |
| Naft traps | `NaftTrapController` |
| Daily missions | `DailyMissionService` |
| Stub IAP store | `StoreService` |
| GUT + ContentValidator + CI | `tests/`, GitHub Actions |

### 10.2 Design target (❌ or stub — see tracker)

| System | Summary |
|--------|---------|
| Ancestral Forge hybrids | Adjacent tower recipes (Phoenix Bow, etc.) |
| Zervan Dial rewind | Snapshot rewind |
| Simorgh continue | One-per-run feather |
| Epic Couplet / Rhyme Window | Timed skill bonus |
| Ahriman Director | Boss adapts to dominant `TowerFamily` |
| Dynamic A* pathing | Light-weighted paths (flag exists per level) |
| Qanat fast travel | Level nodes network |
| Platform IAP / crash SDK | Stub only |
| 35 extra Fate cards | Art + logic |

Detail: [spec/gameplay.md](gameplay.md) · [engineering/implementation-tracker.md](../engineering/implementation-tracker.md).

---

## 11. Battle entity runtime state

Summarized from [spec/gameplay.md](gameplay.md) §2 — what controllers track beyond `.tres` design:

**Enemy:** current HP, speed, armor, path progress, status effects, rewards, tags, boss resistances, path recalc count.

**Tower:** level, family, hybrid flag, cooldown, range, damage (light + forge scaled), hijack flag, tether multiplier, health (for purge).

**Hero:** HP, position, energy, tether target, skill cooldown, cleanse aura tick on region.

**Region:** light level 0–100, stable/pressured/critical/collapsed, permanent corruption flag.

---

## 12. Damage, status, tower families (design)

**Damage types:** Physical, Pierce, Magic, Fire, Sacred, Siege, Poison, True (rare).

**Status:** Burn, Slow, Stun, Poison, Armor Break, Shield, HoT, Corruption, Cleanse, Fear, Reveal Hidden.

**Tower families (full game — enum in code is slice subset)**

| Family | Role |
|--------|------|
| Arrow / ARCHER | Physical ranged |
| Fire / SACRED_FIRE | Burn, sacred, cleanse synergy |
| Siege / HEAVY | Splash, armor break |
| Barracks | Blockers (future) |
| Shrine | Cleanse support |
| Command | Morale aura |
| Forge | Damavand anchors (Hunt) |
| Hybrid | Combo outputs |

Code enum today: `ARCHER`, `SACRED_FIRE`, `HEAVY`, `CONTROL`, `FORGE`.

---

## 13. Meta progression (forge mapping)

| Enemy | Drops material for tower |
|-------|--------------------------|
| Jackal | Falcon → Archer (`iron_falcon`) |
| Corruptor | Ember → Sacred Fire (`iron_ember`) |
| Boar | Anvil → Heavy (`iron_anvil`) |
| Lion boss | Frost → Control (`iron_frost`) |

Forge: levels 1–30 (+4% damage, +1% range per level); visual tier every 10 levels; elite path 5 steps after 30. **Damavand** launch requires ≥1 elite tower (`ForgeService.can_enter_damavand()`).

---

## 14. Scenes & prefabs (entity wiring)

| Entity | Prefab scene |
|--------|----------------|
| Tower | `res://scenes/prefabs/tower.tscn` |
| Enemy | `res://scenes/prefabs/enemy.tscn` |
| Hero | `res://scenes/prefabs/hero.tscn` |
| Projectile | `res://scenes/prefabs/projectile.tscn` |
| Build spot | `res://scenes/prefabs/build_spot.tscn` |
| Battle root | `res://scenes/battle/battle.tscn` |

Battle wiring: `BattleBootstrap` → `BattleContext` (economy, waves, towers, hero, corruption, HUD).

---

## 15. Adding a new entity (engineering)

1. Add `TowerData` / `EnemyData` / etc. to `bootstrap_content.tres` **or** extend `_build_*()` in `content_registry.gd`.
2. Use new stable `*_id` string; reference only IDs in scenes/scripts.
3. Run `powershell -File tools/validate_resources.ps1`.
4. Update [implementation-tracker.md](../engineering/implementation-tracker.md) and this file if the catalog changes.

Prompt for content authoring: [prompts/10-add-new-content.prompt.md](../../prompts/10-add-new-content.prompt.md).

---

## 16. Khan 1 acceptance (gameplay gate)

From [design/02](../design/02-gameplay-ux.md) §20:

- Four towers feel distinct; route readable; Rostam movement matters.
- Sacred Fire and corruption understood before collapse; hijack feels fair.
- Lion changes player behavior; defeat is clear; **one-tap replay**.
- **Voluntary replay** without prompting — primary product signal.

---

## 17. Code ID vs art asset ID

Gameplay code uses IDs in `ContentRegistry`. Production art uses stable asset IDs from [design/01](../design/01-art-phases.md). Wire art in `.tres` / scene sprites — do not rename code IDs without a data migration.

| Code (`enemy_id` / etc.) | Art / design asset ID | Notes |
|--------------------------|----------------------|--------|
| `rostam` | `hero_rostam` | Hero |
| `enemy_jackal` | `enemy_corrupted_jackal` | Grunt |
| `enemy_boar` | `enemy_corrupted_boar` | Brute |
| `enemy_corruptor` | (corruptor archetype) | Same role |
| `enemy_lion_boss` | `boss_mythic_lion` | Khan 1 boss |
| `tower_*` | `tower_*` | Same IDs |
| `level_01` | `map_khan_01_lion_rakhsh` | Map package |

---

## 18. Gameplay assets needed (Khan 1 — M4)

**Status today:** graybox placeholders (`ColorRect` / tinted sprites in prefabs). **Import path:** `art/_placeholders/` until production files land ([project-status.md](../engineering/project-status.md)).

**Technical defaults:** [art/pipeline.md](../art/pipeline.md) — pivots bottom-center (units/towers), center (VFX/projectiles); strips **8×1**; tower cells **256×256**; small enemies **192×192**; hero **256×256**; boss **384×384**; map tiles **128×128**.

### 18.1 Characters & creatures (Phase 0–1)

| Asset ID | Type | Animations / deliverable | Priority | Wired in code |
|----------|------|--------------------------|----------|---------------|
| `hero_rostam` | Hero base | — | P0 | `rostam` (color blob) |
| `hero_rostam_idle` | Strip 8×1 @ 256² | idle | P0 | — |
| `hero_rostam_walk` | Strip 8×1 @ 256² | walk | P0 | move |
| `hero_rostam_basic_attack` | Strip 8×1 @ 256² | attack | P0 | combat |
| `companion_rakhsh` | Companion base + strips | idle, run, warning_stomp | P1 | narrative only |
| `enemy_corrupted_jackal` | Enemy base + strips | run, bite_attack, defeat | P1 | `enemy_jackal` |
| `enemy_corrupted_boar` | Enemy base + strips | walk, charge, defeat | P1 | `enemy_boar` |
| `enemy_corruptor` | Enemy base + strips | run, corrupt, defeat | P1 | `enemy_corruptor` |
| `boss_mythic_lion` | Boss base + strips | idle, run, claw_attack, pounce_attack, roar, defeat | P1 | `enemy_lion_boss` |

### 18.2 Towers (each: base + 8×1 strips per state)

Full tower list: **§5**. Khan 1 needs only the four starters below.

| Asset ID | States required | Priority | Wired in code |
|----------|-----------------|----------|---------------|
| `tower_archer` | idle, attack, construction, corruption_warning, hijacked, purification | P1 | ✅ behavior |
| `tower_sacred_fire` | same six states | P1 | ✅ + burn |
| `tower_heavy` | same six states | P1 | ✅ + armor_break |
| `tower_control` | same six states | P1 | ✅ + slow |

**Readability:** hijacked state must change silhouette/tint, not stats only ([visual-vfx.md](../art/visual-vfx.md) §3).

### 18.3 Battle map & environment (Khan 1)

Full map list: **§6**.

| Asset ID | Type | Contents | Priority |
|----------|------|----------|----------|
| `map_khan_01_lion_rakhsh` | Map package 32×18 | Layers: terrain, path, 8 build pads, 3 light sectors, spawn UR, gate LL, lion arena, brazier point | P0 |
| `tileset_woodland` | Tileset atlas 1024² (8×8×128²) | grass, path, stream, cliffs, corruption/sacred transitions | P1 |
| `props_shared_vertical_slice` | Prop atlas | brazier lit/extinguished/corrupted, rocks, reeds, trees, hero-rest carpet, banner (no text), sacred marker, etc. (16 props — design/01 §8.5) | P1 |

### 18.4 VFX (signature systems — P0 for readability)

| Asset ID | Gameplay read | Priority | System |
|----------|---------------|----------|--------|
| `vfx_arrow_release` | Archer shot | P1 | combat |
| `vfx_arrow_impact` | Hit feedback | P1 | combat |
| `vfx_sacred_fire_cleanse` | Cleanse pulse | **P0** | Sacred Fire |
| `vfx_region_corruption_stage_01` | Ground veins | **P0** | corruption |
| `vfx_tower_hijack_start` | Hijack onset | **P0** | hijack |
| Regional darkness overlay | Per build-spot multiply sprite | **P0** | `MapLightManager` |
| Build-spot base tile | Neutral pad ground | P1 | placement |
| Sacred tether beam | Hero ↔ tower line | P1 | deferred code; art early |

### 18.5 UI (gameplay-facing)

| Asset ID | Use | Priority | Scene / notes |
|----------|-----|----------|---------------|
| `ui_battle_hud_prototype` | Phase 0 layout proof | P0 | validate zones |
| `ui_battle_hud` | Production HUD | P1 | `battle_hud` — lives, gold, SF, wave, build/manage radial + hero action cluster |
| HUD icon set | pause, 1×/2×, settings, cleanse, brazier | P1 | replaces text buttons |
| Hero portrait | Rostam HUD | P1 | bottom-left |
| Pardeh / Fate UI | 3 card frames + `card_*` art | P1 | every 5-wave block break |
| Victory / defeat frame | Results panel | P1 | end of run |
| Tutorial overlay art | First-launch training | P1 | `tutorial_overlay.tscn` |
| Company splash / main menu BG | Boot flow | P2 | meta |
| World map nodes | 7 Khans locked/unlocked/complete | P2 | campaign |

**Fate card art (match code IDs):**

| card_id | Title in code |
|---------|---------------|
| `card_flame_of_azar` | Flame of Azar |
| `card_golden_bounty` | Golden Bounty |
| `card_sacred_wind` | Sacred Wind |

### 18.6 Audio (gameplay)

| Asset | Use | Priority |
|-------|-----|----------|
| Battle music loop | Khan 1 fight | P1 |
| Boss sting | Lion wave | P1 |
| UI click, build, wave start | Feedback | P1 |
| Victory / defeat stinger | Results | P1 |
| Corruption warning / hijack warning | Signature tension | P1 |
| Menu music | Main menu | P2 |

---

## 18. Gameplay assets by phase (after Khan 1 gate)

Do not mass-produce until Phase 1 replay gate passes ([design/00](../design/00-project-index.md)).

| Phase | Towers (§5) | Maps / tilesets (§6) | Other gameplay assets |
|-------|-------------|----------------------|------------------------|
| **0** | — (Rostam only) | `map_khan_01_lion_rakhsh` prototype | `hero_rostam`, `ui_battle_hud_prototype` |
| **1** | 4 starters | `map_khan_01` + `tileset_woodland` + props | Khan 1 enemies, VFX §17.4, `ui_battle_hud` |
| **2** | `tower_support` … `tower_phoenix_bow` | `map_khan_02`…`07` + 6 tilesets | Heroes Zal/Gordafarid/Esfandiyar; bosses §8; boss VFX; env anims §6 |
| **3** | — | — | `ui_pardeh_break`, Fate cards (40+ IDs), relic icons, strategic-action cards |
| **4** | — | — | `ui_hero_hall`, `ui_tower_codex`, `ui_relic_collection`, `ui_narrators_book`, `ui_ancestral_forge`, portraits |
| **5** | `tower_forge` (when authored) | `map_damavand_binding`, `tileset_damavand` | `boss_zahhak`, Hunt/Endless/Daily UI, Damavand VFX |
| **6** | — | — | Settings, accessibility, splash, loading, audio |

**AI prompts for every row:** [prompts/README.md](../../prompts/README.md) (phase files 00–08).

---

## 19. Asset ↔ gameplay system matrix

| System | Minimum assets to read in play |
|--------|--------------------------------|
| Tower placement | All §5 towers on their phase + build card icons (4 in Khan 1) |
| Corruption | region overlay, stage-01 VFX, warning on tower |
| Hijack | hijack start VFX, hijacked tower state, recovery cleanse |
| Sacred Fire | SF meter icon, cleanse VFX, brazier props |
| Hero | world sprite, portrait, skill feedback |
| Boss | Lion telegraph (claw/pounce/roar anims) |
| Fate | 3 card frames + boon/curse visual split |
| Forge meta | Kaveh forge UI (can stay graybox longer) |

---

## Related

- Visual readability spec → [art/visual-vfx.md](../art/visual-vfx.md)
- AI prompts by phase → [prompts/README.md](../../prompts/README.md) · import rules → [art/pipeline.md](../art/pipeline.md)
- Monetization → [design/03-monetization.md](../design/03-monetization.md)
- Live-ops → [liveops/retention.md](../liveops/retention.md)
