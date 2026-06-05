# Main Gameplay Overview

**Last updated:** 2026-06-06  
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
| **Roguelite Path** | 5-node run with relic picks | After tutorial |
| **Endless** | Infinite waves on Labour 1 | 7 Labour seals |
| **Horde** | 15-wave survival per map | After tutorial |
| **Hunt for Zahhak** | Damavand boss hunt variant | 7 seals + 1 Elite tower at Kaveh's Forge |
| **Kaveh's Forge** | Permanent tower upgrades | Always (main menu or world map) |

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

Victory → forge materials / tokens banked → replay or return to map
```

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
| **Roguelite** | `is_roguelite_run` | ❌ No | Per node | Mixed run (L1, L2, L3 elite, L4) |
| **Hunt for Zahhak** | `is_hunt_mode` | ✅ Yes (`mode_zahhak`) | Damavand hunt rules | `level_08_damavand` only |
| **Daily Tale** | `is_daily_tale` | ❌ No | Labour 1 layout | `level_01` (daily seed) |

**Labour Modes only run in campaign** (`is_campaign_mode()`). Horde, Endless, Roguelite, and Daily Tale use the map layout and enemies but **not** the story hazard overlay.

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

**5-wave micro-loop (campaign):** Every map repeats escalating **5-wave blocks** — intro (waves 1–2), escalation (3–4), climax (5) — then **Pardeh Break** (Fate card pick). Mini-boss on every 10th wave; Hero's Vow every 10-wave block. Templates live in `scripts/meta/campaign_wave_templates.gd`.

| Block role | Waves in block | Purpose |
|------------|----------------|---------|
| Intro | 1–2 | New enemy type or lighter Labour hazard |
| Escalation | 3–4 | Swarms + pairings; corruptors tax Sacred Fire on hijack maps |
| Climax | 5 | Push Labour hazard before Pardeh; wave 10/20 = mini-boss climax |

**Labour + wave synergy (block 1 teaching beats):**

| Map | Wave design hook | Labour hazard sync |
|-----|------------------|-------------------|
| L1 Lion | Boars distract path; jackals swarm | Rakhsh ambush wave 1 |
| L2 Thirst | Mirage shades | Oasis pulse spawns mirages — heal or defend |
| L3 Dragon | Hounds rush while serpents burrow | 12s burrow cycle |
| L4 Temptress | Feast shades after decoys | Cleanse dispels illusions |
| L5 Olad | Raider funnel then boar flood | Second cave opens after wave 3 |
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

### Roguelite Path

- **5 nodes:** Woodland (L1) → Sacred Rest (relic pick) → Desert (L2) → Canyon Elite (L3) → Feast Trial (L4).
- Run state saved — resume from world map.
- Defeat clears the run; relics carry into battles.

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
  → Horde + Roguelite + Daily Tale available

Clear Labour N
  → Labour N+1 unlocked
  → Labour seal if default objective met on victory

Clear Labour 7
  → Damavand unlocked (campaign)

7 Labour seals
  → Endless unlocked
  → Rostam Barracks tower unlocked (or IAP)
  → Hunt for Zahhak eligible (also needs Elite forge)

Horde: 8/8 maps cleared
  → Serpent Spire tower unlocked (or IAP)
```

**Kaveh's Forge (meta):** Enemies drop Star Iron materials on campaign victory → upgrade starter towers permanently (levels 1–30, then 5 Elite steps). Elite tower required for Hunt.

**Forge Tokens:** Earned on victory → buy and cast **spells** from the battle HUD.

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
| Campaign-only Labour attach | `scripts/battle/battle_bootstrap.gd` → `_attach_labour_mode()` |
| Wave count + 5-wave block templates | `scripts/meta/campaign_wave_templates.gd` + `content_catalog.gd` → `wave_count_for()` |
| Pardeh cadence (every 5 waves) | `scripts/battle/wave_manager.gd` → `_should_offer_pardeh()` |

---

## 10. Related docs

| Doc | Use when you need… |
|-----|-------------------|
| [design/02-gameplay-ux.md](../design/02-gameplay-ux.md) | Design pillars, UX, corruption, hijack |
| [spec/entities-and-gameplay.md](../spec/entities-and-gameplay.md) | All towers, maps, art phases |
| [spec/gameplay.md](../spec/gameplay.md) | Full formulas and post-launch systems |
| [engineering/game-logic.md](../engineering/game-logic.md) | Battle state machine and ownership |
| [engineering/handoff.md](../engineering/handoff.md) | Onboarding for programmers |
