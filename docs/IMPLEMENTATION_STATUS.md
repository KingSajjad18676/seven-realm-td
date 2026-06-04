# Implementation Status — Gameplay & Mechanics

**Last updated:** 2026-06-04  
**Active engine:** Godot 4.6 — see [GODOT_PORT_STATUS.md](GODOT_PORT_STATUS.md) for playable truth  
**Unity reference:** archived under `_archive/unity/` (historical; no longer the default workflow)  
**Purpose:** Single source of truth for what is **playable today** vs **design target**, vs **not started**.  
**Design canon:** [DOC_INDEX.md](DOC_INDEX.md) → README_00–05  
**Onboarding:** [GAME_HANDOFF.md](GAME_HANDOFF.md) · [GAME_LOGIC_AND_ESSENTIALS.md](GAME_LOGIC_AND_ESSENTIALS.md)

**How to read tables:** **Design target** = PDF/README canon. **Built today** = Godot port status. Do not mark launch monetization as required just because stubs exist in code.

---

## Quick summary

| Question | Answer |
|----------|--------|
| Which engine to run? | **Godot** — open `shahname-td-godot/shahname-td`, press F5 |
| Can you play a full TD battle? | **Yes** (Godot) — waves, towers, hero, gold, lives, win/loss |
| Is the “signature identity” fully playable? | **Partially** — corruption, tether, morale, fates in code; several finale systems need content + level flags |
| Campaign content | **7 Khans** in catalog; **design: 8 maps** (+ Damavand Binding); layouts mostly shared template |
| Khan 1 gate | **Not validated** — voluntary replay signal per README_00 |
| Front-end flow | **Boot → CompanySplash → MainMenu → WorldMap** |
| Roguelite / daily / shop | **Scaffolded** — partial UI; launch store per README_03 not live |
| Biggest gap | **Art/VFX (README_01 Phase 0/1)** + distinct Khan layouts + replay proof |

> Godot wiring: [GODOT_PORT_STATUS.md](GODOT_PORT_STATUS.md). Milestones: [README_04](README_04_DEVELOPMENT_PRODUCTION_ROADMAP.md).

---

## Module A/B/C — Lore-driven endgame (2026-05-30)

| System | Status | Key types |
|--------|--------|-----------|
| Damavand Quest (10 chains) | ✅ | `StarIronShardService`, 100 shards/chain, `DamavandQuestManager` |
| Hunt finale gate (chains + wave 100) | ✅ | `HuntDirector`, `DamavandQuestManager.HuntFinaleWaveRequirement` |
| Shard loot pressure AI | ✅ | `AhrimanDirector.SetShardLootPressure`, `NemesisBattleDirector` |
| Blood Oath (Peyman) | ✅ built / 🟡 launch | Standard + premium tier in code; optional skill tests per README_02 |
| IAP / Premium gateway | 🟡 stub | `PremiumGateway` — **deferred** for soft launch ([README_03](README_03_ETHICAL_MONETIZATION_BUSINESS.md)) |
| Simorgh's Blessing (subscription) | 🟡 stub | **Not** launch monetization per README_03/05 |
| Kaveh AFK Forge | ✅ | `KavehForgeService`, `KavehForgePanel` |
| Fate Re-roll | ✅ | `FateRerollService`; paid reroll **deferred** — design favors fair reroll rules |
| Simorgh Feather continue | ✅ | `SimorghContinueService` — evaluate vs fair engagement (README_02) |
| Premium heroes | 🟡 stub | Code gates exist; **no paid overpowered heroes** at launch per README_03 |
| Zahhak's Fury (ascension) | 🟡 | `ZahhakFuryService` scaffold only |
| Nemesis (Kineye Ahriman) | ✅ | `NemesisManager`, `NemesisBattleDirector`, `NemesisEntry` |
| Hunt for Zahhak mode | ✅ | `BattleLaunchData.IsHuntMode`, `HuntDirector`, `HuntWaveGenerator` |
| Forge tower (Damavand) | 🟡 | `tower_forge` asset via setup; runtime unlock via `BattleRuntimeModifiers.ForgeBuildUnlocked` |

---

## Status legend

| Symbol | Meaning |
|--------|---------|
| ✅ | Implemented and usable in a normal play session |
| 🟡 | Code exists; incomplete content, wiring, or polish |
| ❌ | Not implemented or only documented |
| 🎨 | Logic works; art/VFX/readability still placeholder |

---

## 1. Core battle loop

