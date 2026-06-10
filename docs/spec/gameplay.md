# Gameplay Specification

**Last updated:** 2026-06-09  
**Design canon:** [design/02-gameplay-ux.md](../design/02-gameplay-ux.md) · [design/00-project-index.md](../design/00-project-index.md)  
**Developer quick start:** [engineering/game-logic.md](../engineering/game-logic.md)  
**What works today:** [engineering/implementation-tracker.md](../engineering/implementation-tracker.md) · **Built entities:** [entities-and-gameplay.md](entities-and-gameplay.md) §7 · **Modes/maps:** [main-gameplay.md](../product/main-gameplay.md)

**Built (repo):** Full campaign (Labours 1–7 + Damavand), 10+ play modes, 8 towers, 22 enemies, Labour Modes, Pardeh/Fate, equipment, daily missions, Campaign Run, Gauntlet, co-op — see [main-gameplay.md](../product/main-gameplay.md).

This document includes **advanced and post-launch** systems (rewind, tribute, premium stubs) that may not be coded yet. **Khan 1 production gate** is defined in design/02 §20 and [PRD.md](../product/prd.md) §5 — do not treat every section here as required for the first vertical slice.

## 1. Core Battle Loop

1. Load level data (static waypoints or dynamic A* grid per level flag).
2. Spawn path, build spots, and region light state (`MapLightManager`).
3. Player builds towers; adjacent families may unlock **Ancestral Forge** hybrids.
4. Player positions hero, **drags Sacred Tether** to buff towers, and passively cleanses standing region.
5. Player starts wave.
6. Enemies path toward the gate (light-weighted A* when enabled); corruptors darken regions.
7. Towers target enemies; at **light 0** hijacked towers target allies/hero until purged.
8. Hero fights, uses ability; **Epic Couplet** windows reward timed skill use.
9. Player spends gold / Sacred Fire; may hold **Zervan Dial** to rewind (with corruption penalty).
10. Boss **Khan phases** (every 15% HP) trigger adaptive counters and map modifiers.
11. Roguelite finale: **Zahhak** (infinite HP) dragged to **Damavand** with Forge chains — or standard wave clear victory.

### Kaveh's Forge (meta — implemented)

| Step | Behavior |
|------|----------|
| Battle kills | Each enemy may drop a **forge material** (`forge_material_id` / `forge_material_drop` on `EnemyData`) |
| Victory | `BattleEconomy.forge_materials_earned` committed to save `star_iron` |
| Main menu | **Kaveh's Forge** screen — per starter tower row |
| Normal forge | Levels 1→30; cost scales per level; +4% damage / +1% range per level |
| Visual tier | Every 10 levels → design tier 1–3 (graybox color/size) |
| Elite forge | After level 30, 5 elite levels; large bonus at elite 5 |
| Damavand | `level_08_damavand` launch blocked unless `ForgeService.can_enter_damavand()` (≥1 elite tower) |

**Material mapping (Labour 1 baseline):** Jackal → Falcon (Archer); Corruptor → Ember (Sacred Fire); Boar → Anvil (Heavy); Lion boss → Frost (Control). Per-Labour enemies drop themed Star Iron — see [entities-and-gameplay.md](entities-and-gameplay.md) §13.

**Not the same as:** Ancestral Forge (adjacent tower hybrids in battle).

### Input rules (mobile)

| Input | Action |
|-------|--------|
| **Virtual stick (left)** | Move hero — joystick-only |
| **Attack / Heavy / Dodge / Skill (right)** | Manual hero combat |
| Tap build spot (empty) | Build radial |
| Tap tower (occupied) | Manage radial — upgrade, sell, purify, **Tether** |
| Tap path (Naft armed) | Place Rostam oil slick |
| Tap Cleanse | Spend Sacred Fire on selected region |

**Deferred (design target, not built):** drag offensive tether to Zahhak, Hold Rewind (Zervan Dial), Rhyme Window skill bonus, sacrifice max-level tower tribute gesture.

## 2. Battle Entities

### Enemy

Required runtime state:

- current HP
- movement speed
- armor
- magic resistance
- path progress
- active status effects
- reward gold
- enemy tags

### Tower

Required runtime state:

- level, `TowerFamily`, ancestral hybrid flag
- target mode, cooldown, range, damage (scaled by regional light)
- projectile data, upgrade branch, pending hybrid recipe
- **health** (for hijack purge by hero)
- **isHijacked**, layer/tag swap when region light = 0
- tether attack-speed multiplier (primary + refracted 50%)
- regional light efficiency: `E = L/30` when `L < 30` (cooldown + range)

