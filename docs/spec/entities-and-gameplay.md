# Entities, Gameplay & Assets — Shahnameh TD

**Last updated:** 2026-06-06  
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
| Morale | Battle momentum (design target; not built in slice) |

---

## 3. Core battle loop (implemented today)

1. Load `LevelData` → path, build spots, regions, waves.
2. **PreBattle:** place towers (gold), move hero (tap ground), optional cleanse (Sacred Fire).
3. **Start wave** → enemies spawn, path to gate.
4. Towers attack; corruptors pressure regions; at light **0** tower **hijacks** (attacks allies) until cleansed.
5. Hero fights + skill; leaks reduce **lives**.
6. After wave 4 → **Pardeh Break** → pick 1 of 3 **Fate cards** → wave 5 **Lion boss**.
7. Victory → forge materials banked → **Replay** or return to world map.

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

**Runtime catalog:** `scripts/meta/content_registry.gd` — if bootstrap `.tres` is empty, builds Khan 1 slice in `_create_runtime_bootstrap()`.

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
| `tower_flame_archer` | Flame Archer | **2** | Ancestral hybrid | Fire + Arrow | ❌ | Rapid burn stacking |
| `tower_volcano_ram` | Volcano Ram | **2** | Ancestral hybrid | Fire + Siege | ❌ | Heavy explosive anti-armor |
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
| **1** | `level_01` | `map_khan_01_lion_rakhsh` | Labour 1 — Lion and Rakhsh | 32×18 | Medium | `tileset_woodland` | Lion of the First Khan | `mode_lion` | ✅ |
| **2** | `level_02` | `map_khan_02_desert_thirst` | Labour 2 — Desert of Thirst | 36×20 | Medium | `tileset_desert` | Manifestation of Thirst | `mode_thirst` | ❌ |
| **2** | `level_03` | `map_khan_03_azhdaha_canyon` | Labour 3 — Azhdaha Canyon | 40×22 | Medium-large | `tileset_dragon_canyon` | Azhdaha | `mode_dragon` | ❌ |
| **2** | `level_04` | `map_khan_04_sorceress_feast` | Labour 4 — Sorceress Feast | 42×24 | Medium-large | `tileset_enchanted_glade` | Sorceress (illusion + fiend) | `mode_temptress` | ❌ |
| **2** | `level_05` | `map_khan_05_olad_camp` | Labour 5 — Olad Camp | 48×27 | Large | `tileset_mountain_camp` | Olad champion | `mode_demons` | ❌ |
| **2** | `level_06` | `map_khan_06_arzhang_fortress` | Labour 6 — Arzhang Fortress | 52×30 | Large | `tileset_div_fortress` | Arzhang Div | `mode_rescue` | ❌ |
| **2** | `level_07` | `map_khan_07_white_div_cavern` | Labour 7 — White Div Cavern | 56×32 | Very large | `tileset_white_div_cavern` | Div-e Sepid | `mode_blindness` | ❌ |
| **5** | `level_08_damavand` *(typical)* | `map_damavand_binding` | Damavand Binding (finale) | 64×36 | Very large | `tileset_damavand` | Zahhak binding sequence | `mode_zahhak` | ❌ logic gate only |

**Hunt mode (Phase 5):** repeatable survival — may use `level_hunt` + Damavand assets (`boss_zahhak`, anchor VFX); not a ninth campaign Khan map.

**Per-map deliverables (each `map_id`):** terrain, path, build pads, regional-light sectors, corruption mask, collision, camera anchors; sector overlays on large maps ([design/01](../design/01-art-phases.md) §5.5).

**Shared Khan 1 environment assets (Phase 1):** `tileset_woodland`, `props_shared_vertical_slice` (16 props — design/01 §8.5).

**Phase 2 environment animations (per biome):** `env_brazier_flame`, `env_corrupted_brazier`, `env_qanat_flow`, `env_stream_ripple`, `env_desert_heat_distortion`, `env_sand_drift`, `env_dragon_scorch_embers`, `env_illusion_shimmer`, `env_fortress_banner_sway`, `env_cavern_mist`, `env_falling_cave_dust`.

---

## 7. Entities in repo today (built)

### 7.1 Heroes

| hero_id | display_name | max_hp | move_speed | attack_damage | skill_id | Notes |
|---------|--------------|--------|------------|---------------|----------|-------|
| `rostam` | Rostam | 220 | 190 | 28 | `rostam_charge` | Only hero in slice |

**Design target roster (not in repo):** Zal, Gordafarid, Esfandiyar, Sohrab, Kaveh, Simorgh — see [design/02](../design/02-gameplay-ux.md) §12.

---

### 7.2 Towers (starter four — subset of §5)