| Step | Spec (GAMEPLAY_SPEC §1) | Status | Notes |
|------|-------------------------|--------|-------|
| Load level + map layout | ✅ | `LevelData.mapLayout`, `BattleMapBuilder` |
| Spawn paths + build spots | ✅ | Multi-path support (`path_a`, `path_b`) |
| Regional light state | ✅ | `MapLightManager` — one region per build spot |
| Build towers | ✅ | `TowerManager`, `TowerBuildPanel` |
| Position hero | ✅ | Tap ground → `HeroManager.HandleGroundTap` |
| Sacred Tether (drag) | ✅ | `HeroSacredTetherDrag` — separate from tap UI |
| Start waves | ✅ | `WaveManager.StartWaves()` |
| Enemies path to gate | ✅ | `PathFollower`, `EnemyController` |
| Corruptors darken regions | ✅ | `enemy_corruptor` + region decay |
| Towers target + shoot | ✅ | Target modes, projectile pool |
| Hijacked towers at light 0 | ✅ | `TowerController` layer/tag swap; hero can purge |
| Hero fight + ability | ✅ | Auto-attack + 2 skills (Rostam, Zal) |
| Epic Couplet / Rhyme Window | 🟡 | `CoupletComboManager` works; trigger mostly from hybrid fire (~12%) — no hybrid content yet |
| Spend gold / Sacred Fire | ✅ | `BattleEconomy` |
| Zervan Dial rewind | 🟡 | Hold rewind works; tower HP + hero energy not restored on rewind |
| Khan boss phases | 🟡 | Any `isBoss` enemy triggers phases — no Khan-specific boss content |
| Zahhak + Damavand finale | 🟡 | Controllers exist; no level enables flags; no boss prefab in waves |
| Win / loss | ✅ | Lives → defeat; all waves cleared → victory; Damavand trigger optional |

### Mobile input (spec table)

| Gesture | Status | Handler |
|---------|--------|---------|
| Tap build spot | ✅ | `TowerBuildSpot` → build/upgrade/sell |
| Tap max-level tower (tribute) | 🟡 | Works when `enableZahhakTribute`; no level sets flag |
| Drag hero → tower (tether) | ✅ | `HeroSacredTetherDrag` |
| Drag hero → Zahhak | 🟡 | Code in `HeroController`; needs Zahhak in scene |
| Hold Rewind | ✅ | `RewindButtonHandler` + `ZervanDialController` |
| Tap Cleanse / Brazier | ✅ | Sacred Fire spend on selected spot |
| Tap hero skill | ✅ | Rhyme Window bonus when active |
| Drag organ onto tower | 🟡 | `OrganMutationDragUI`; zero organ assets on disk |

---

## 2. Battle entities

### Enemy — runtime state

| Field / behavior | Status |
|------------------|--------|
| HP, speed, armor, MR | ✅ |
| Path progress | ✅ |
| Status effects (tick) | ✅ inline in `EnemyController` |
| Reward gold | ✅ |
| Tags / boss flag | ✅ |
| `pathRecalcCount` anti-juggle | ✅ |
| `isMothCorruptor` inverted A* | 🟡 code only; no moth enemy asset |
| Dynamic `WaypointPath` | 🟡 per-level flag; none enabled |
| Boss resistances (`BossModifierData`) | 🟡 no modifier assets |

### Tower — runtime state

| Field / behavior | Status |
|------------------|--------|
| Level, cooldown, range, damage | ✅ |
| `TowerFamily` | 🟡 enum + code; **tower `.asset` files omit family** (defaults to `None`) |
| Hybrid / pending recipe | 🟡 `AncestralForgeManager`; **0 combo assets** |
| Target mode | ✅ |
| Projectile + on-hit status | ✅ (status often unassigned on projectiles) |
| Regional light scaling | ✅ |
| Hijack at light 0 | ✅ |
| Tether AS multiplier + refraction | ✅ |
| Health + purge by hero | ✅ |
| Organ mutation buffs | 🟡 manager wired; no organ data |

### Hero — runtime state

| Field / behavior | Status |
|------------------|--------|
| HP, move, auto-attack | ✅ |
| Energy + tether drain | ✅ |
| Tether range, cleanse aura | ✅ |
| Skill cooldown + revive | ✅ |
| Offensive Zahhak tether | 🟡 needs Zahhak instance |
| Couplet invuln / infinite energy | 🟡 via `fate_couplet_immortal` fate |
| **Hero roster in data** | 2 of 6 planned (Rostam, Zal) |

---