### Hero

Required runtime state:

- current HP, max HP (reducible by Serpent tribute failure)
- position, **facing direction** (for attack arc)
- **attack / heavy / dodge / skill cooldowns**
- **dodge i-frame window**
- **move input vector** from virtual stick
- **currentEnergy / maxEnergy** (tether drain)
- **tetherRange**, cleanse radius
- revive timer
- active tether target (tower)
- invulnerability / infinite energy (Epic Couplet Fate boon — deferred)

### Enemy (extended)

- **pathRecalcCount** — anti-juggle enrage (speed/scale += 15% per recalc)
- **isMothCorruptor** — inverted A* (seeks brightest regions)
- boss runtime damage resistances (`BossModifierData`)
- dynamic `WaypointPath` when level uses A*

## 3. Damage Types

- Physical
- Pierce
- Magic
- Fire
- Sacred
- Siege
- Poison
- True damage, use rarely

## 4. Status Effects

- Burn
- Slow
- Stun
- Poison
- Armor Break
- Shield
- Heal Over Time
- Corruption
- Cleanse
- Fear
- Reveal Hidden

## 5. Tower Families

`TowerFamily` enum drives forge recipes, Khan counters, and refraction:

| Family | Role | Example |
|--------|------|---------|
| Arrow | Physical ranged | Persian Arrow Tower |
| Fire | Sacred / burn | Zoroastrian Fire Tower |
| Siege | Splash / armor break | Trebuchet |
| Barracks | Blockers | Persian Immortals |
| Shrine | Cleanse / support | Simorgh Shrine |
| Command | Morale aura | Royal Command |
| Forge | Damavand anchors (Hunt binding) | Kaveh's Forge (Zahhak finale) |
| Hybrid | Ancestral combo output | Phoenix Bow (Fire + Arrow) |

## 6. Unique Systems

### Core identity

> A Persian-myth tower defense where you hold back Ahriman's darkness with Sacred Fire — and the darkness fights back by corrupting your own towers — across roguelite runs shaped by double-edged Fates.

Three pillars define what makes this game unlike generic Kingdom Rush clones:

| Pillar | Role | Build priority |
|--------|------|----------------|
| **Sacred Fire vs Corruption** | Flagship signature — living, corruptible battlefield | C (highest payoff, highest risk) |
| **Fate Weaving** | Roguelite spine — every reward is boon + curse | A (lowest risk, implement first) |
| **Morale** | Supporting meter — battlefield momentum | B (bridge between A and C) |

Roguelite + TD is the **vehicle** for replay; these three systems are the **identity**.

---

### Sacred Fire vs Corruption (FLAGSHIP)

The battlefield is a contested space, not a static lane. Light and darkness are opposing forces that change how the map plays.

#### Board state

- The map is divided into **regions** (path segments, build-spot clusters, or shrine zones).
- Each region has a **light level** (0 = fully corrupted, 100 = fully lit).
- Regions start lit at campaign defaults; roguelite and boss levels may start partially dark.

#### Corruption spread

- Certain enemies (corruptors, bosses, elite waves) apply **corruption** as they advance or on death.
- Corruption **darkens** regions along the path over time or when enemies pass through.
- Darkened regions affect anything built on or near them:
  - **Disable** towers below a light threshold (cannot attack until cleansed).
  - **Weaken** towers in partial darkness (reduced attack speed and range).
  - **Buff** nearby enemies (armor, speed, or intimidation — stacks with Morale low state).

#### Sacred Fire (second resource)

- **Gold** remains the primary build/upgrade currency.
- **Sacred Fire** is a separate battle resource earned from:
  - killing corruptor-type enemies
  - Zoroastrian Fire tower kills
  - Shrine nodes and roguelite rewards
  - hero abilities (Fereydon, cleansing bonds)
- Player spends Sacred Fire to:
  - **Cleanse** a region (restore light level)
  - **Light braziers** (persistent small light aura on a tile)
  - **Empower** fire-type towers (temporary damage or sacred damage bonus)

#### Cleansing sources (stack with Sacred Fire spend)

- Tap-to-cleanse on corrupted build spots (costs Sacred Fire)
- Simorgh Shrine tower (passive cleanse radius)
- Zal hero skill
- Sacred Fire tower upgrade branch
- Cleansing relics from roguelite runs

#### Design intent