| tower_id | display_name | family | build_cost | damage | attack_rate | range | Special | forge_material_id |
|----------|--------------|--------|------------|--------|-------------|-------|---------|---------------------|
| `tower_archer` | Archer Tower | ARCHER | 50 | 14 | 1.4 | 150 | — | `iron_falcon` |
| `tower_sacred_fire` | Sacred Fire | SACRED_FIRE | 65 | 10 | 1.0 | 130 | burn | `iron_ember` |
| `tower_heavy` | Heavy Tower | HEAVY | 80 | 28 | 0.55 | 120 | armor_break | `iron_anvil` |
| `tower_control` | Control Tower | CONTROL | 70 | 6 | 0.9 | 140 | slow | `iron_frost` |

**Roles (design)**

| tower_id | Job | Weakness |
|----------|-----|----------|
| `tower_archer` | Fast single-target DPS | Armor, groups |
| `tower_sacred_fire` | Burn, cleanse synergy, SF economy | Lower raw DPS alone |
| `tower_heavy` | Armor break, brutes | Slow |
| `tower_control` | Slow / stagger, buys time | Low direct damage |

**All other towers:** see **§5** (seven advanced/hybrid IDs + three planned families).

**Reward towers (built — no `forge_material_id`):**

| tower_id | Unlock | Behavior |
|----------|--------|----------|
| `tower_zahhak_serpent` | All 8 Horde clears or IAP | `AttackBehavior.TWIN`; venom DoT + damage taken mult; Hunger AS on poisoned kills |
| `tower_rostam_barracks` | 7 Labour seals or IAP | `AttackBehavior.BARRACKS`; summons ally units (see below) |

**Ally units (barracks):**

| unit_id | Display | Role |
|---------|---------|------|
| `unit_zabul_vanguard` | Zabul Vanguard | Cleave melee; reduced burn/corruptor/fire damage |
| `unit_bull_mace_bearer` | Bull-Mace Bearer | Armor shatter + brief stun (slow); summoned at barracks max level |

**Tower runtime (controllers):** level, hijack state, regional light efficiency, forge damage/range mult from `ForgeService`, targeting via `TowerController`; serpent **Hunger** and barracks ally tracking on same controller.

---

### 7.3 Enemies (Khan 1 slice)

| enemy_id | display_name | tags | max_hp | speed | armor | gold | SF | corruption_pressure | forge drop |
|----------|--------------|------|--------|-------|-------|------|-----|---------------------|------------|
| `enemy_jackal` | Corrupted Jackal | grunt | 28 | 95 | 0 | 6 | 0 | 0 | 2× `iron_falcon` |
| `enemy_boar` | Corrupted Boar | brute | 90 | 55 | 4 | 14 | 0 | 0 | 3× `iron_anvil` |
| `enemy_corruptor` | Corruptor | corruptor | 40 | 70 | 0 | 10 | 2 | 18 | 3× `iron_ember` |
| `enemy_lion_boss` | Lion of the First Khan | boss | 650 | 45 | 6 | 80 | 0 | 0 | 25× `iron_frost` |

**Enemy archetypes (design target, not all authored)**

| Archetype | Role |
|-----------|------|
| Grunt | Default lane pressure |
| Runner | Fast leak threat |
| Brute | High HP / armor |
| Corruptor | Darkens regions, may grant Sacred Fire on kill |
| Boss | Phase mechanics, Khan counters |

**Campaign bosses (target IDs / names)** — see §8.

---

### 7.4 Levels & waves

| level_id | display_name | grid | gold | lives | SF | hero | build spots | waves |
|----------|--------------|------|------|-------|-----|------|-------------|-------|
| `level_00_tutorial` | Sacred Fire Training | 32×18 | 200 | 25 | 8 | rostam | 3 | 2 tutorial waves |
| `level_01` | Khan 1 — Lion and Rakhsh | 32×18 | 140 | 20 | 4 | rostam | 4 | 5 (boss wave 5) |

**Shared layout (graybox):** spawn ~(80,360), gate ~(1180,360), winding path, regions `region_north` / `region_south`.

**Khan 1 wave table (`level_01`)**

| wave_id | Spawns |
|---------|--------|
| `wave_1` | 6× jackal |
| `wave_2` | 8× jackal |
| `wave_3` | 5× jackal, 2× boar |
| `wave_4` | 6× jackal, 2× corruptor, 2× boar → **Pardeh Break** |
| `wave_5` | 1× lion boss |

---

### 7.5 Fate cards (built pool)

| card_id | title | Boon | Curse |
|---------|-------|------|-------|
| `card_flame_of_azar` | Flame of Azar | +15% tower damage | +8% enemy HP |
| `card_golden_bounty` | Golden Bounty | +30 gold | +10% corruption rate |
| `card_sacred_wind` | Sacred Wind | +2 Sacred Fire | (enemy HP mult 1.0 in data) |

