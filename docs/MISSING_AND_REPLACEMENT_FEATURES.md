# Missing and Replacement Features — Rostam 7 Labours: Shahname TD

**Last updated:** 2026-06-11
**Sources:** full audit of `docs/` (design canon, implementation-tracker, project-status) and `scripts/` / `scenes/` / `resources/` (code reality).
**Scope rule:** no combat rewrite. Improve what exists first. All ideas respect the Khan 1 gate ([design/00-project-index.md](design/00-project-index.md) §3) and monetization canon ([design/03-monetization.md](design/03-monetization.md)).

**Code reality baseline (verified, not assumed):**

| Content | In code today |
|---|---|
| Towers | 8 (4 starters + Flame Archer, Volcano Ram, Serpent Spire, Barracks) |
| Enemies | 26 (9 phase-controller bosses + 17 grunts/specials) |
| Heroes | 3 (Rostam, Zal, Sohrab) |
| Fate cards | **8** (design target 43) |
| Relics | **7** (3 global + 4 per-tower slot), no synergies |
| Companions | 3 shrine picks + Rakhsh, no progression |
| Equipment | 7 sets × 4 pieces = 28 |
| Modes | Campaign, Campaign Run, Horde, Endless, Gauntlet, Brothers in Arms, Defend the Throne, Hunt for Zahhak, Daily Tale |
| Not in code | Bestiary/codex, player titles, run history, heat system, relic synergies, nemesis director (deferred), Daily Tale modifiers, Simorgh continue |

---

## 1. Analysis of Existing Features

Legend for verdicts: **STAY** (good as-is) · **IMPROVE** · **MERGE** · **REPLACE** · **DEMOTE** (hide from UI for now).

### 1.1 Campaign Run (branching roguelite graph)

| Question | Answer |
|---|---|
| More fun? | Yes — it is the strongest replay loop in the game (draft, branch, shrine, Throne of Kavus gamble, Damavand finale). |
| More replayable? | Yes, but ceiling is low: node *types* are few (skirmish / anvil / shrine / Kavus / boss / finale) and skirmishes are always 15 waves on the same maps. After 2–3 runs the graph reads the same. |
| Meaningful choices? | Yes (draft 3 towers, branch picks, shrine companion-or-relic, Kavus risk). Best decision density in the game. |
| 7-Khan lore? | Medium — node names are mythic but nodes have no story text; the journey doesn't *feel* like the Haft-Khan march yet. |
| Easy to understand? | Mostly. Ahriman's Shroud second SF wallet is the one cognitively heavy part (docs flag this themselves). |
| Too complicated? | No. |
| Too similar to another system? | Overlaps the deprecated legacy roguelite (already migrated — finish removing the legacy scene). |
| **Verdict** | **IMPROVE.** This is the spine. Invest in node variety + story events here before any new mode. Remove `scenes/roguelite_map/` legacy path from player reach. |

### 1.2 Fate cards (Pardeh Break)

| Question | Answer |
|---|---|
| More fun? | Yes — boon+curse picks every 5 waves is the signature beat. |
| More replayable? | **Weak today: only 8 cards.** With 3 offered per Pardeh and Pardehs every 5 waves on a 30–100 wave map, players see the whole pool in one long battle. Repetition kills the "turning a page" fantasy. |
| Meaningful choices? | Yes individually, but no build-around depth because cards don't interact with relics or each other. |
| 7-Khan lore? | High potential (Pardeh = curtain of an illustrated epic) but cards carry zero story text. |
| Easy to understand? | Yes. |
| Too complicated? | No. |
| Too similar? | Risk of blur with relics — both are "pick a modifier." Current separation (Fate = this battle, relics = this run, per tower) is right but never *explained* to the player. |
| **Verdict** | **IMPROVE.** Priority: grow pool toward ~24 cards in data (art can stay placeholder), add one line of Shahnameh flavor per card, and make several cards reference relic tags (see §2 Relic Synergy Tags). Do NOT need all 43 now. |

### 1.3 Relics of the Shahs

| Question | Answer |
|---|---|
| More fun? | Mildly — 7 relics, mostly flat stat passives (+8% dmg, +8 gold/wave). |
| More replayable? | Weak. No synergies coded, pool too small to vary builds. |
| Meaningful choices? | Per-tower slotting is a good mechanic, but with ≤2 relics per tower type there is rarely a real choice. |
| 7-Khan lore? | Names are excellent (Cup of Jamshid, Mace of Feridun) — effects don't echo the stories. |
| Easy to understand? | Yes. |
| Too similar? | Borders Equipment sets (both are passive stat layers). Distinction: relics = run-scoped, equipment = account-scoped. Keep that line hard. |
| **Verdict** | **IMPROVE — highest-leverage system in the game.** Add synergy tags + boss trophy relics (§2). Relics should become the run-identity system ("this was my Jamshid-fire run"). |

### 1.4 Companions

| Question | Answer |
|---|---|
| More fun? | Yes — Cheetah auto-banking, Zavareh gate guard, Simurgh light pulses are all felt in play. |
| More replayable? | Weak: 3 picks, max 1/run, no growth. The choice happens once and is then static for the whole run. |
| Meaningful choices? | One good choice at the first shrine, then nothing. |
| 7-Khan lore? | Strong fit (Rakhsh, Zavareh are canon). Underexploited. |
| Easy to understand? | Yes. |
| Too complicated? | No. |
| **Verdict** | **IMPROVE.** Bond levels within a run (companion grows from battles survived) is the obvious upgrade — emotional and cheap (§2). |

### 1.5 Kaveh's Forge (Star Iron meta)

| Question | Answer |
|---|---|
| More fun? | Functional, not exciting — +4% damage per level is the least interesting kind of progression. |
| More replayable? | Yes mechanically (soft gate at Labour 3+ pushes replays for Star Iron) — but "replay because you're undergeared" is the *grind* kind of replay, not the *want* kind. The Khan 1 gate KPI is *voluntary* replay; forge-gate replay can mask it. |
| Meaningful choices? | Some (which tower to level first), shallow. |
| 7-Khan lore? | Kaveh is a great anchor; the forge itself is a menu. |
| Too complicated? | The split between Forge / Equipment / Relics / Spells / reward towers is **four-plus parallel progression tracks** — docs themselves flag this. Each is fine alone; together they're a lot for mobile onboarding. |
| **Verdict** | **STAY, simplify presentation.** Don't add a fifth track. Future: per-tower forge *perk choice* at milestone levels (10/20/30) instead of pure %, but later. |