Players must decide: spend gold on more towers, or spend Sacred Fire to reclaim territory? Corruption turns tower placement into territory control, not only DPS math.

#### Runtime (implemented)

- `MapRegion` + `MapLightManager` (exposed as `BattleContext.Corruption`)
- `TowerController.OnLightChanged`, hijack at `L == 0`, `TakeDamage` purge
- `BattleEconomy` Sacred Fire; cleanse / brazier on build spots
- Corruptor decay loop in regions; `ApplyPermanentCorruption` for rewind / tribute
- **Art still required:** regional overlay, brazier prop, hijack VFX — see [art/visual-vfx.md](../art/visual-vfx.md)

---

### Module 2 — Hero Sacred Tether & Ancestral Forge

#### Sacred Tether (drag UX)

- Drag from hero to friendly tower (not the same as tap-to-upgrade).
- Attack-speed bonus: `AS_bonus = 2.0 × (1 − distance / tetherRange)`.
- Drains `currentEnergy` continuously; severs if out of range or energy empty.
- Fires `OnLightTopologyChanged` for enemy path recalc.

#### Tether refraction (hybrid towers)

- Ancestral hybrid acts as prism: secondary beams to **2 nearest same-family** towers.
- Those towers receive **50%** of the tether attack-speed bonus.

#### Cleanse aura

- Every **0.1s**, hero's current `MapRegion` gains light (`cleanseLightPerTick` from `HeroData`).

#### Ancestral Forge

- On tower build, `Physics2D.OverlapCircleNonAlloc` checks neighbors.
- Matching `TowerCombinationData` (e.g. Fire + Arrow) sets **pending hybrid** on upgrade UI.
- Example output: `tower_phoenix_bow` (hybrid, opens Rhyme Window crit chance).

---

### Module 3 — Zervan Chrono, Epic Couplet, Khan Phases

#### Zervan Dial

- Ring buffer: **50 snapshots × 0.1s** = 5s history (10s with `fate_shattered_chrono_dial` boon).
- Snapshot stores: enemy pos/HP/path, hero pos/energy, tower healths[], region lights[].
- Hold rewind: overwrite live state from snapshots.
- **Ahriman's Echo:** each grid cell an enemy reverses through → that region `isPermanentlyCorrupted`, `light = 0`.

#### Epic Couplet

- Ancestral hybrid crit/skill → **1.5s Rhyme Window**.
- Hero skill inside window: screen clear (non-boss), local relight, max morale.
- `fate_couplet_immortal`: 6s invuln + infinite energy on success; missed window may halve morale.

#### Khan escalation

- Boss HP every **15%** lost → `OnPhaseEnter(phase)`.
- Regional light penalty; HUD banner; hooks **Ahriman Director**.

---

### Module 4 — Dynamic Shadow-Pathing (Living Labyrinth)

Enabled per level: `LevelData.useDynamicPathfinding`.

#### Light-weighted A*

`Cost = distance + (L × W_light)` where `L` is normalized regional light [0,1].

- Normal enemies **avoid** light (longer path through darkness).
- **Moth Corruptor** (`isMothCorruptor`): inverted cost — seeks brightest tiles.

#### Anti-juggle

Each `RecalculatePath()`:

- `pathRecalcCount++`
- Speed and scale `× (1 + 0.15 × pathRecalcCount)`
- At **4+** recalcs, enemy **ignores light penalty** (pure distance pathing).

#### Recalc triggers (throttled)

Brazier, Sacred Tether established, region cleansed → `MapLightManager.OnLightTopologyChanged`.

Players herd waves with light — not static maze walls.

---

### Module 5 — Ahriman Director (Adaptive Khan AI)

- `PlayerTacticsAnalyzer` tallies `TowerFamily` every **10s**.
- On Khan `OnPhaseEnter`, `AhrimanDirector` picks `BossModifierData` countering dominant family.
- Example: `modifier_ash_cloak` → 80% Fire resistance + warning banner.
- Boss applies runtime `DamageType` resistance map.

---

### Module 6 — Serpent's Toll & Damavand Chaining

Roguelite / boss levels: `enableZahhakTribute`, `enableDamavandBoss`.

#### Serpent's Tribute

- `hungerTimer` fills; at zero → **RequireTribute** UI.
- Player must tap-sacrifice a **max-level** tower.
- Failure: hero **max HP −25%**, **3 random regions** permanently corrupted.

#### Zahhak (infinite HP)

- `ZahhakBossController`: immune to tower damage; hero damage only.
- Waves are crowd control; boss is the objective.

#### Offensive tether