**Design target:** 40+ named Fate IDs in art extract; only three wired in code. Full list in [design/01](../design/01-art-phases.md) Phase 3 / `_source/README_00_01_extracted.txt` §10.2.

---

## 8. Campaign entities (design target — not in repo)

**All maps:** see **§6**. Below: enemies and bosses per Khan.

### 8.1 Enemies and bosses by Khan

| `level_id` | `map_id` | Boss | Enemy IDs (design) |
|------------|----------|------|-------------------|
| `level_02` | `map_khan_02_desert_thirst` | `boss_manifestation_of_thirst` | `enemy_mirage_shade`, `enemy_salt_crust_brute` |
| `level_03` | `map_khan_03_azhdaha_canyon` | `boss_azhdaha` | `enemy_canyon_serpent`, `enemy_scorched_cave_hound` |
| `level_04` | `map_khan_04_sorceress_feast` | `boss_sorceress_illusion_form`, `boss_sorceress_revealed_fiend_form` | `enemy_illusion_attendant`, `enemy_feast_shade` |
| `level_05` | `map_khan_05_olad_camp` | `boss_olad_champion_form` | `enemy_mountain_raider`, `enemy_mountain_archer`, `companion_olad_guide_form` |
| `level_06` | `map_khan_06_arzhang_fortress` | `boss_arzhang_div` | `enemy_div_infantry`, `enemy_div_brute`, `enemy_div_stone_thrower`, `enemy_div_standard_bearer`, `enemy_div_corruptor`, `enemy_div_sorcerer` |
| `level_07` | `map_khan_07_white_div_cavern` | `boss_div_e_sepid` | `enemy_white_div_thrall`, `enemy_cavern_boulder_brute`, `enemy_cavern_corruptor` |
| `level_08_damavand` | `map_damavand_binding` | `boss_zahhak` (binding) | anchors, `enemy_zahhak_serpent_guard`, `enemy_chainbreaker_div`, … |

**Khan 1 (in repo):** `enemy_jackal`, `enemy_boar`, `enemy_corruptor`, `enemy_lion_boss` — art IDs `enemy_corrupted_*`, `boss_mythic_lion` (§16).

**Companion (Khan 1):** `companion_rakhsh` — narrative, not playable in code.

---

### 8.2 Post-campaign

| Mode | Key entities / systems |
|------|-------------------------|
| **Endless** | Procedural waves; no new boss required per wave |
| **Hunt for Zahhak** | `boss_zahhak`, serpent guards, Damavand mountain trigger, Forge towers for chains |
| **Roguelite map** | Node graph, blessings between fights |

---

## 9. Gameplay systems

### 9.1 Built (✅ in repo)

| System | Owner / notes |
|--------|----------------|
| Wave spawn & win/loss | `WaveManager`, `BattleStateController`, `EnemySpawner` |
| Tower place / attack / projectiles | `TowerManager`, `TowerController`, `ProjectileController` |
| Gold, lives, Sacred Fire | `BattleEconomy` |
| Regional light & corruption | `MapLightManager` (via `BattleContext`) |
| Tower hijack warning → hijack → cleanse recovery | `TowerController` + build spots |
| Hero move + skill | `HeroController` |
| Pardeh Break + Fate draft | After wave 4 on Khan 1 |
| Lion boss wave | `enemy_lion_boss` |
| Kaveh's Forge meta | `ForgeService`, Star Iron per tower material |
| Tutorial mission | `level_00_tutorial`, gates Khan 1 |
| Replay | One-tap from results |

### 9.2 Design target (❌ or 🟡 — see tracker)

| System | Summary |
|--------|---------|
| Sacred Tether | Drag hero → tower for AS buff; energy drain |
| Morale meter | 0–100 battle momentum |
| Ancestral Forge | Adjacent tower hybrids (e.g. Phoenix Bow) |
| Zervan Dial rewind | Snapshot rewind with corruption echo |
| Epic Couplet / Rhyme Window | Timed skill bonus window |
| Khan phases | Boss HP thresholds → map penalties + director |
| Ahriman Director | Boss adapts to dominant `TowerFamily` |
| Dynamic A* pathing | Light-weighted paths; moth corruptor inversion |
| Zahhak tribute & Damavand finale | Hunt mode spectacle |
| Qanat fast travel | Level nodes network |
| Blood Oath / Zahhak Pact / Memory Div | Optional run modifiers |
| Sell / upgrade tower UI | ✅ |

Detail: [spec/gameplay.md](gameplay.md) §6–8 · [engineering/implementation-tracker.md](../engineering/implementation-tracker.md).

---

## 10. Battle entity runtime state

Summarized from [spec/gameplay.md](gameplay.md) §2 — what controllers track beyond `.tres` design:

**Enemy:** current HP, speed, armor, path progress, status effects, rewards, tags, boss resistances, path recalc count.