### 1.6 Star Iron scavenging

| Question | Answer |
|---|---|
| More fun? | Yes — physical pickups + unbanked risk is a genuinely good signature mechanic. |
| Meaningful choices? | Yes: keep fighting vs Retreat to Forge is a real tension beat. |
| Problem | **Defeat clears 100% of unbanked iron.** Combined with no defeat recap, losing = "you got nothing, you learned nothing." This is the single biggest "losing feels bad" lever in the game. |
| Too similar? | Star Iron is also the Hunt binding-anchor resource — two contexts, one name, no unifying copy. Minor confusion. |
| **Verdict** | **IMPROVE the defeat side only.** Keep 100% combat-resource loss (the tension is good) but add a small *non-iron* consolation ("Memory of the Fallen" — see §3.6). Do not soften banking rules. |

### 1.7 Equipment sets (Haft-Khan Equipment)

| Question | Answer |
|---|---|
| More fun? | Set bonuses (dash knockdown, gate rebuild) are real gameplay, good. |
| More replayable? | Yes (chase 28 pieces from bosses + daily chest). |
| Meaningful choices? | Mixing 2+2 sets vs 4-set is a real decision. |
| 7-Khan lore? | Sets are named per Labour — good, but acquisition is disconnected from the Labour identity (daily chest drops random helms). |
| Too similar? | Closest overlap risk with relics. Survives because account-scoped vs run-scoped — but the *player* doesn't know that rule. |
| **Verdict** | **STAY, tighten identity.** Make boss kills on Labour N always drop Labour N set pieces (mostly true already), and label everything in UI: "Equipment = forever, Relics = this run, Fate = this battle." One tooltip, big clarity win. |

### 1.8 Daily Missions

| Question | Answer |
|---|---|
| More fun? | Neutral — 10-mission pool of generic "do X N times" tasks. |
| More replayable? | Login driver, yes; excitement driver, no. |
| 7-Khan lore? | **None.** This is the most theme-naked system in the game. |
| Too similar? | Overlaps the legacy liveops scaffold (daily quests/login calendar in `liveops/retention.md`) — keep only one daily-task system, this one. |
| **Verdict** | **REPLACE skin, keep skeleton** → "Heroic Deeds" with Shahnameh framing (§3.1). Logic and save format unchanged. |

### 1.9 Daily Tale

| Question | Answer |
|---|---|
| More fun? | **Weakest shipped feature.** Code reality: it always launches `level_01` with a date flag — the promised "fair modifiers" are not implemented. Today it is literally "play Labour 1 again, once a day." |
| Meaningful choices? | None. |
| Easy to understand? | Yes, because there's nothing to it. |
| **Verdict** | **IMPROVE-or-DEMOTE.** Either ship the seeded modifier set (2–3 mutators/day — small work since `runtime_modifiers` already exists) or hide the button until it does something. Shipping a dead daily teaches players the dailies aren't worth checking. |

### 1.10 Horde

| Question | Answer |
|---|---|
| More fun? | OK — 15-wave quick session per map. |
| More replayable? | Carries the Serpent Spire unlock (8 clears) so it gets played, then dies. |
| Too similar? | **Most redundant mode.** Same maps, same rosters, shorter wave count, no Labour overlay. It's "campaign lite." |
| **Verdict** | **MERGE direction:** keep as quick mode, but give it identity via weekly elite-modifier rotation per map (Khan-specific elite affixes, §4). If that never ships, it's a candidate for folding into Daily Tale as the "quick seeded battle" slot. |

### 1.11 Endless

| Question | Answer |
|---|---|
| More fun? | Standard endless; scaling is jackal/boar count growth — pressure but not *new questions*. Design doc itself demands "scale combinations, not HP." |
| More replayable? | For score-chasers, with `endless_best` saved. There is no leaderboard/records screen to make the number matter. |
| Locked behind | 7 Labour seals — extremely late for a side mode. |
| **Verdict** | **STAY, low priority.** Cheapest improvement: show personal records on the world map (§2 Run History) so the number players already earn becomes visible. Consider unlocking at 3 seals. |

### 1.12 Haft-Khan Gauntlet

| Question | Answer |
|---|---|
| More fun? | Yes for the skill-player niche — boss rush + ms ghost PB + Rush risk is the best-designed side mode. |
| Too similar? | Reuses campaign bosses deliberately. Fine. |
| **Verdict** | **STAY.** Only tie its PB into the records/titles layer when that exists. |

### 1.13 Brothers in Arms (co-op)

| Question | Answer |
|---|---|
| More fun? | Yes when used; local couch co-op on mobile is niche. |
| Too complicated? | Split SF/loot wallets are under-explained. |
| **Verdict** | **STAY, freeze.** Do not invest until Khan 1 replay is proven. Not a retention lever for the core audience. |

### 1.14 Defend the Throne

| Question | Answer |
|---|---|
| More fun? | A 15-wave radial arena — novel layout, but one map, no progression hooks, no unlock attached, no Labour overlay. |
| Too similar? | It is Horde-with-radial-spawns. Docs never justify its retention value vs Horde/Endless. |
| **Verdict** | **DEMOTE or MERGE.** Lowest-value mode on the menu. Options: (a) fold the radial arena into Campaign Run as a special "Siege of the Throne" node type — instantly makes Campaign Run more varied and deletes a menu button; (b) keep hidden until it has a reward chain. Recommend (a). |

### 1.15 Hunt for Zahhak

| Question | Answer |
|---|---|
| More fun? | Yes — binding shards + repeatable Fury escalation is a real endgame chase. |
| 7-Khan lore? | Strongest lore framing in the game. |
| Problem | The promised Nemesis/Ahriman Director pressure (spec) is deferred in code — the hunt is less adaptive than designed. Also "Campaign Damavand vs Hunt Damavand" confuses players (two finales, same mountain). |
| **Verdict** | **STAY, clarify.** One UI line distinguishing the authored finale from the repeatable hunt. Director AI stays deferred (high risk). |

### 1.16 Labour Mode hazards

| Question | Answer |
|---|---|
| More fun? | Yes — this is where map identity lives (Thirst drain + oasis, Blindness darkness, Demons second front). Best lore-to-mechanics translation in the game. |
| Problem | `mode_zahhak` is alert-only (messaging, no hazard). Hazards have no codex/recap — players who lose to a hazard get no explanation of what it was. |
| **Verdict** | **STAY + small IMPROVE.** Feed hazard names into the defeat recap (§2) and the future codex. Give `mode_zahhak` one real hazard when Damavand art lands. |