- Drag tether to Zahhak: rapid energy drain, **90% slow** — drag toward Damavand.

#### Damavand win

- `DamavandMountainArea` trigger: Zahhak inside + **≥2 Forge** towers adjacent → `TriggerVictory()`.

#### Fereydun's Binding Mosaic (2026-05-31)

**Campaign — 7 Khan seals (permanent puzzle pieces)**

- First clear of each `level_01`–`level_07` grants one **Khan seal** (`khan_seal_ids` in save).
- All 7 seals unlock **Hunt for Zahhak** (`DamavandQuestManager.can_enter_hunt_mode()`).
- **Khan 7** still runs a one-time **Damavand teaser** (`enableDamavandBoss`); repeatable binding is Hunt-only.

**Hunt — Star Iron → 3 Damavand anchors (repeatable)**

- Milestone waves drop **Star Iron**; **100 iron** auto-forges **1 anchor** (3 required per binding attempt; 2 after three lifetime bindings).
- Finale unlock (Hunt): **7 seals + all anchors for this attempt** AND **wave 50** (`HUNT_FINALE_WAVE_REQUIREMENT`).
- Near completion (≥90/100 toward next anchor): `AhrimanDirector` + `NemesisBattleDirector` increase pressure.
- **Damavand win** in Hunt: `on_hunt_binding_victory()` resets anchors, increments **Zahhak Fury** (boss HP / nemesis pressure).

**UI:** World map `BindingMosaicPanel` (7+3 grid); Hunt HUD shows seals, anchors, iron, binding #, fury tier.

#### Monetization (pay-to-progress, not pay-to-win)

- **Golden Blood Oath:** premium diamond cost for bonus shard rewards on milestone waves.
- **Simorgh's Blessing:** subscription doubles shard + organ drop rates.
- **Kaveh's AFK Forge:** offline shard drip; Zoroastrian Fire boost / instant fill via premium.
- **Fate Re-roll:** first reroll free per draft; later rerolls cost diamonds.
- **Simorgh Feather:** once per run continue — clear field, +3 lives.
- **Premium heroes:** Rostam/Zal free; Kaveh, Fereydon, Gordafarid via IAP stub SKUs.

#### Demon's Blood (organs)

- Khan bosses drop `OrganMutationData`; **drag from bottom-right HUD slot onto a tower** (`OrganMutationDragUI`).
- Example: White Demon blood on Shrine → adjacent Arrows gain temporary map-wide range.

---

### Deep-system Fate variants

| Fate ID | Boon | Curse |
|---------|------|-------|
| `fate_shattered_chrono_dial` | Rewind up to 10s | Extra regions corrupted per rewind second |
| `fate_couplet_immortal` | Couplet success: 6s invuln + infinite energy | Missed Rhyme Window halves morale |

---

### Fate Weaving (roguelite spine)

Every meaningful modifier choice is **double-edged**: a boon and a curse, never a pure upgrade. Framing uses Shahnameh tragedy and triumph — runs should feel like woven fates, not stat spreadsheets.

#### When Fates appear

- Before roguelite battles (draft 1 of 3)
- After elite and boss nodes (pick 1 reward)
- Daily challenge fixed Fate (optional)
- Campaign optional pre-battle Fate on hard paths

#### Fate data shape (target)

Each Fate defines:

- `id` — stable lowercase_snake_case
- `displayName` / `description` — myth-flavored copy
- **Boon** — one or more positive `BlessingType` or `DailyModifierType` effects
- **Curse** — one or more negative effects on the same battle/run

Existing systems to extend: `BlessingData`, `DailyModifierData`, `BattleRuntimeModifiers`, `BlessingSystem`, `BlessingChoicePanel`.

#### Example Fates

| Fate ID | Boon | Curse |
|---------|------|-------|
| `fate_rostams_rage` | Hero damage +100% | Hero cannot be healed |
| `fate_simorghs_gift` | Sacred Fire income +50% | Tower build cost +25% |
| `fate_ahrimans_haste` | Enemy speed -15% | Boss appears one wave earlier |
| `fate_kings_bounty` | Gold income +40% | Starting lives -2 |
| `fate_white_demons_chill` | Frost slow duration +30% | Hero skill cooldown +50% |
| `fate_divine_judgment` | All towers +20% sacred damage | Corruption spreads 2x faster |

#### Design rules

- Never offer three pure-positive choices in one draft.
- Curses must be felt within the same battle or the same roguelite run.
- Relic and blessing pools should be re-themed as Fates over time.