## 3. Damage types

Enum in code: `Physical`, `Pierce`, `Magic`, `Fire`, `Sacred`, `Siege`, `Poison`, `True`.

| Type | Code support | Used in content |
|------|--------------|-----------------|
| Physical | ✅ | ✅ default on arrow/cannon projectiles |
| Fire | ✅ | 🟡 frost tower themed as Fire family in setup script only |
| Sacred | ✅ | 🟡 hero cleanse skill |
| Siege | ✅ | 🟡 cannon splash (damage type not always set in SO) |
| Pierce, Magic, Poison, True | ✅ | ❌ not assigned in current projectile assets |

---

## 4. Status effects

| Effect | Code (`EnemyController`) | SO asset | Used in combat |
|--------|--------------------------|----------|----------------|
| Slow | ✅ | ✅ `status_slow` | 🟡 frost tower (link often missing) |
| Burn | ✅ | ✅ `status_burn` | ❌ |
| Stun | ✅ | ❌ | ❌ |
| Poison | ✅ | ❌ | ❌ |
| Shield | ✅ | ❌ | ❌ |
| Corruption | ✅ | ✅ `status_corruption` | ✅ corruptors |
| Cleanse | ✅ | ✅ `status_cleanse` | ✅ hero skill |
| Armor Break, Heal OT, Fear, Reveal | ❌ | ❌ | ❌ |

`StatusEffectSystem` exists as a thin wrapper — **combat uses `EnemyController.TickStatusEffects()` directly**.

---

## 5. Tower families (design vs reality)

| Family | Design role (spec) | Tower in game | Family assigned on asset |
|--------|-------------------|---------------|--------------------------|
| Arrow | Physical ranged | Arrow tower | ❌ (None) |
| Fire | Sacred / burn | Frost tower (prototype) | ❌ |
| Siege | Splash | Cannon tower | ❌ |
| Barracks | Blockers | — | ❌ |
| Shrine | Cleanse support | — | ❌ |
| Command | Morale aura | — | ❌ |
| Forge | Damavand chains | — | ❌ |
| Hybrid | Ancestral output | — | ❌ |

**Impact:** Ancestral Forge adjacency, Ahriman family counters, tether refraction by family, and Damavand “2+ Forge towers” check **do not activate** until families are set (run `ShahnamehTD → Generate Project Setup` in editor, or assign manually).

---

## 6. Signature systems (identity pillars)

### A. Sacred Fire vs Corruption (flagship)

| Feature | Status | Detail |
|---------|--------|--------|
| Per-region light 0–100 | ✅ | `MapRegion.lightLevel` |
| Corruption spread on pass / corruptor | ✅ | |
| Tower weaken below light 30 | ✅ | cooldown + range scale |
| Tower disable / hijack at light 0 | ✅ | attacks allies/hero |
| Sacred Fire currency | ✅ | corruptor kills, fire tower hooks |
| Cleanse region (SF spend) | ✅ | 25 SF default |
| Light brazier | ✅ | +40 light |
| Permanent corruption | ✅ | tribute fail, rewind echo |
| Morale drop on corruption threshold | ✅ | |
| Regional overlay / hijack VFX | 🎨 | placeholder tints only |

### B. Fate Weaving (roguelite spine)

| Feature | Status | Detail |
|---------|--------|--------|
| Double-edged `BlessingData` (boon + curse) | ✅ | 6 fate assets |
| `BattleRuntimeModifiers` apply in battle | ✅ | |
| Pre-battle fate draft | 🟡 | only `level_03` has `requiresPreBattleFateDraft` |
| `FateMechanics` tuning flags | 🟡 | static config (chrono 10s, couplet invuln) |
| Fate-specific icons / copy polish | 🎨 | |
| Full spec fate table (8+ fates) | 🟡 | partial pool |

### C. Morale (support meter)

| Feature | Status | Detail |
|---------|--------|--------|
| 0–100 meter | ✅ | `MoraleController` |
| Gains: kills, skills, elites | ✅ | |
| Losses: lives, hero down, corruption | ✅ | |
| High morale → tower AS, hero energy | ✅ | |
| Low morale → barracks penalty, boss intimidation | 🟡 | no barracks towers yet |
| HUD bar | ✅ | slider; ornate frame 🎨 |

### Module 2 — Tether & Ancestral Forge

