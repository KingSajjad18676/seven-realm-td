# Main Gameplay Overview

**Last updated:** 2026-06-09 (full game inventory sync)  
**Purpose:** Quick reference for how the whole game works — play modes, maps, and what each Labour adds.  
**Repo truth:** [engineering/project-status.md](../engineering/project-status.md) · **Deep mechanics:** [spec/gameplay.md](../spec/gameplay.md)

---

## 1. What this game is

**Rostam 7 Labours: Shahname TD** is an active 2D tower-defense roguelite on landscape mobile (Godot 4.6).

You defend the gate on Persian-myth maps inspired by Rostam’s seven labours in the Shahnameh. You build towers, move the hero, spend **Sacred Fire** to fight **corruption**, pick **Fate cards** between wave blocks, and beat mythic bosses.

**Campaign:** 7 Labours + **Damavand Binding** finale (8 battlefields).  
**Signature twist:** Each campaign map adds a **Labour Mode** — a story hazard layered on top of the normal TD loop (campaign only).

---

## 2. How you move through the game

```
Boot → Main Menu
         ├─ Play → World Map (campaign + side modes)
         ├─ Daily Tale (seeded daily challenge on Labour 1)
         └─ Kaveh's Forge (meta tower upgrades)
```

**First-time flow:** Main Menu **Play** sends you to the **Tutorial** (`level_00_tutorial`). After that, **Labour 1** unlocks on the world map.

**World map buttons**