### 1.17 Corruption / hijack

| Question | Answer |
|---|---|
| More fun? | Yes — signature threat, fully built (light states, 3.5 s hijack warning, SF purify). |
| Easy to understand? | The mechanics are fair; the *readability* on placeholder art is the flagged risk (art problem, not design problem). |
| **Verdict** | **STAY.** Touch nothing mechanical. The defeat recap should name corruption/hijack as a death cause ("Region collapsed → Heavy Tower hijacked → gate fell"). |

### 1.18 Sacred Fire

| Question | Answer |
|---|---|
| More fun? | Yes — scarce tactical resource with multiple sinks (cleanse, purify, reroll, vow rewards). |
| Too complicated? | Only the Ahriman's Shroud run-wallet variant. Acceptable for an endgame mode. |
| **Verdict** | **STAY.** It is the theme. |

### 1.19 Boss encounters

| Question | Answer |
|---|---|
| More fun? | Yes — all 9 bosses have phase controllers with unique mechanics (Lion roar ambush, Thirst drought SF drain, Zahhak binding ritual). NOT stat checks. The design work is done. |
| Problem | Bosses give nothing memorable on death except equipment drops. No trophy, no story beat, no codex entry. The kill *feels* smaller than it is. |
| Mini-bosses | Every-10th-wave mini-bosses are stat-heavy waves, fine for rhythm. |
| **Verdict** | **STAY + IMPROVE rewards** → Boss Trophy Relics (§2). |

### 1.20 Cross-cutting findings

1. **The post-battle moment is the weakest screen in the game.** One overlay panel lists numbers. No story, no cause-of-death narrative, no records, no "one more run" energy. Yet voluntary replay is *the* product KPI.
2. **Too many parallel progression tracks** (Forge, Equipment, Relics, Spells, reward towers) and **too many sibling modes** (Horde / Endless / Throne / Daily Tale overlap). Add depth to existing tracks; do not add tracks or modes.
3. **Lore is in the names, not in the play.** Pardeh has no text, missions are generic, bosses drop no stories. Cheap text-data fixes, huge theme wins.
4. **Losing is pure punishment** (100% unbanked iron loss, no recap, no consolation, Simorgh continue deferred).
5. **Records exist in save data but not on screen** (`endless_best`, `gauntlet_best`, `hunt_best_binding`, mission lifetime stats, per-level replay counts). Free retention left on the table.

---

## 2. Missing Features (detailed)

### 2.1 Heroic Recap (victory and defeat)

| Field | Detail |
|---|---|
| What it does | Replaces the bare `%ResultsPanel` numbers with a 3-beat narrative recap: (1) **cause line** — for defeat, the actual kill chain pulled from battle events ("The Salt Brute broke the gate while the eastern region lay collapsed"); for victory, the standout fact ("No tower fell to hijack"); (2) **deeds list** — 3 auto-picked highlights (vows honored, regions cleansed, boss phases survived, iron banked); (3) one-tap **Fight Again** as the visually dominant button. |
| Why more fun | Every run ends on meaning instead of a stat dump. Defeats become stories. |
| Why more repeatable | Directly serves the Khan 1 KPI: "understand result → one-tap replay." Knowing *why* you lost is the #1 driver of "I can fix that — one more run." |
| Connects to | `battle_results_formatter.gd`, `battle_hud_controller.gd`, objectives, Hero's Vow tally, `MapLightManager` (collapse events), boss controllers (phase events). |
| Lore | Recap copy written as Ferdowsi-style chronicle lines ("Thus fell Rostam at the Second Labour, undone by thirst"). |
| Size | **Small–Medium** |
| Risk | **Low** — UI + event logging only, zero combat changes. |
| Minimal version | Track last gate-damage source + last collapsed region + last hijack in a tiny `RunChronicle` dictionary inside battle state; format 1 cause line + 3 deed lines on the existing panel; restyle the replay button. |
| Upgraded version | Per-Labour chronicle templates, illustrated Pardeh-frame background, share/screenshot, recap feeds run history. |
| Files | Inspect: `scripts/ui/battle_hud_controller.gd`, `scripts/battle/battle_state_controller.gd`, `scripts/ui/battle_results_formatter.gd`, `scripts/battle/objective_controller.gd`. Modify: those + new `scripts/battle/run_chronicle.gd`. |
| Testing | Defeat by gate leak / by hijacked tower / by boss → distinct cause lines. Victory shows deeds. Gauntlet/endless panels unaffected. Replay button fires `replay_selected` analytics. GUT test for `RunChronicle` formatting. |

### 2.2 Boss Trophy Relics