| Feature | Status |
|---------|--------|
| Drag tether hero → tower | ✅ |
| AS bonus by distance | ✅ |
| Energy drain + sever | ✅ |
| Hybrid refraction (50% to same-family neighbors) | 🟡 needs hybrid + families |
| Hero passive cleanse in region | ✅ |
| Adjacency forge → pending hybrid upgrade | 🟡 **0 `TowerCombinationData` assets** |
| Phoenix Bow example hybrid | ❌ created by editor setup only, not committed |

### Module 3 — Zervan, Couplet, Khan

| Feature | Status |
|---------|--------|
| 50 × 0.1s snapshot buffer | ✅ |
| Hold rewind | ✅ |
| Restore enemy pos/HP/path | ✅ |
| Restore region lights | ✅ |
| Ahriman Echo permanent corruption on rewind path | ✅ |
| Restore tower HP | ❌ skipped in `ApplySnapshot()` |
| Restore hero energy | ❌ |
| Rhyme Window 1.5s | ✅ |
| Epic Couplet payoff (clear, relight, morale) | ✅ |
| Khan phase every 15% boss HP | ✅ |
| Phase regional light penalty + banner | ✅ |

### Module 4 — Dynamic shadow pathing

| Feature | Status |
|---------|--------|
| Light-weighted A* | ✅ `AStarPathfinder` |
| Moth corruptor (seek light) | 🟡 flag on `EnemyData`; no asset |
| Anti-juggle speed/scale | ✅ |
| Recalc on topology change | ✅ `PathRecalcListener` |
| **Enabled on any level** | ❌ `useDynamicPathfinding` false on all levels |

### Module 5 — Ahriman Director

| Feature | Status |
|---------|--------|
| Dominant family tally (10s) | ✅ `PlayerTacticsAnalyzer` |
| Pick counter modifier on phase | ✅ `AhrimanDirector` |
| Apply boss resistances | ✅ |
| **`BossModifierData` assets** | ❌ folder empty |
| Director warning banner | ✅ UI hook |

### Module 6 — Serpent's Toll & Damavand

| Feature | Status |
|---------|--------|
| Tribute hunger timer | ✅ `ZahhakTributeManager` |
| Sacrifice max-level tower | ✅ |
| Fail: hero max HP −25%, 3 regions permanent corrupt | ✅ |
| Zahhak infinite HP, hero-only damage | ✅ `ZahhakBossController` |
| Offensive tether slow | ✅ |
| Damavand trigger + 2 Forge towers → win | 🟡 no scene trigger + no Forge towers |
| Organ drop on Khan phase | 🟡 **0 `OrganMutationData` assets** |
| Organ drag UI | ✅ |

---

## 7. Standard TD features

| Feature | Status | Notes |
|---------|--------|-------|
| Wave scheduling | ✅ | fixed + boss wave assets |
| Endless waves | ✅ | `EndlessWaveGenerator` |
| Tower build / upgrade / sell | ✅ | 2 upgrade tiers per tower |
| Target modes | ✅ | first/last/strong/weak/etc. |
| Object pooling | ✅ | enemies, projectiles |
| Floating damage text | ✅ | |
| Pause + 1×/2× speed | ✅ | |
| Range indicator | ✅ | |
| Post-battle rewards | ✅ | soft currency, stars, progression |
| Lives at gate | ✅ | |
| Relics in battle | 🟡 | 3 relic assets, applicator exists |
| Quest tracking in battle | ✅ | daily build/kills/wins |

---

## 8. Meta & replay modes

| System | Status | Notes |
|--------|--------|-------|
| Boot → Splash → Main Menu → World Map | ✅ | `Boot`, `CompanySplash`, `MainMenu`, `WorldMap`; `SceneFlowController` |
| Campaign 7-Khan chain | ✅ | unlock via save; Endless gated by `AllKhansCompleted()` |
| Endless mode unlock | ✅ | Requires all 7 Khans completed |
| Hunt mode unlock | ✅ | First Talisman on Khan 7 win |
| Main menu meta panels | ✅ | Same toolbar as world map + Credits |
| Monetization / Kaveh Forge UI | ✅ | Wired in setup generator |
| Hero progression | ✅ | in-battle XP + Hero Camp honor upgrades |
| Tower progression | 🟡 | unlock UI + **veterancy + lineage** |
| Tower veterancy (in-run stars) | ✅ | `TowerVeterancyManager`, per-family XP |
| Lineage / Star Altar | ✅ | souls on 3-star survival, `StarAltarPanel` |
| Ferdowsi Archive | ✅ | prophecies, chronicle pages, `FerdowsiArchivePanel` |
| Jinn of the Desert | ✅ | `JinnSpawnDirector`, greed escalation |
| Qanat fast travel | ✅ | `QanatNetworkManager`, level map nodes |
| Relic equip | 🟡 | save + battle applicator |
| Daily challenge | ✅ | date-seeded level + modifier + fate |
| Daily bazaar (shop) | 🟡 | rotating currency packs; 6 shop items |
| Roguelite expedition | 🟡 | `RogueliteRunController`, `RogueliteMap` scene; node templates exist |
| Blessing pick after node | ✅ | |
| Weekly boss trial | 🟡 | service stub, victory hook |
| Battle pass | 🟡 | service stub |
| Events (Nowruz) | 🟡 | 1 event asset |
| Cosmetics | 🟡 | 2 skins, service exists |
| Analytics interface | ✅ | `AnalyticsService` |
| Save system | ✅ | progress, currencies, dailies |