---

### Morale (supporting meter)

Morale is a **battlefield momentum** bar (0–100), not the headline hook. It makes the fight feel alive and ties hero/tower fantasy together without replacing Sacred Fire territory play.

#### Inputs (raise or lower morale)

| Event | Effect |
|-------|--------|
| Enemy kill | Small increase |
| Elite/boss kill | Large increase |
| Hero skill used (offensive) | Medium increase |
| Royal Command tower aura | Passive increase while active |
| Life lost (enemy reaches end) | Large decrease |
| Hero downed | Medium decrease |
| Corruption threshold crossed on a region | Small decrease |

#### Outputs

**High morale (e.g. 70+):**

- Tower attack speed bonus
- Hero energy gain bonus

**Low morale (e.g. 30-):**

- Barracks unit effectiveness reduced
- Bosses gain intimidation bonus (speed or damage)

Morale does not replace cleansing corrupted tiles; it modulates combat tempo globally.

---

### Hero Bonds (meta flavor)

Owning certain heroes unlocks passive bonuses and story moments. Bonds support the pillars above; they are not the signature mechanic alone.

Examples:

- Rostam + Zal: faster hero energy
- Zal + Simorgh: stronger cleansing and Sacred Fire efficiency
- Fereydon + Kaveh: morale bonus and Fate draft options

Mystery Tale roguelite nodes can deliver bond-specific story beats mid-run.

---

### Build order and status

| Phase | System | Code status | Art/UI polish |
|-------|--------|-------------|---------------|
| A | Fate Weaving + `FateMechanics` | Implemented | Copy + icons |
| B | Morale | Implemented | HUD bar styling |
| C | Sacred Fire / regions / hijack | Implemented | **Critical** — overlays, hijack read |
| 2 | Tether + Forge | Implemented | Beam VFX, hybrid silhouettes |
| 3 | Chrono + Couplet + Khan | Implemented | Rewind FX, rhyme UI flash |
| 4 | A* pathing + Moth | Implemented (per-level flag) | Path debug optional |
| 5 | Ahriman Director | Implemented | Boss modifier banner |
| 6 | Zahhak + Damavand + Tribute | Implemented | Boss, mountain, serpent HUD art |

### Tower Veterancy & Lineage

- Towers earn **veterancy XP** during battle from damage dealt and region cleanses on their build spot.
- **Stars (0–3)** grant in-run bonuses: +10% attack speed (1★), +15% damage (2★), awakened passive (3★).
- Towers that reach 3★ and survive grant a **family soul** post-victory.
- **Star Altar** (World Map): spend souls for permanent `TowerFamily` lineage upgrades.

### Hero battle XP & Hero Camp

- Heroes earn **session XP** from damage, kills, cleanses, skills, and tether uptime; banks to meta level on battle end (33% on defeat).
- **Hero Camp** (World Map): spend honor on per-hero upgrade branches (Combat / Tether / Sacred).

### Ferdowsi Archive

- **Mystery Tale** roguelite nodes assign a **prophecy** for the next battle.
- Completing the prophecy on victory grants a **chronicle page**; inserting it in the Archive applies a permanent global modifier.

### Jinn of the Desert

- Neutral **Jinn** may spawn mid-wave; hero skills can hit it for gold/SF loot while enraging active enemies.

### Qanat network

- Levels may define **Qanat nodes**; hero spends Sacred Fire to teleport between nodes.

**Next priority:** visual layer per [art/visual-vfx.md](../art/visual-vfx.md) — gameplay logic is in place; readability at mobile scale depends on art.

## 7. Roguelite Expedition

Run structure:

1. choose hero
2. choose starting tower set
3. enter branching node map
4. fight battles and elites
5. choose relic/blessing rewards
6. defeat final boss
7. earn permanent resources

Node types:

- Battle
- Elite
- Boss
- Merchant
- Shrine
- Mystery Tale
- Relic Forge
- Healing Spring

## 8. Daily Challenge

Daily challenge includes:

- fixed map
- fixed modifier
- fixed scoring rules
- leaderboard
- reward chest

## 9. Win/Loss

Win:

- all waves defeated (campaign / standard)
- boss defeated if boss level (HP reaches zero)
- **Damavand chain:** Zahhak in mountain trigger with 2+ Forge towers (roguelite finale)
- roguelite node victory returns to map

Loss:

- player lives reach zero
- protected objective destroyed (enemies reach gate)
- hero permanently crippled by repeated tribute failures (design tuning)