| Button | What it does | Unlock |
|--------|--------------|--------|
| **Campaign nodes** (T, 1–7, D) | Standard campaign battle on that map | Linear unlock; Damavand after Labour 7 |
| **Campaign Run** | **Primary roguelite** — branching run: draft 3 towers, scavenge Star Iron, skirmish/anvil/shrine/**Throne of Kavus** nodes → Damavand | After tutorial |
| **Endless** | Infinite waves on Labour 1 | 7 Labour seals |
| **Haft-Khan Gauntlet** | Race Labours 1–7 back-to-back; ms timer, ghost PB, Rush / early-call risk | 7 Labour seals |
| **Horde** | 15-wave survival per map | After tutorial |
| **Brothers in Arms** | Local couch co-op — Zal + Sohrab pick, shared gold/lives, separate Sacred Fire and scavenged loot | After tutorial |
| **Defend the Throne** | 360° radial arena — enemies march inward to the center throne | After tutorial |
| **Hunt for Zahhak** | Damavand boss hunt variant | 7 seals + 1 Elite tower at Kaveh's Forge |
| **Kaveh's Forge** | Permanent tower upgrades | Always (main menu or world map) |
| **Equipment** | Equip 4-piece sets (weapon/armor/helm/talisman) | World map panel |
| **Daily Missions** | 3 rotating objectives per day | World map panel |

---

## 3. Core battle loop (every mode)

This is the shared foundation. Labour Modes and side modes add rules on top.

```
Pre-battle
  → tap build pads → place / upgrade / sell towers (Gold)
  → move hero (tap ground)
  → optional: cleanse corruption (Sacred Fire)

Start wave
  → enemies spawn and path to the gate
  → towers attack; corruptors darken regions
  → at region light 0: tower can hijack (attacks allies) until purified
  → hero intercepts leaks, uses skills, Sacred Tether buffs towers

Every 5 waves → Pardeh Break
  → pick 1 of 3 Fate cards (boon + optional curse)
  → optional Hero's Vow every 10 waves (Accept/Decline — honor = SF + morale)

Every 10 waves → mini-boss wave

Final wave → map boss

Victory → unbanked materials banked to save → replay or return to map
Defeat → unbanked materials lost (100%)
Pardeh (campaign / horde / run) → optional Retreat to Forge banks materials and ends battle safely
```

**Scavenging:** Enemies may drop physical Star Iron on the map. Move **Rostam** over drops to collect into an **unbanked** tally (10s despawn). Pads still cost **Gold** only; materials are spent at **Kaveh's Forge** for unlock + upgrade.

### Battle HUD (landscape mobile)

| Zone | Elements |
|------|----------|
| Top bar | Lives, gold, wave, Sacred Fire, morale, unbanked materials |
| Pad tap (empty) | **Build radial** — afford-gated tower picks at world position |
| Pad tap (occupied) | **Manage radial** — upgrade, sell, purify (SF), Sacred Tether when hero in range |
| Pad select | **Attack-range ring** — preview on build, live on manage, grows on upgrade |
| Hero | Portrait + skill button; tap ground to move |
| Actions | Cleanse, Naft trap (Rostam), spell bar, early call, pause / 1× / 2× |
| Overlays | Pardeh panel, Hero's Vow chip, gauntlet timer + ghost PB, co-op HUD row |
| Map fit | Medium maps (e.g. Labour 1) lock full-map view; minimap/threat hidden when map fully visible |

Bottom tower card bar removed — all build/manage flows use pad radials.

### Battle resources

| Resource | Role |
|----------|------|
| **Gold** | Build and upgrade towers |
| **Lives** | Gate integrity — enemies that leak reduce lives |
| **Sacred Fire** | Cleanse regions, recover hijacked towers, hero skills |
| **Morale** | Momentum buffs; vow rewards and penalties |
| **Forge Tokens** | Meta currency from victories; buy spells at Kaveh's Forge |

### Starter towers (all campaign maps)

| ID | Role |
|----|------|
| `tower_archer` | Ranged DPS |
| `tower_sacred_fire` | Fire / corruption counter |
| `tower_heavy` | Slow heavy hitters |
| `tower_control` | Crowd control |

### Reward towers (unlock outside normal forge)

| Tower | Unlock |
|-------|--------|
| **Rostam Tahmtan Barracks** | 7 Labour seals **or** store IAP — summons ally blockers |
| **Serpent Spire** | Clear Horde on all 8 maps **or** store IAP — twin venom + attack-speed hunger |

---

## 4. Play modes vs maps

A **map** is a battlefield (`level_id`). A **mode** is how you launch that map (`BattleLaunchData` flags).

| Mode | Flag | Labour Mode active? | Waves | Maps used |
|------|------|---------------------|-------|-----------|
| **Campaign** | default | ✅ Yes | 30–100 (procedural + boss) | Tutorial + Labours 1–7 + Damavand |
| **Horde** | `is_horde_mode` | ❌ No | 15 fixed | Any unlocked campaign map (not tutorial) |
| **Endless** | `is_endless_mode` | ❌ No | Infinite | Labour 1 only |
| **Campaign Run** | `is_campaign_run` | ❌ No | Per node | Mixed campaign maps |
| **Roguelite (legacy)** | `is_roguelite_run` | ❌ No | Per node | Mixed run (L1–L4) — **deprecated**; save migrates to Campaign Run |
| **Hunt for Zahhak** | `is_hunt_mode` | ✅ Yes (`mode_zahhak`) | Damavand hunt rules | `level_08_damavand` only |
| **Daily Tale** | `is_daily_tale` | ❌ No | Labour 1 layout | `level_01` (daily seed) |
| **Brothers in Arms** | `is_brothers_mode` | ❌ No | Campaign-length | Any unlocked map |
| **Defend the Throne** | `is_throne_defense_mode` | ❌ No | 15 fixed | `level_throne_arena` |
| **Haft-Khan Gauntlet** | `is_gauntlet_mode` | ✅ Yes (per boss) | 7-boss chain | Labours 1–7 in sequence |

**Labour Modes only run in campaign** (`is_campaign_mode()`) and gauntlet boss transitions. Horde, Endless, Campaign Run nodes, Brothers, Throne, and Daily Tale use map layout and enemies but **not** the full campaign Labour overlay (except gauntlet per-boss modes).

---

## 5. All maps — modes, bosses, and Labour hazards

### Summary table

| Map ID | Display name | Hero | Campaign waves | Boss | Mini-boss (every 10th) | Default objective | Labour Mode |
|--------|--------------|------|----------------|------|------------------------|-------------------|-------------|
| `level_00_tutorial` | Sacred Fire Training | Rostam | 2 | — | — | — | — |
| `level_01` | Labour 1 — Lion and Rakhsh | Rostam | 30 | Lion of the First Khan | Boar | No leaks | **Lion** |
| `level_02` | Labour 2 — Desert of Thirst | Zal | 40 | Manifestation of Thirst | Salt-crust Brute | Cleanse twice | **Thirst** |
| `level_03` | Labour 3 — Azhdaha Canyon | Zal | 50 | Azhdaha | Canyon Serpent | No leaks | **Dragon** |
| `level_04` | Labour 4 — Sorceress Feast | Rostam | 60 | Sorceress | Feast Shade | No hijack | **Temptress** |
| `level_05` | Labour 5 — Olad Camp | Rostam | 70 | Olad Champion | Mountain Raider | No leaks | **Demons** |
| `level_06` | Labour 6 — Arzhang Fortress | Rostam | 80 | Arzhang Div | Div Brute | Cleanse twice | **Rescue** |
| `level_07` | Labour 7 — White Div Cavern | Rostam | 90 | White Div | Cavern Boulder Brute | No hijack | **Blindness** |
| `level_08_damavand` | Damavand Binding | Rostam | 100 | Zahhak | Chainbreaker Div | Cleanse twice | **Zahhak** |

**Wave formula (campaign):** `20 + (Labour index × 10)` — e.g. Labour 1 = 30 waves, Labour 7 = 90, Damavand = 100.  
**Difficulty scaling:** Each Labour raises enemy HP, speed, and spawn count (~12% / 4% / 15% per step).

**10-wave master block (campaign):** Every map repeats **10-wave macro blocks** with act-specific enemy progression. Within each block: **Bait** (1–3, scavenging focus), **Trap** (4–5, heavy push + Labour hazard intensity), **Hijack** (6–8, corruptor floods), **Push + Mini-boss** (9–10). **Pardeh Break** after every 5 cleared waves (end of Trap); **Hero's Vow** after every 10 cleared waves (end of block). Templates in `scripts/meta/campaign_wave_templates.gd`.

| Block role | Waves in block | Purpose |
|------------|----------------|---------|
| Bait | 1–3 | Low-tier enemies; material drops boosted; no corruptors |
| Trap | 4–5 | Heavy push; Labour hazard peaks; Pardeh at wave 5 |
| Hijack | 6–8 | Corruptor floods; Sacred Fire tax |
| Push | 9 | Brute/elite escorts before mini-boss |
| Mini-boss | 10 | Map mini-boss + escorts; Hero's Vow after clear |

**Labour + wave synergy (block 1 teaching beats):**

| Map | Wave design hook | Labour hazard sync |
|-----|------------------|-------------------|
| L1 Lion | Jackal bait scavenging; boars act 2+ | Rakhsh ambush wave 1; roar ambushes act 3 |
| L2 Thirst | Mirage shades | Oasis pulse spawns mirages — heal or defend |
| L3 Dragon | Hounds rush while serpents burrow | 12s burrow cycle |
| L4 Temptress | Feast shades after decoys | Cleanse dispels illusions |
| L5 Olad | Raider funnel then dual-lane attrition | Second cave opens after wave 3 |
| L6 Rescue | Div corruptor floods | Wave 3 corruption spike + captive objective |
| L7 Blindness | Boulder brutes in darkness | 6s blind every 14s; cleanse shortens |
| Damavand | Serpent guards → chainbreakers | Binding progress (campaign) |

**Map size:** Labours 1–2 are medium maps; 3–4 medium-large; 5–7 large / very large with camera anchors; Damavand is the largest.

---

### Labour Mode details (campaign only)

Each mode is implemented in `scripts/battle/labours/`.

#### Labour 1 — `mode_lion` (Lion and Rakhsh)

- Opening alert: Rakhsh keeps watch.
- **Wave 1 ambush:** After 2.5s, 4 jackals spawn near the hero — Rakhsh engages the lion pack.

#### Labour 2 — `mode_thirst` (Desert of Thirst)

- Passive **hero HP drain** and **region corruption pressure** during active waves.
- Every **18s:** oasis pulse — +1 Sacred Fire, repairs region light; hero near fountain spot heals.

#### Labour 3 — `mode_dragon` (Azhdaha Canyon)

- Every **12s:** boss/serpent enemies **burrow** (submerge) or surface — strike when they emerge.

#### Labour 4 — `mode_temptress` (Sorceress Feast)

- From **wave 2:** 6 **decoy** illusion attendants spawn (fake threats).
- **Cleanse** dispels all active decoys instantly.

#### Labour 5 — `mode_demons` (Olad Camp)

- After **wave 3 completes:** a **second cave front** opens mid-path — extra div infantry and brutes spawn.

#### Labour 6 — `mode_rescue` (Arzhang Fortress)

- **Rescue objective:** Move Rostam to captive spot near the gate → +20 morale, +2 Sacred Fire.
- **Wave 3:** sudden corruption spike on all regions.

#### Labour 7 — `mode_blindness` (White Div Cavern)

- Every **14s:** **6s darkness** — towers deal 75% damage, vision radius 70%.
- **Cleanse** shortens darkness; defeating the White Div boss ends the effect permanently.

#### Damavand — `mode_zahhak`

- **Campaign Damavand:** binding progress mechanic + chainbreaker guards before Zahhak.
- **Hunt mode:** HuntController — bind Zahhak with forge chains (requires 7 seals + Elite tower).

---

## 6. Side modes in detail

### Horde

- Pick any **unlocked** campaign map from the Horde picker.
- **15 waves** per map; enemy roster matches that Labour's theme.
- Clear Horde on **all 8 maps** (tutorial excluded) → unlock **Serpent Spire** tower.
- No Labour Mode overlay; no procedural 30–100 wave campaign length.

### Endless

- Runs on **Labour 1** layout only.
- Waves never end until you lose.
- Requires **7 Labour seals** (full campaign clear with seal objectives).

### Campaign Run (primary roguelite)

- **Entry:** World Map → **Campaign Run** (after tutorial).
- **Tower draft:** Pick 3 towers from unlocked pool pre-run; +1 tower on elite nodes.
- **Node types:** skirmish, anvil (forge rest), shrine (companion or relic pick), **Throne of Kavus** (Kay Kavus Folly bombardment), labour boss, Damavand finale.
- **Scavenging:** Physical Star Iron drops; unbanked until victory, Pardeh Retreat, or defeat (100% loss).
- **Companions:** Shrine pick — Royal Cheetah, Simurgh Fledgling, or Zavareh (max 1 per run).
- **Relics:** Shrine + alternating Pardeh (relic slot instead of Fate pick); per-tower relic slots via `RunModifierService`.
- **Hard mode:** **Ahriman's Shroud** after campaign Damavand clear — see §7b.
- Save v6 `campaign_run`; legacy 5-node roguelite scene deprecated.

### Roguelite Path (legacy)

- **5 nodes:** Woodland (L1) → Sacred Rest → Desert (L2) → Canyon Elite (L3) → Feast Trial (L4).
- Superseded by **Campaign Run**; existing saves migrate `roguelite_run` → `campaign_run`.

### Brothers in Arms (local co-op)

- Pick **Zal** or **Sohrab** as second hero; shared gold and lives, **split** Sacred Fire and scavenged loot.
- Any unlocked campaign map; no Labour Mode overlay.
- `CoopPlayerManager` routes input and economy per player.

### Defend the Throne

- **Map:** `level_throne_arena` — 360° radial arena, 10 spawn routes marching inward.
- **15 waves** survival; no campaign seals or Labour overlay.
- Rostam only; starter four towers.

### Haft-Khan Gauntlet

- **Unlock:** 7 Labour seals.
- **Flow:** Labours 1–7 bosses back-to-back in one session; **3-tower draft** at start.
- **Timer:** Millisecond speedrun clock; personal-best **ghost** replay HUD (save v8 `gauntlet_best`).
- **Risk mechanics:** Rush waves and early-call overwhelm for faster clears.
- **No Pardeh Break or Hero's Vow** — pure boss-rush pacing.
- Labour Modes apply per boss map during the chain.

### Hunt for Zahhak

- Launches **Damavand** with `is_hunt_mode`.
- Requires **7 Labour seals** + at least **1 Elite tower** forged at Kaveh's Forge.
- Uses `mode_zahhak` + HuntController binding sequence.

### Daily Tale

- From **Main Menu → Daily Tale**.
- Always **Labour 1** map with a date-based seed.
- One completion per calendar day tracked in save.

---

## 7. Progression and unlocks

```
Tutorial complete
  → Labour 1 unlocked
  → Horde + Campaign Run + Brothers + Throne + Daily Tale available

Clear Labour N
  → Labour N+1 unlocked
  → Labour seal if default objective met on victory

Clear Labour 7
  → Damavand unlocked (campaign)

7 Labour seals
  → Endless unlocked
  → Haft-Khan Gauntlet unlocked
  → Rostam Barracks tower unlocked (or IAP)
  → Hunt for Zahhak eligible (also needs Elite forge)

Horde: 8/8 maps cleared
  → Serpent Spire tower unlocked (or IAP)

Campaign Damavand clear (once)
  → Ahriman's Shroud toggle on Campaign Run
```

**Kaveh's Forge (meta):** Banked Star Iron unlocks new tower types (per-tower material) and upgrades them (Lv 1–30, then 5 Elite). Each tower uses one material ID for both unlock and upgrades. Elite tower required for Hunt.

| Tower | Material |
|-------|----------|
| Archer | Falcon Star Iron (`iron_falcon`) |
| Sacred Fire | Ember Star Iron (`iron_ember`) |
| Heavy | Anvil Star Iron (`iron_anvil`) |
| Control | Frost Star Iron (`iron_frost`) |
| Flame Archer | Serpent Star Iron (`iron_serpent`) |
| Volcano Ram | Volcano Star Iron (`iron_volcano`) |

**Forge Tokens:** Earned on victory → buy and cast **spells** from the battle HUD.

**Relics of the Shahs (run/battle):** Separate from Kaveh's Forge. During scavenging modes, find crowns and rings at **Campaign Run shrines**, **Roguelite rest nodes**, and every **other Pardeh Break** (after Fate pick). Each relic slots onto one tower **type** in your loadout for the rest of the run or battle. Examples: **Cup of Jamshid** (`tower_archer` — map-wide range, −50% attack speed); **Flame of Hushang** (`tower_sacred_fire` — burn + slow Gate Life recovery on attack). One slot per tower type; picking a duplicate slot prompts replace confirmation.

### Forge progression gate (soft difficulty)

Kaveh's Forge is the **primary power curve** for campaign, Horde, and Damavand. Nothing is hard-locked on the world map — Labour 3+ stays playable — but enemy HP and spawn pressure from Labour 3 onward assume your starter towers have been forged to the **expected level** for that map. Unforged towers hit a difficulty wall; losing sends you back to **replay earlier Labours** for Star Iron, forge at Kaveh's, then try again.

This is intentional **replay-to-grow** (roguelite TD standard), not a paywall: Star Iron is free from victories, forge power is never sold, and Labours 1–2 stay clearable without forging so the loop is taught on a win.

| Map | Expected avg forge level | Notes |
|-----|--------------------------|-------|
| Labour 1 | 1 | Forge optional — learn the TD loop |
| Labour 2 | 2 | Light forge nudge |
| Labour 3 | 8 | First real wall for unforged towers |
| Labour 4 | 12 | |
| Labour 5 | 16 | |
| Labour 6 | 20 | |
| Labour 7 | 25 | |
| Damavand | 30 + 1 Elite | Elite gate for Hunt unchanged |

**Average forge level** = mean forge level across the four starter towers (`tower_archer`, `tower_sacred_fire`, `tower_heavy`, `tower_control`).

**Modes affected:** Campaign, Horde (uses same map difficulty), Damavand campaign. **Not affected:** Endless, Roguelite Path, Daily Tale (practice / side content).

**Player-facing cues:** World map shows recommended vs your average forge on Labour 3+ nodes; defeat screen suggests replay + forge when under recommendation.

---

## 7b. Ahriman's Shroud (Campaign Run hard mode)

Unlocked after clearing **campaign Damavand** (`level_08_damavand`) once. On **Campaign Run** start, an optional toggle blankets the branching graph in darkness:

| Rule | Behavior |
|------|----------|
| Unlock | `SaveSystem.is_level_cleared("level_08_damavand")` |
| Toggle | **Ahriman's Shroud** on tower draft (default off) |
| Hidden nodes | Reachable unrevealed nodes show `???` until paid reveal |
| Reveal | Costs run **Sacred Fire** (1–3 by node type); must reveal before entering |
| Run wallet | Starts at 5 SF; persists across map nodes and battles (cleanse / purify draw from same pool) |
| Defeat | Run ends as normal Campaign Run |

**Code:** `campaign_run_state.gd`, `shroud_reveal_controller.gd`, `world_map_controller.gd`, `battle_launch_data.gd`, `battle_bootstrap.gd`.

---

## 7c. Haft-Khan Equipment Sets

**Entry:** World Map → **Equipment** panel (`EquipmentService`).

| Set ID | Theme | Boss drops (weapon + armor) | Daily mission drops (helm + talisman) |
|--------|-------|----------------------------|--------------------------------------|
| `set_rakhsh_vigor` | Labour 1 — Lion | `level_01` clear | Daily mission loot chest |
| `set_thirst_turan` | Labour 2 — Thirst | `level_02` clear | Daily mission loot chest |
| `set_azhdaha_scale` | Labour 3 — Dragon | `level_03` clear | Daily mission loot chest |
| `set_mazandaran_venom` | Labour 4 — Temptress | `level_04` clear | Daily mission loot chest |
| `set_kaveh_iron` | Labour 5 — Demons | `level_05` clear | Daily mission loot chest |
| `set_arzhang_fury` | Labour 6 — Rescue | `level_06` clear | Daily mission loot chest |
| `set_simurgh_talon` | Labour 7 — Blindness | `level_07` clear | Daily mission loot chest |

- **28 pieces** total (7 sets × 4 slots: weapon, armor, helm, talisman).
- Equipped loadout applies in battle via `EquipmentBattleService` + `equipment_set_rules.gd` (set bonuses, toxic cloud, etc.).
- Save v9 tracks `equipment_owned` and `equipment_equipped`.

**Code:** `equipment_service.gd`, `equipment_screen_controller.gd`, `equipment_battle_service.gd`, `content_catalog.gd` → `build_equipment_pieces()`.

---

## 7d. Daily Missions

**Entry:** World Map → **Daily Missions** panel (`DailyMissionService`).

- **3 missions per day** drawn from a **10-mission pool**; rotates at calendar day boundary.
- Progress tracked in save v9; lifetime stats via `MissionProgressTracker`.
- **Royal Bounty** consumable: +3 mission progress on one active mission.
- **Loot chest** on claim → helm or talisman equipment piece (random from eligible pool).
- Missions span all modes (e.g. total div kills, pristine boss wave, archer damage in a run).

**Code:** `daily_mission_service.gd`, `daily_missions_panel_controller.gd`, `content_catalog.gd` → `build_daily_mission_definitions()`.

---

## 8. Enemy themes per map

| Map | Main enemy types |
|-----|------------------|
| Labour 1 | Jackal, Boar, Corruptor |
| Labour 2 | Mirage Shade, Salt-crust Brute, Corruptor |
| Labour 3 | Canyon Serpent, Scorched Hound, Corruptor |
| Labour 4 | Illusion Attendant, Feast Shade, Corruptor |
| Labour 5 | Mountain Raider, Mountain Archer, Boar |
| Labour 6 | Div Infantry, Div Brute, Div Corruptor |
| Labour 7 | White Div Thrall, Cavern Boulder Brute, Div Corruptor |
| Damavand | Zahhak Serpent Guard, Chainbreaker Div, Div Brute |

---

## 9. Where this is defined in code

| Topic | Location |
|-------|----------|
| Map list + display names | `scripts/meta/content_catalog.gd` → `build_levels()` |
| Labour Mode per map | `scripts/battle/labours/labour_mode_factory.gd` |
| Mode hazard logic | `scripts/battle/labours/mode_*.gd` |
| Launch flags (Horde, Hunt, …) | `scripts/battle/battle_launch_data.gd` |
| World map UI + unlocks | `scripts/meta/world_map_controller.gd` |
| Campaign Run graph + draft | `campaign_run_state.gd`, `campaign_run_generator.gd`, `tower_draft_controller.gd` |
| Ahriman's Shroud hard mode | `campaign_run_state.gd`, `shroud_reveal_controller.gd`, `world_map_controller.gd` |
| Material drops + scavenging | `loot_drop_manager.gd`, `material_drop.gd`, `battle_economy.gd` |
| Safe retreat | `fate_draft_controller.gd` → `battle_state_controller.trigger_safe_retreat()` |
| Per-tower forge unlock | `forge_service.gd`, `kaveh_forge_controller.gd` |
| Campaign-only Labour attach | `scripts/battle/battle_bootstrap.gd` → `_attach_labour_mode()` |
| Wave count + 10-wave master block templates | `scripts/meta/campaign_wave_templates.gd` + `content_catalog.gd` → `wave_count_for()` |
| Pardeh cadence (every 5 waves) | `scripts/battle/wave_manager.gd` → `_should_offer_pardeh()` |
| Expected forge curve + gate | `scripts/meta/forge_service.gd` → `expected_forge_level_for()`, `is_under_forge_recommendation()` |
| Forge-scaled difficulty (L3+) | `scripts/meta/content_catalog.gd` → `khan_difficulty()` |
| Equipment sets + battle rules | `equipment_service.gd`, `equipment_battle_service.gd`, `equipment_set_rules.gd` |
| Daily missions | `daily_mission_service.gd`, `mission_progress_tracker.gd` |
| Gauntlet timer + ghost PB | `gauntlet_run_state.gd`, gauntlet HUD in `battle_hud_controller.gd` |
| Co-op split economy | `coop_player_manager.gd` |

---

## 10. Related docs

| Doc | Use when you need… |
|-----|-------------------|
| [design/02-gameplay-ux.md](../design/02-gameplay-ux.md) | Design pillars, UX, corruption, hijack |
| [spec/entities-and-gameplay.md](../spec/entities-and-gameplay.md) | All towers, maps, art phases |
| [spec/gameplay.md](../spec/gameplay.md) | Full formulas and post-launch systems |
| [engineering/game-logic.md](../engineering/game-logic.md) | Battle state machine and ownership |
| [engineering/handoff.md](../engineering/handoff.md) | Onboarding for programmers |