### Roguelite node types (spec §7)

| Node type | Status |
|-----------|--------|
| Battle | ✅ template asset |
| Elite | 🟡 uses battle flow + blessings |
| Boss | ✅ template asset |
| Merchant | ✅ |
| Shrine | ✅ |
| Mystery Tale | ✅ | prophecy handoff via `RogueliteRunController` |
| Relic Forge | ❌ |
| Healing Spring | ❌ |

### Scenes

| Scene | Planned (TECHNICAL_DESIGN) | Exists |
|-------|---------------------------|--------|
| Boot | ✅ | ✅ |
| CompanySplash | ✅ | ✅ (generated) |
| MainMenu | ✅ | ✅ (generated; meta hub) |
| WorldMap | ✅ | ✅ |
| Battle | ✅ | ✅ |
| RogueliteMap | ✅ | ✅ |
| Shop | ✅ | ❌ (bazaar on world map / main menu) |
| HeroCamp | ✅ | ❌ (hero panel on menu/map) |
| EventHub | ✅ | ❌ |

---

## 9. Content inventory (ScriptableObjects on disk)

Counts are committed `.asset` files under `Assets/_Project/ScriptableObjects/`.

| Category | Count | IDs / notes |
|----------|------:|-------------|
| **Towers** | 12 | arrow, cannon, frost + 2 upgrades each + 3 projectiles |
| **Enemies** | 5 | grunt, runner, brute, corruptor, boss |
| **Heroes** | 2 | rostam, zal |
| **Levels (campaign)** | 3 | level_01, level_02, level_03 |
| **Roguelite nodes** | 3 | battle, merchant, boss templates |
| **Waves** | 3 | wave_01, wave_02, wave_boss |
| **Fates / blessings** | 6 | e.g. rostams_rage, simorghs_gift |
| **Status effects** | 4 | burn, slow, cleanse, corruption |
| **Relics** | 3 | sacred_flame, golden_shah, arrow_quiver |
| **Shop items** | 6 | gold/honor packs, blessing modifiers |
| **Quests** | 3 | daily build, kills, wins |
| **Cosmetics** | 2 | rostam gold, zal silver |
| **Events** | 1 | nowruz |
| **Tower combinations** | **0** | need `TowerCombinationData` |
| **Organ mutations** | **0** | need `OrganMutationData` |
| **Boss modifiers** | **0** | need `BossModifierData` |

**Level flags today**

| Flag | level_01 | level_02 | level_03 |
|------|----------|----------|----------|
| `requiresPreBattleFateDraft` | ❌ | ❌ | ✅ |
| `useDynamicPathfinding` | ❌ | ❌ | ❌ |
| `enableZahhakTribute` | ❌ | ❌ | ❌ |
| `enableDamavandBoss` | ❌ | ❌ | ❌ |

Roguelite battles auto-enable tribute via `BattleBootstrap` when launched from a run.

---

## 10. PRD scope checklist

### MVP (PRD §4)

| Requirement | Status |
|-------------|--------|
| One playable battle scene | ✅ |
| One complete path | ✅ (multi-path on levels) |
| Enemy spawner + waves | ✅ |
| One tower type | ✅ (3 in slice) |
| One hero | ✅ (2 in slice) |
| Projectile + damage | ✅ |
| Win/loss | ✅ |
| Mobile landscape HUD | ✅ | Pause overlay, hero portrait slot, results stats, Simorgh panel, hunt progress |
| World map + 3 levels | ✅ |
| ScriptableObject upgrades | ✅ |

### Vertical slice (PRD §5)