**Tower:** level, family, hybrid flag, cooldown, range, damage (light + forge scaled), hijack flag, tether multiplier, health (for purge).

**Hero:** HP, position, energy, tether target, skill cooldown, cleanse aura tick on region.

**Region:** light level 0–100, stable/pressured/critical/collapsed, permanent corruption flag.

---

## 11. Damage, status, tower families (design)

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

## 12. Meta progression (forge mapping)

| Enemy | Drops material for tower |
|-------|--------------------------|
| Jackal | Falcon → Archer (`iron_falcon`) |
| Corruptor | Ember → Sacred Fire (`iron_ember`) |
| Boar | Anvil → Heavy (`iron_anvil`) |
| Lion boss | Frost → Control (`iron_frost`) |

Forge: levels 1–30 (+4% damage, +1% range per level); visual tier every 10 levels; elite path 5 steps after 30. **Damavand** launch requires ≥1 elite tower (`ForgeService.can_enter_damavand()`).

---

## 13. Scenes & prefabs (entity wiring)

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

## 14. Adding a new entity (engineering)

1. Add `TowerData` / `EnemyData` / etc. to `bootstrap_content.tres` **or** extend `_build_*()` in `content_registry.gd`.
2. Use new stable `*_id` string; reference only IDs in scenes/scripts.
3. Run `powershell -File tools/validate_resources.ps1`.
4. Update [implementation-tracker.md](../engineering/implementation-tracker.md) and this file if the catalog changes.

Prompt for content authoring: [prompts/10-add-new-content.prompt.md](../../prompts/10-add-new-content.prompt.md).

---

## 15. Khan 1 acceptance (gameplay gate)

From [design/02](../design/02-gameplay-ux.md) §20:

- Four towers feel distinct; route readable; Rostam movement matters.
- Sacred Fire and corruption understood before collapse; hijack feels fair.
- Lion changes player behavior; defeat is clear; **one-tap replay**.
- **Voluntary replay** without prompting — primary product signal.

---

## 16. Code ID vs art asset ID

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

## 17. Gameplay assets needed (Khan 1 — M4)

**Status today:** graybox placeholders (`ColorRect` / tinted sprites in prefabs). **Import path:** `art/_placeholders/` until production files land ([project-status.md](../engineering/project-status.md)).

**Technical defaults:** [art/pipeline.md](../art/pipeline.md) — pivots bottom-center (units/towers), center (VFX/projectiles); strips **8×1**; tower cells **256×256**; small enemies **192×192**; hero **256×256**; boss **384×384**; map tiles **128×128**.

### 17.1 Characters & creatures (Phase 0–1)

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

### 17.2 Towers (each: base + 8×1 strips per state)

Full tower list: **§5**. Khan 1 needs only the four starters below.

| Asset ID | States required | Priority | Wired in code |
|----------|-----------------|----------|---------------|
| `tower_archer` | idle, attack, construction, corruption_warning, hijacked, purification | P1 | ✅ behavior |
| `tower_sacred_fire` | same six states | P1 | ✅ + burn |
| `tower_heavy` | same six states | P1 | ✅ + armor_break |
| `tower_control` | same six states | P1 | ✅ + slow |

**Readability:** hijacked state must change silhouette/tint, not stats only ([visual-vfx.md](../art/visual-vfx.md) §3).

### 17.3 Battle map & environment (Khan 1)

Full map list: **§6**.

| Asset ID | Type | Contents | Priority |
|----------|------|----------|----------|
| `map_khan_01_lion_rakhsh` | Map package 32×18 | Layers: terrain, path, 8 build pads, 3 light sectors, spawn UR, gate LL, lion arena, brazier point | P0 |
| `tileset_woodland` | Tileset atlas 1024² (8×8×128²) | grass, path, stream, cliffs, corruption/sacred transitions | P1 |
| `props_shared_vertical_slice` | Prop atlas | brazier lit/extinguished/corrupted, rocks, reeds, trees, hero-rest carpet, banner (no text), sacred marker, etc. (16 props — design/01 §8.5) | P1 |

### 17.4 VFX (signature systems — P0 for readability)

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

### 17.5 UI (gameplay-facing)

| Asset ID | Use | Priority | Scene / notes |
|----------|-----|----------|---------------|
| `ui_battle_hud_prototype` | Phase 0 layout proof | P0 | validate zones |
| `ui_battle_hud` | Production HUD | P1 | `battle_hud` — lives, gold, SF, wave, tower cards |
| HUD icon set | pause, 1×/2×, settings, cleanse, brazier | P1 | replaces text buttons |
| Hero portrait | Rostam HUD | P1 | bottom-left |
| Pardeh / Fate UI | 3 card frames + `card_*` art | P1 | wave 4 break |
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

### 17.6 Audio (gameplay)

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