| Field | Detail |
|---|---|
| What it does | Killing a Labour boss in Campaign Run offers a **choice of 1 of 2 trophy relics** unique to that boss (e.g. Lion: *Pelt of the First Labour* — heavy towers taunt; *Lion's Fang* — hero crit vs full-HP enemies). Trophies are run-scoped relics in the existing slot system. |
| Why more fun | Bosses become reward moments, not just obstacles. The strongest fight gives the strongest loot decision. |
| Why more repeatable | 7 bosses × 2 trophies = 14 new build directions; players reroute runs to reach a boss whose trophy fits their draft. |
| Connects to | Existing `RelicData` + `relic_slot_picker_controller.gd` + `campaign_run_state.gd` boss-node completion. No new system. |
| Lore | Each trophy is a named artifact from that Labour's story — the most direct Haft-Khan theming possible. |
| Size | **Medium** (mostly data: 14 relic defs + picker hook) |
| Risk | **Low–Medium** (balance only). |
| Minimal version | 2 trophies for the Lion only (Khan 1 gate friendly); picker fires after `node_labour_boss` victory. |
| Upgraded version | All 7 bosses + Zahhak; trophy display on run map; codex records trophies earned. |
| Files | Inspect: `scripts/meta/content_registry.gd` (`_build_default_relics`), `scripts/meta/campaign_run_state.gd`, `scripts/ui/relic_slot_picker_controller.gd`. Modify: those + relic defs. |
| Testing | Trophy offered only on run boss kill; persists in `tower_relic_slots` save v7; ContentValidator passes on new relic IDs; duplicate-slot replace flow works. |

### 2.3 Relic Synergy Tags

| Field | Detail |
|---|---|
| What it does | Every relic and several Fate cards get 1–2 tags from a small set (**Fire, Light, Iron, Beast, Royal, Shadow**). Holding 2+ relics sharing a tag activates a visible set spark (e.g. 2× Fire: burns spread once). Tags shown as icons in pickers. |
| Why more fun | Turns "pick the biggest %" into "build toward Fire." Creates the run-identity feeling roguelites live on. |
| Why more repeatable | Same relic pool yields different runs depending on tag commitment; trophies (§2.2) multiply this. |
| Connects to | `RelicData` (add `tags: Array[StringName]`), `run_modifier_service.gd` (count tags, apply spark), Fate cards (`fate_card_data.gd` can carry tags so a card pick advances a tag). |
| Lore | Tags map to Zoroastrian/Shahnameh concepts: Fire = Azar, Light = Farr, Royal = the Shahs, Shadow = Ahriman. |
| Size | **Medium** |
| Risk | **Medium** (balance, UI space on mobile — tags must be icons, not text). |
| Minimal version | 3 tags (Fire/Light/Iron), one 2-piece spark each, icons in relic picker only. |
| Upgraded version | 6 tags, 2- and 3-piece sparks, Fate cards count toward tags, recap line names your dominant tag ("A run of Fire"). |
| Files | Inspect: `scripts/data/relic_data.gd`, `scripts/meta/run_modifier_service.gd`, `scripts/ui/relic_slot_picker_controller.gd`, `scripts/data/fate_card_data.gd`. |
| Testing | Spark activates/deactivates as relics change; no spark in non-run modes; smoke_test validates tag enum; mobile picker legible at 1280×720. |

### 2.4 Run Title Generator

| Field | Detail |
|---|---|
| What it does | At run end (win or lose), composes a title from run facts: dominant relic tag + standout deed + outcome → "**Ember-Sworn Lion-Slayer**", "**The Thirsty March, Unfinished**". Shown big on the recap; saved to run history. |
| Why fun / repeatable | Names make runs memorable and shareable; players chase titles they haven't seen. Near-zero mechanical risk. |
| Connects to | Heroic Recap (§2.1) data, relic tags (§2.3), run history (§2.5). |
| Lore | Title fragments drawn from Shahnameh epithets (Tahmtan, Sagzi, World-Pahlavan). |
| Size | **Small** |
| Risk | **Low** |
| Minimal version | ~12 fragment strings + composition rule in `RunChronicle`. |
| Upgraded version | Rare titles for rare feats (no-hijack Damavand), title displayed on world map profile. |
| Files | New: title table inside `run_chronicle.gd`. Modify: results panel. |
| Testing | Titles deterministic for same run facts; defeat titles never mocking (tone check); Persian/English string table ready for localization stub. |

### 2.5 Run History and Personal Records panel

| Field | Detail |
|---|---|
| What it does | World-map panel listing last 10 runs (title, outcome, Labour reached, deeds) + existing records already in save (`endless_best`, `gauntlet_best`, `hunt_best_binding`, horde clears, mission lifetime stats) finally rendered. |
| Why fun / repeatable | Progress becomes visible; beaten records are the cheapest "one more run" trigger that exists. |
| Connects to | Recap/titles write entries; save gains a small `run_history` array (save v10). |
| Lore | Framed as the **"Book of Deeds"** — a chronicle page UI. |
| Size | **Small–Medium** |
| Risk | **Low** (save migration must be tested). |
| Minimal version | Append-only 10-entry array + plain list panel from world map. |
| Upgraded version | Filters per mode, record-broken toasts in battle, codex integration. |
| Files | Inspect: `scripts/meta/save_system.gd`, `save_migration.gd`, `world_map_controller.gd`. New: `scripts/ui/run_history_panel_controller.gd`. |
| Testing | SaveMigration GUT test v9→v10; history capped at 10; records match legacy fields; panel readable on device. |

### 2.6 Bestiary — "Div-Nameh" codex

| Field | Detail |
|---|---|
| What it does | Codex unlocking an entry per enemy/boss killed: art slot, 2-line Shahnameh fragment, and the *mechanical tell* ("Corruptors blight the region where they die"). Kill counts shown. |
| Why fun / repeatable | Collection pull + teaches counterplay + delivers lore. Three jobs, one screen. |
| Connects to | 26 existing enemies, `mission_progress_tracker.gd`-style kill counting, future story fragments. |
| Lore | The bestiary of divs *is* Shahnameh material; highest theme density per dev-hour. |
| Size | **Medium** (UI + 26 text entries; art deferred to placeholders) |
| Risk | **Low** |
| Minimal version | Kill-count dictionary in save + list panel with name/tell/fragment for the 9 bosses only. |
| Upgraded version | All 26 enemies, hazard entries per Labour Mode, unlock toasts, Pardeh-style page art. |
| Files | New: `scripts/ui/codex_panel_controller.gd`, entries in `content_catalog.gd`. Modify: save, kill hooks in `enemy_controller.gd` death path (one signal already exists for missions). |
| Testing | Entries unlock on first kill; counts persist; no per-frame cost (hook on death only); validator covers codex IDs. |

### 2.7 Pardeh Story Fragments

| Field | Detail |
|---|---|
| What it does | Each Fate card gains a 1–2 line story fragment shown on the card; collecting all fragments of a Labour completes a chronicle page in the codex. Pure data + text. |
| Why fun / repeatable | Gives Pardeh the "illustrated epic" feel the design demands; completionists replay to fill pages. |
| Connects to | Fate cards, codex (§2.6). **Lore stays out of combat logic** — fragments are display-only fields. |
| Size | **Small** |
| Risk | **Low** |
| Minimal | `story_text` field on `FateCardData` + display in `fate_draft_controller.gd`. |
| Upgraded | Per-Labour fragment sets, completion rewards (cosmetic), narrator voice later. |
| Files | `scripts/data/fate_card_data.gd`, `scripts/ui/fate_draft_controller.gd`, `content_catalog.gd`. |
| Testing | Card UI fits text on mobile; empty fragment renders cleanly; localization-ready strings. |

### 2.8 Companion Bond Levels

| Field | Detail |
|---|---|
| What it does | Within a Campaign Run, the shrine companion gains Bond I→III from battles survived (not grind: +1 per node cleared). Each bond tier adds one visible upgrade (Cheetah: faster sprint → banks +10% → revives once). Bond resets each run. |
| Why fun / repeatable | The one-shot shrine choice becomes a relationship arc; losing a run with Bond III companion *hurts in the good way*. |
| Connects to | `companion_manager.gd`, `campaign_run_state.gd` (store `companion_bond`). |
| Lore | Rakhsh-and-Rostam loyalty is the heart of the Labours. |
| Size | **Small–Medium** |
| Risk | **Low** |
| Minimal | Bond counter + 1 stat bump per tier + tier pip on companion HUD chip. |
| Upgraded | Per-companion unique tier-III abilities, bond moments in recap ("Zavareh held the gate at the last"). |
| Files | `scripts/companions/companion_manager.gd`, behaviors, `campaign_run_state.gd`, HUD chip. |
| Testing | Bond persists across run battles, resets on new run; tier effects apply once; save round-trip. |

### 2.9 Nemesis Enemy ("the Div That Remembers")

| Field | Detail |
|---|---|
| What it does | When a run ends in defeat, the enemy type that dealt the killing pressure is crowned **Nemesis**: next run it appears with a name, a visual mark, +1 affix, and a bounty (bonus iron + codex entry on revenge kill). One nemesis at a time. |
| Why fun / repeatable | Converts defeat into a personal grudge → the strongest possible "one more run." Aligns with the design-only "Memory Div" concept. |
| Connects to | RunChronicle cause data (§2.1) picks the nemesis; wave generator injects it; codex records the revenge. |
| Lore | Divs that learn and return are pure Shahnameh. |
| Size | **Medium** |
| Risk | **Medium** — must not break wave balance; cap at one marked enemy with one affix. NOT the deferred AhrimanDirector (no adaptive AI). |
| Minimal | Save one `nemesis: {enemy_id, affix}`; `CampaignWaveTemplates` swaps one mid-block spawn for the marked elite; banner on its wave. |
| Upgraded | Nemesis escalates if it kills you again (max 3 affixes), unique title on revenge, nemesis history in codex. |
| Files | `scripts/battle/run_chronicle.gd` (new), `campaign_wave_templates.gd`, `save_system.gd`, enemy spawn path in `wave_manager.gd`. |
| Testing | Nemesis spawns exactly once per run; affix stacks correctly; revenge clears nemesis; no nemesis in tutorial/gauntlet. |

### 2.10 Khan-Specific Elite Modifiers (waves)

| Field | Detail |
|---|---|
| What it does | A small affix pool themed per Labour (L2 *Parched*: drains 1 SF on gate hit; L7 *Shrouded*: invisible until first hit). The 10-wave block generator marks 1–2 waves per block as **elite** with a telegraphed affix banner. Horde rotates one affix per map per week. |
| Why fun / repeatable | Waves stop being interchangeable; Horde gets an identity for free. |
| Connects to | `CampaignWaveTemplates` block roles (Bait/Trap/Hijack/Push already exist — affixes are role seasoning), `runtime_modifiers`. |
| Lore | Affix names from each Labour's hazard mythology. |
| Size | **Medium** |
| Risk | **Medium** (difficulty creep — affixes must be telegraphed and capped at low counts). |
| Minimal | 3 affixes, campaign Labours 3+ only, banner reuses Pardeh alert UI. |
| Upgraded | 8+ affixes, Horde weekly rotation, affixes feed nemesis system. |
| Files | `scripts/battle/campaign_wave_templates.gd`, `wave_manager.gd`, HUD banner. |
| Testing | Affix applies to flagged group only; clears on wave end; L1–2 unaffected (forge-gate parity); readability check on device. |

### 2.11 Campaign Run Story Events (node variety)

| Field | Detail |
|---|---|
| What it does | 2 new node types: **Cursed Shrine** (take a relic now + a curse for the next battle — cursed rewards, finally) and **Tale Encounter** (text event with 2 choices: small resource trade-offs + a story fragment; no combat). Plus fold Defend the Throne's radial arena in as a rare **Siege node**. |
| Why fun / repeatable | Graph stops reading the same by run 3; risk appetite becomes a player trait. |
| Connects to | `campaign_run_generator.gd` node tables, existing shrine/anvil controllers as templates, curses ride `runtime_modifiers`. |
| Lore | Tale Encounters are literally Shahnameh vignettes — the cleanest lore-delivery channel the run has. |
| Size | **Medium–Large** |
| Risk | **Medium** (graph generation changes need seed-stability tests). |
| Minimal | Cursed Shrine only: reuse `ShrineNodeController` with a curse rider. |
| Upgraded | 6–8 Tale Encounters, Siege node, event outcomes referenced in recap titles. |
| Files | `scripts/meta/campaign_run_generator.gd`, `campaign_run_state.gd`, new `tale_event_controller.gd`, event data in `content_catalog.gd`. |
| Testing | Seeded graphs reproducible; save v6 compatibility; curse expires after one battle; events skippable. |

### 2.12 "One More Run" post-run flow

| Field | Detail |
|---|---|
| What it does | After the recap, a single screen with exactly three big targets: **Run Again** (same draft re-offered, one tap), **New Draft**, **Book of Deeds**. For campaign defeats under forge curve, the existing forge guidance becomes one quiet line, not a wall. |
| Why fun / repeatable | Removes every tap between "I want revenge" and wave 1. This *is* the KPI. |
| Connects to | Recap (§2.1), scene flow (`scene_flow_controller.gd`), preloader (`LevelAssetCollector` can warm the same level during recap). |
| Size | **Small** |
| Risk | **Low** |
| Minimal | Re-route results Continue → this screen; Run Again relaunches with cached `BattleLaunchData`. |
| Upgraded | Background preload during recap = near-instant restart; daily/heroic-deed progress peek on this screen. |
| Files | `scripts/meta/scene_flow_controller.gd`, results panel, preloader hook. |
| Testing | Run Again works for campaign/run-node/horde/endless; no save corruption on rapid restart; analytics `replay_selected` fires. |

Also evaluated, deliberately **not** specified for now: player-facing Heat dial (wait until Ahriman's Shroud adoption is measured — two hard-mode dials confuse), full 43 Fate cards (grow to ~24 first), run seeds sharing (later), hero roster expansion (deferred in canon).

---

## 3. Replace Weak Features With Better Ideas

### 3.1 Daily Missions → "Heroic Deeds"

**Existing feature.** 3 generic missions/day from a 10-pool ("kill N enemies"), Royal Bounty booster, chest → equipment.
**Problem.** Zero theme, zero story, indistinguishable from any mobile dailies. Doesn't make anyone *feel* like Rostam.
**Better replacement.** Keep service, rotation, chest, and save format. Re-skin every mission as a **Deed** with a Shahnameh frame and, where cheap, a more flavorful condition: "Honor a Hero's Vow as Rostam honored his oath" (vow system exists), "Cleanse 3 regions — drive back Ahriman's shadow," "Bank 50 Star Iron for Kaveh's banner." Completing all 3 = "A Day Worthy of the Book of Kings" (+chest, +codex fragment).
**Why this is better.** The player's daily checklist becomes a roleplay prompt. Same engagement loop, triple the identity.
**Implementation plan.** Smallest test: rename + rewrite descriptions of the existing 10 definitions in `build_daily_mission_definitions()` (`content_catalog.gd`), retitle the panel. Ship; then add 5 new deed types that hook existing signals (vows, cleanses, banked iron) via `mission_progress_tracker.gd`. **Verdict: keep and improve (re-skin first, deepen second).**

### 3.2 Daily Tale → "Today's Tale" with real mutators

**Existing feature.** Daily button that replays `level_01` with a date seed; documented "fair modifiers" never implemented.
**Problem.** It's a dead button wearing a feature's name. Players learn the daily slot is empty calories.
**Better replacement.** Date-seeded pick of (map from cleared pool) + 2 mutators from a small fair list (one helping, one hindering: "+20% gold / jackals are Swift") shown on a card *before* launch. Reuses `runtime_modifiers` end-to-end.
**Why this is better.** A 5-minute different-every-day puzzle is a real habit anchor — and it advertises the modifier vocabulary used by Fate cards and elite affixes.
**Implementation plan.** Mutator table (6 entries) + seeded pick in `daily_tale_service.gd`; pre-battle card UI; pipe to `runtime_modifiers` in bootstrap. If not scheduled within a milestone, **hide the button** — shipping it dead is worse than absent. **Verdict: improve, or demote until improved.**

### 3.3 Defend the Throne → Siege node in Campaign Run

**Existing feature.** Standalone 15-wave radial arena, no unlocks, no overlay, no reward chain.
**Problem.** Fourth sibling of Horde/Endless/Daily Tale; splits attention, earns nothing, and the menu is already crowded for mobile.
**Better replacement.** Move the radial arena into Campaign Run as a rare high-stakes **Siege of the Throne** node (good rewards, surrounded spawns) and remove the menu entry. The arena scene and route data are reused as-is.
**Why this is better.** Campaign Run gains its most dramatic node; one less menu button; the content finally has stakes.
**Implementation plan.** Add node type to `campaign_run_generator.gd` mapping to `level_throne_arena` with run flags; hide world-map button behind a debug flag for one release; watch complaints (expect none). **Verdict: merge into Campaign Run.**

### 3.4 Horde → Rotating Elite Horde

**Existing feature.** 15 waves per map, same rosters, unlock vehicle for Serpent Spire, then abandoned.
**Problem.** "Campaign lite" — no reason to return after 8 clears.
**Better replacement.** Keep mode; add the weekly Labour-affix rotation from §2.10 ("This week: Demons' horde is *Shrouded*") with a small first-clear-of-the-week deed bonus.
**Why this is better.** Horde becomes the place players practice against affixes; near-zero new code once §2.10 exists.
**Implementation plan.** After elite affixes ship, seed affix by ISO-week + map id in horde launch path. **Verdict: keep and improve (dependent on §2.10) — until then, leave as-is.**

### 3.5 Legacy 5-node roguelite → delete from player reach

**Existing feature.** `scenes/roguelite_map/` + `roguelite_run_state.gd`, superseded by Campaign Run; save already migrates.
**Problem.** Dead code path still callable via `SceneFlowController.go_to_roguelite_map()`; conceptual debt; risk of QA confusion.
**Better replacement.** Remove the entry point (keep migration code), mark scene dev-only, plan deletion after one stable release.
**Implementation plan.** One-line flow change + tracker note. **Verdict: remove (player-facing).**

### 3.6 Defeat experience → "Memory of the Fallen"

**Existing feature.** Defeat = lose 100% unbanked Star Iron, terse panel, forge nudge.
**Problem.** Losing teaches nothing and gives nothing; with the forge gate this risks the exact "grind wall feeling" design/02 forbids. (Canon also forbids manipulative defeat offers — so the fix must be generous, not transactional.)
**Better replacement.** Keep the 100% iron loss (the banking tension is good design). Add: Heroic Recap cause line (§2.1) + one **Memory** per defeated run — a small permanent codex/chronicle entry ("Fell at the Third Labour to the Canyon Serpent") and +1 deed progress where honest. No currency, no power, no ad prompt.
**Why this is better.** Defeat becomes a collectible story instead of a wallet slap; respects monetization canon exactly.
**Implementation plan.** Ships automatically with §2.1 + §2.5; the only extra is writing defeat-flavored chronicle templates. **Verdict: improve (no rule changes, all framing).**

### 3.7 Equipment acquisition → Labour-identity drops

**Existing feature.** 7 sets × 4; boss drops weapon/armor, daily chest drops random helm/talisman.
**Problem.** The chest RNG disconnects set pieces from the Labour they're named for; collecting feels like slots, not pilgrimage.
**Better replacement.** Daily chest offers a **choice of 2** pieces, weighted toward sets of Labours you've cleared this week; boss first-kills guarantee their own set's piece.
**Why this is better.** "I'm hunting the Thirst set, so I'm replaying Labour 2" is a self-directed goal loop.
**Implementation plan.** Touch only `equipment_service.gd` drop tables + chest UI (pick-1-of-2). **Verdict: keep and improve.**

### 3.8 Fate cards vs Relics — sharpen the contract

**Existing feature.** Both are modifier picks; separation exists in code (battle vs run scope) but is never stated to the player.
**Problem.** New players can't tell which choice matters longer; choices blur.
**Better replacement.** Not a mechanic — a *contract*: every Fate card UI carries "until battle ends" badge; every relic carries "for this run" badge; equipment screens say "forever." Plus Fate cards gain relic-tag icons (§2.3) so the short-term pick can serve the long-term build.
**Implementation plan.** Badge labels in the two pickers + one onboarding hint line. **Verdict: keep both; clarify, then interlink via tags.**

---

## 4. New Feature Ideas (32)

Scores: Fun / Replay / Difficulty (1–10, higher difficulty = harder).

### Add Now (small, high fun-per-hour)

| # | Idea | Fun | Rep | Dif | Best reason | Biggest risk |
|---|---|---|---|---|---|---|
| 1 | Heroic Recap (victory+defeat cause lines) | 9 | 9 | 3 | Serves the replay KPI directly | Cause attribution edge cases |
| 2 | One More Run flow (1-tap restart + preload) | 8 | 10 | 2 | Removes friction at the decisive moment | Save-state races on rapid restart |
| 3 | Run Title Generator | 8 | 7 | 2 | Memory + shareability for pennies | Titles feel samey if table too small |
| 4 | Pardeh story fragments on Fate cards | 7 | 6 | 2 | Cheapest big lore win | Text overflow on small screens |
| 5 | Scope badges (battle/run/forever) on pickers | 6 | 6 | 1 | Kills the #1 player confusion | None |
| 6 | Personal records panel (render existing saves) | 7 | 8 | 2 | Free retention from data already saved | Save migration bug |
| 7 | Heroic Deeds re-skin of Daily Missions | 7 | 6 | 2 | Theme transplant, zero logic risk | Copy quality |
| 8 | Companion bond pips (3 tiers/run) | 8 | 7 | 3 | Emotional attachment to the shrine pick | Balance of tier-III perks |
| 9 | Defeat "Memory" chronicle entries | 8 | 7 | 2 | Losing finally yields something honest | Tone (must not patronize) |
| 10 | Record-broken toast in battle ("New best: wave 41") | 7 | 8 | 2 | Mid-battle motivation spike | HUD clutter on mobile |
| 11 | Hide/finish Daily Tale dead button | 5 | 4 | 1 | Stops training players to ignore dailies | None |
| 12 | Boss intro nameplates ("Arzhang, Warden of the Fifth") | 7 | 4 | 1 | Mythic weight for one label | None |

### Add Next (medium, build variety + replay)

| # | Idea | Fun | Rep | Dif | Best reason | Biggest risk |
|---|---|---|---|---|---|---|
| 13 | Boss Trophy Relics (1-of-2 per run boss) | 9 | 9 | 4 | Bosses become reward decisions | Power creep |
| 14 | Relic Synergy Tags (Fire/Light/Iron…) | 9 | 9 | 5 | Run identity engine | Mobile icon readability |
| 15 | Fate cards count toward relic tags | 8 | 8 | 3 | Links the two pick systems meaningfully | Complexity creep in card text |
| 16 | Nemesis enemy ("Div That Remembers") | 9 | 9 | 5 | Defeat → grudge → one more run | Wave balance distortion |
| 17 | Khan-specific elite wave affixes | 8 | 8 | 5 | Waves stop being interchangeable | Difficulty creep; telegraphing |
| 18 | Cursed Shrine node (reward now, curse next battle) | 8 | 8 | 4 | Real cursed-reward tension | Curse must be readable |
| 19 | Daily Tale mutator pairs (seeded) | 7 | 8 | 3 | Real daily habit anchor | Unfair seed combos |
| 20 | Div-Nameh bestiary (bosses first) | 8 | 7 | 4 | Collection + counterplay teaching + lore | Content writing time |
| 21 | Tale Encounter nodes (text events, 2 choices) | 8 | 8 | 5 | Story delivery inside the run | Writing quality; localization |
| 22 | Siege node (Throne arena folded into runs) | 7 | 7 | 4 | More node variety, one less menu mode | Difficulty spike placement |
| 23 | Equipment chest pick-1-of-2, Labour-weighted | 7 | 7 | 3 | Self-directed collection goals | Drop-table math |
| 24 | Grow Fate pool 8 → ~24 (data + flavor, placeholder art) | 8 | 9 | 4 | Kills Pardeh repetition | Balancing 16 new cards |
| 25 | Anvil node perk choice (pick 1 of 2 upgrade paths) | 7 | 7 | 3 | Anvils become decisions, not taps | UI work |
| 26 | Weekly Horde affix rotation | 7 | 8 | 3 | Revives a dead mode for near-free | Depends on #17 |

### Add Later (large; only after Khan 1 replay is proven)

| # | Idea | Fun | Rep | Dif | Best reason | Biggest risk |
|---|---|---|---|---|---|---|
| 27 | Heat ladder ("Ahriman's Ascent" post-Shroud tiers) | 8 | 9 | 6 | Endgame chase for finishers | Stacks confusingly on Shroud — **risky now** |
| 28 | Simorgh Feather continue (canon-deferred, once/run) | 7 | 6 | 5 | Softens brutal late defeats fairly | Economy/ad-pressure perception — handle with care |
| 29 | Forge milestone perk choices (L10/20/30 pick-one) | 8 | 8 | 6 | Makes meta progression a build system | Save + balance surface area |
| 30 | Seeded run sharing / weekly community seed | 7 | 9 | 6 | Social comparison without servers | Determinism guarantees |
| 31 | Ferdowsi Archive (full chronicle/codex meta-screen) | 7 | 7 | 7 | The lore home everything feeds into | Big UI investment |
| 32 | 4th–5th shrine companions (Olad guide, Simorgh elder) | 7 | 7 | 5 | More shrine variety | Behavior code per companion; art |

Cool but **not worth building now:** AhrimanDirector adaptive AI (stays deferred — high risk, opaque to players), new standalone modes of any kind, hero roster expansion (canon-deferred), player-facing heat dial (#27) until Shroud adoption data exists, full 43-card pool in one push.

---

## 5. Ranked Top 10 (worth building)

Scored on: fun, replay, lore, low risk, fit with existing systems, mobile readability, one-more-run pull.

| Rank | Feature | Why it wins |
|---|---|---|
| 1 | **Heroic Recap + Memory of the Fallen** (§2.1, §3.6) | Attacks the KPI (voluntary replay) and the biggest weakness (losing feels empty) in one low-risk UI feature. |
| 2 | **One More Run flow** (§2.12) | The cheapest possible multiplier on every other feature — friction removal at the decisive moment. |
| 3 | **Boss Trophy Relics** (§2.2) | Best fun-per-risk content add; deepens bosses, relics, and runs simultaneously with mostly data. |
| 4 | **Relic Synergy Tags** (§2.3) | Turns the modifier pile into a build system; foundation for cards, trophies, titles. |
| 5 | **Run Title Generator + Records panel** (§2.4, §2.5) | Identity + visible progress; both tiny once the recap exists. |
| 6 | **Campaign Run node events** — Cursed Shrine first, then Tale Encounters + Siege node (§2.11, §3.3) | Directly fixes the flattest part of the best mode; absorbs Defend the Throne. |
| 7 | **Nemesis enemy** (§2.9) | The strongest emotional one-more-run hook; medium risk so it sits mid-list. |
| 8 | **Heroic Deeds re-skin + Pardeh fragments** (§3.1, §2.7) | Two text-data passes that triple daily theme density. |
| 9 | **Khan-specific elite affixes (+ Horde rotation)** (§2.10, §3.4) | Wave variety engine; revives Horde as a free byproduct. |
| 10 | **Div-Nameh bestiary** (§2.6) | Collection + teaching + lore; ranks last only because it's pure meta-UI. |

Explicitly cut from top 10: Heat ladder, Simorgh continue, forge perk trees, seeded sharing, co-op investment, new companions — all "later" or "avoid for now."

---

## 6. First 3 Features To Build

### Build 1 — Heroic Recap + One More Run flow (§2.1 + §2.12 + §3.6 together)

- **Why first:** It is the KPI. Every defeat today ends in an unexplained stat panel; the design canon demands "understand result → one-tap replay" and nothing else touches that path this cheaply.
- **Player problem:** "Why did I lose, and why should I try again?"
- **Improves:** results panel, objectives display, Hero's Vow tally, forge defeat guidance, analytics replay tracking.
- **Smallest version:**
  1. New `scripts/battle/run_chronicle.gd` (RefCounted): records last gate-damage source, last region collapse, last hijack, vows, cleanses, iron banked, boss phases reached. Fed by signals that already exist (`CombatEvents`, objective controller, light manager).
  2. `battle_results_formatter.gd` renders: 1 cause line (defeat) or standout line (victory) + 3 deed lines.
  3. Results panel restyle: dominant **Fight Again** button; Continue → world map secondary; forge guidance reduced to one line.
  4. Defeat writes one Memory string to save (flat array for now; full history panel comes with Build follow-ups).
- **Files to inspect:** `scripts/ui/battle_hud_controller.gd`, `scripts/ui/battle_results_formatter.gd`, `scripts/battle/battle_state_controller.gd`, `scripts/battle/objective_controller.gd`, `scripts/battle/map_light_manager.gd`, `scripts/core/combat_events.gd`, `scripts/meta/scene_flow_controller.gd`.
- **Files to modify:** formatter, HUD controller, state controller (event taps), scene flow (restart route), `save_system.gd` (memories array).
- **New files:** `scripts/battle/run_chronicle.gd`; optional `tests/unit/test_run_chronicle.gd`.
- **Data needed:** ~20 chronicle template strings (defeat causes, victory deeds, memory lines).
- **UI needed:** restyled results panel only — no new scene.
- **Testing checklist:** defeat by leak / hijacked tower / boss / hazard each produce a distinct, correct cause line; victory shows 3 deeds; Fight Again relaunches identical `BattleLaunchData` in campaign, run-node, horde, endless; gauntlet panel untouched; rapid restart doesn't corrupt save; GUT test for chronicle formatting; device readability pass.

### Build 2 — Boss Trophy Relics (§2.2)

- **Why second:** Highest-impact content add that rides entirely on built systems (relics, slot picker, run state, boss nodes) and is mostly data. Makes Campaign Run bosses feel like the Labours they're named for.
- **Player problem:** "Bosses are climaxes that pay out nothing memorable; runs lack build direction."
- **Improves:** relics (pool 7 → up to 21), Campaign Run boss nodes, run identity.
- **Smallest version:** 2 trophy relics for the Lion only; after a `node_labour_boss` victory on Labour 1, the existing `RelicSlotPickerController` opens with the 1-of-2 trophy choice; trophies are normal `RelicData` with a `trophy_boss_id` field.
- **Files to inspect:** `scripts/meta/content_registry.gd` (`_build_default_relics`), `scripts/data/relic_data.gd`, `scripts/ui/relic_slot_picker_controller.gd`, `scripts/meta/campaign_run_state.gd`, `scripts/meta/run_modifier_service.gd`.
- **Files to modify:** content registry (trophy defs), run state (post-boss-node hook), picker (trophy mode header), modifier service (any new effect hooks).
- **New files:** none required (data lives in registry; optional `.tres` overrides later).
- **Data needed:** 2 relic definitions (Lion), names + effects + flavor lines; later 12 more.
- **UI needed:** "Trophy of the First Labour" header variant on the existing picker.
- **Testing checklist:** trophy offers only after run boss victory (not linear campaign); persists in `tower_relic_slots` (save v7 round-trip); replace-confirm flow on occupied slot; ContentValidator + smoke_test pass with new IDs; effects apply in next node battle; no offer on defeat.

### Build 3 — Relic Synergy Tags, minimal (§2.3)

- **Why third:** With trophies the relic pool is finally big enough for tags to matter; tags then convert picks into builds and feed titles/recap later. Sequenced after Builds 1–2 deliberately.
- **Player problem:** "Relic picks are isolated stat math; runs don't have an identity."
- **Improves:** relics, shrine/Pardeh/trophy pickers, future Fate-card linkage.
- **Smallest version:** 3 tags (Fire, Light, Iron) as `tags: Array[StringName]` on `RelicData`; tag icons in pickers; one 2-piece spark each (Fire: burns tick once more; Light: +1 region light/wave; Iron: +5% tower HP-equivalent/gate armor), computed in `run_modifier_service.gd` from held relics.
- **Files to inspect:** `scripts/data/relic_data.gd`, `scripts/meta/run_modifier_service.gd`, `scripts/ui/relic_slot_picker_controller.gd`, `scripts/meta/relic_slot_helper.gd`, `scripts/battle/battle_economy.gd` (where sparks land).
- **Files to modify:** all of the above; tag data on the 7+2 existing relics and Lion trophies.
- **New files:** none (icons from `art/_placeholders/` until art phase).
- **Data needed:** tag assignments; 3 spark definitions; 3 placeholder icons.
- **Testing checklist:** spark activates at exactly 2 same-tag relics, deactivates on relic loss/replace; no sparks outside run modes; picker icons legible at 1280×720 on device; smoke_test validates tag names; GUT test for tag counting in `run_modifier_service`.

**Sequencing note:** all three avoid combat-loop rewrites entirely — Builds 1 is UI/event-tap, Build 2 is data + one hook, Build 3 is data + one service. Together they form the loop: *lose → understand → grudge/goal → restart in one tap → chase a trophy → build a tagged identity.*

---

## 7. Update Discipline

When any feature above ships: update [engineering/project-status.md](engineering/project-status.md), flip the row in [engineering/implementation-tracker.md](engineering/implementation-tracker.md), and re-check this document's verdicts. The Khan 1 voluntary-replay gate remains the success measure for Builds 1–3.