| Requirement | Target | Status |
|-------------|--------|--------|
| Towers | 3 | ✅ arrow, cannon, frost |
| Hero | Rostam | ✅ (+ Zal) |
| Enemy types | 5 | ✅ 4 + boss |
| Campaign maps | 5 | 🟡 **3** |
| Boss | 1 | 🟡 generic boss enemy, not Khan/Zahhak scenario |
| Tower upgrades | yes | ✅ |
| Hero ability | yes | ✅ |
| Daily challenge prototype | yes | ✅ |
| Shop placeholder | yes | ✅ daily bazaar |
| Roguelite 5 nodes | yes | 🟡 flow exists; graph is minimal |

### Full launch (PRD §6) — not started

6 heroes, 6 tower families, 50+ levels, 5 bosses, live events, battle pass, bonds, etc.

---

## 11. Known code gaps (not just missing art)

1. **Tower families unset on disk** — forge, director, refraction, Damavand checks inactive until assigned.
2. **Deep-system assets not committed** — `ShahnamehTDSetup.cs` can generate combo/organ/modifier assets; folders empty in repo.
3. **Zervan incomplete restore** — tower HP and hero energy not rewound (`ZervanDialController.ApplySnapshot`).
4. **Regions = build spots** — spec describes path-segment clusters; implementation is 1:1 spot regions.
5. **Only 2 hero skills hard-coded** — `HeroController` picks `RostamMaceSlam` or `ZalSacredCleanse` by hero id.
6. **HijackedTower layer** — must exist in Unity Tags/Layers for hijack combat.

---

## 12. How to test in Unity

### Core campaign

1. Run **ShahnamehTD → Generate Project Setup**, then open **Boot** → Play.
2. Flow: Splash → Main Menu → **Play Campaign** → World Map.
3. Select **Khan 1** (`level_01`) on the map.
3. Build towers on spots → **Start Wave**.
4. Move hero (tap ground), use skill button, spend Sacred Fire on cleanse/brazier if corruptors darken spots.
5. **Expected:** enemies follow paths; towers shoot; lives decrease on leaks; victory when waves clear.

### Signature systems (best current level)

1. Run editor menu **ShahnamehTD → Generate Project Setup** (assigns families, deep assets, layers).
2. Play **level_03** — fate draft before battle.
3. Test rewind (hold UI), tether (drag hero to tower), morale bar movement.

### Roguelite

1. From world map → Roguelite entry → **RogueliteMap** scene.
2. Pick nodes → battle → blessing rewards.

### Edge cases to verify

- Corruptor darkens spot → tower weakens → hijack at 0 → hero purges.
- Pause / 2× speed during active wave.
- Sell tower refunds gold.
- Daily challenge claim once per day.

---

## 13. Recommended next steps (priority order)

1. **Run project setup + commit generated SOs** — tower families, phoenix combo, ash_cloak modifier, demon organ.
2. **Flag level_03** — `useDynamicPathfinding`, `enableZahhakTribute` for integrated deep-system test map.
3. **Visual vertical slice** — [VISUAL_AND_VFX_SPEC.md](VISUAL_AND_VFX_SPEC.md): region overlay, tether beam, hijack read.
4. **Fourth–fifth campaign levels** + Khan boss wave with modifiers.
5. **Damavand test scene** — Zahhak prefab, mountain trigger, 2 Forge tower placeholders.
6. **Complete Zervan restore** — tower HP API + hero energy in snapshots.

---

## 14. Related docs

| Doc | Use when |
|-----|----------|
| [GAME_LOGIC_AND_ESSENTIALS.md](GAME_LOGIC_AND_ESSENTIALS.md) | Battle flow, BattleContext, architecture rules, file map |
| [GAMEPLAY_SPEC.md](GAMEPLAY_SPEC.md) | Full design rules and target behavior |
| [PRD.md](PRD.md) | Product scope and launch targets |
| [DEVELOPMENT_ROADMAP.md](DEVELOPMENT_ROADMAP.md) | Phase plan and current focus |
| [TECHNICAL_DESIGN.md](TECHNICAL_DESIGN.md) | Managers, scenes, input map |
| [VISUAL_AND_VFX_SPEC.md](VISUAL_AND_VFX_SPEC.md) | Art checklist for readability |
| [GAMEPLAY_AND_ASSET_REQUIREMENTS.md](GAMEPLAY_AND_ASSET_REQUIREMENTS.md) | Player flow, mechanics summary, asset checklist |

**Maintenance:** Update this file when adding levels, enabling level flags, or shipping a formerly partial system to ✅.
