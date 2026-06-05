# Design 02 — Gameplay, Visual UX, and Replayability

**Last updated:** 2026-06-04  
**Design canon** — senior game-design specification.  
**Implementation truth:** [engineering/implementation-tracker.md](../engineering/implementation-tracker.md) · [spec/gameplay.md](../spec/gameplay.md)  
**Source:** `Shahnameh TD Gameplay Design.pdf` (extract: [\_source/design/02_extracted.txt](_source/design/02_extracted.txt))

---

## 1. Product promise

Shahnameh TD should feel like an illustrated heroic tale the player actively defends. The player must feel intelligent and heroic: saw pressure, prepared defense, moved the champion at the right moment, rescued a region, adapted the build, defeated a mythic ordeal, discovered a new possibility, and wants to replay immediately.

The first battle must be easy to understand; the fiftieth run must still create interesting choices.

---

## 2. Design pillars

### 2.1 Readable tactics on a phone

At normal mobile zoom, identify within seconds: enemy entrances, paths, build pads, tower types, hero position, objectives, threatened region, corruption severity, boss telegraph, off-screen emergency. Decorative art supports the battlefield; it never competes with it.

### 2.2 Active tower defense

The player positions a hero, activates skills, cleanses corruption, rescues hijacked towers, uses regional tools, selects Fate cards, reacts to boss mechanics, and changes strategy during Pardeh Breaks.

### 2.3 Replayability through decisions

Variation must change strategy, not only enemy HP. Runs can differ by: hero, route branch, build-pad priorities, Fate cards, relics, objectives, Forge hybrids, Memory Div, Zahhak Pact, Blood Oath, map modifier, Daily Tale seed.

### 2.4 Cultural coherence

Respect Shahnameh identity consistently. Avoid generic Western-fantasy castles, random runes, fake Persian writing, costume mixing without narrative reason, and ornament that damages clarity.

### 2.5 Fair engagement

Players return for mastery, discovery, and improvement. Avoid paid power, grind walls, punitive streak loss, confusing currencies, manipulative urgency, and forced battle interruptions.

---

## 3. First 60 seconds

Teach by doing:

1. Show one entrance, one route, one gate, Rostam, two build pads  
2. Highlight Archer Tower card; let player place  
3. Send a small readable enemy group  
4. Show Rostam intercepting a leak  
5. Introduce one subtle corruption warning  
6. Award enough Sacred Fire to cleanse  
7. End wave with satisfying reward pulse  
8. Preview next threat  

**Do not** require understanding Morale, Farr, Forge hybrids, complex relics, rewind, Qanat, Blood Oaths, Zahhak Pacts, or Memory Divs in the first battle.

---

## 4. Minute-to-minute loop

```
read the next threat
  → build, upgrade, or save
  → move hero toward dangerous pressure
  → protect or cleanse a region
  → react to leak, elite, hijack, or objective
  → collect rewards
  → preview next wave
```

Meaningful decision every **15–30 seconds** without overwhelm.

---

## 5. Five-wave structure (Pardeh Break)

Every five waves, open a **Pardeh Break** (20–40 seconds):

```
review the run
  → choose one of three Fate cards
  → optionally reroll
  → accept or decline optional objective
  → select one strategic action
  → inspect next pressure
  → continue
```

Should feel like turning a page in an illustrated epic, not managing a spreadsheet.

---

## 6. Core resources

| Resource | Role | Purchasable? |
|----------|------|--------------|
| **Gold** | Build, upgrade, repair, reposition, tactical actions | No |
| **Gate integrity / Lives** | Enemies reaching gate damage lives; clear feedback on hit and defeat | No |
| **Sacred Fire** | Cleanse, braziers, prevent collapse, recover hijacks, hero skills, Sacred Fire towers, map actions | No |
| **Morale** | Tower responsiveness, auras, objective rewards, comeback, card synergies — visually secondary early | No |
| **Farr** | Account progression, unlocks, collections, mastery, cosmetic recognition — **not** paid power | No direct purchase |
| **Star Iron (per tower)** | Meta forge currency — each starter tower has its own material (Falcon, Ember, Anvil, Frost) | No |

Sacred Fire must be important but usable (not hoarded forever, not spent mindlessly).

### Kaveh's Forge (meta progression)

- Defeating enemies in campaign battles drops **Star Iron** tied to a specific tower material (banked on **victory** only).
- **Main menu → Kaveh's Forge:** spend a tower's own material to raise its permanent forge level (1–30).
- Every **10 levels** the tower's battlefield design tier advances (placeholder: color/size until art M4).
- After level 30, a **5-step Elite path** marks the tower **Elite** (+large combat bonuses).
- **Damavand Binding** requires at least one Elite tower before launch (logic wired; finale level deferred).
- Distinct from **Ancestral Forge** (in-battle adjacent-tower hybrids — still deferred).

---

## 7. Regional light and corruption

| State | Visual | Gameplay |
|-------|--------|----------|
| Stable | Warm light, clean terrain, teal accents | Normal operation |
| Pressured | Subtle cold veins, warning icon | Respond soon |
| Critical | Stronger charcoal-violet, alert sound | Immediate action |
| Collapsed | Transformed terrain, unmistakable change | Enemy advantage, tower weakness, route pressure, hijack danger |

Corruption must be visible before punishment, predictable enough to plan, dramatic enough to demand action, recoverable through skill, and stronger in later maps without feeling arbitrary.

---

## 8. Tower hijacking

Fair sequence:

```
visible corruption signal
  → warning sound
  → dark tendrils approach tower
  → rescue window
  → hijacked silhouette change
  → cleanse or recovery action
  → purification pulse
```

Never silently disable a tower. Early maps: generous recovery windows. Late maps: compressed timing and competing pressure.

---

## 9. Hero control and Sacred Tether

**Rostam (starter):** frontline fighter, boss responder, leak interceptor, emergency defender, Sacred Tether amplifier.

Hero solves problems towers cannot alone: hold breach, intercept runner, interrupt boss, protect purification, activate regional points, strengthen nearby towers, recover from route changes. Movement should be **strategic, not exhausting**.

---

## 10. Starter towers

| Tower | Role | Strength | Weakness | Silhouette |
|-------|------|----------|----------|------------|
| Archer | Fast single-target | Reliable early DPS | Weak vs armor, groups | Timber platform, teal canopy |
| Sacred Fire | Burn, corruption support | Purification synergy | Lower raw DPS without setup | Stone brazier, warm flame |
| Heavy | Armor break, impact | Brutes, clusters | Slow attack | Thick masonry, heavy launcher |
| Control | Slow, stagger, path control | Buys time | Lower direct damage | Qanat/wind utility form |

Each tower must communicate its job before reading stats.

---

## 11. Advanced towers and Forge hybrids

| Hybrid | Playstyle |
|--------|-----------|
| Flame Archer | Rapid burn stacking |
| Volcano Ram | Heavy explosive anti-armor |
| Qanat Weaver | Slow, reposition, route support |
| Derafsh Bastion | Morale and defensive aura |
| Azar Oracle | Sacred Fire economy and purification |

Hybrids reward intentional builds; do not appear randomly without explanation.

---

## 12. Hero roster

| Hero | Role | Notes |
|------|------|-------|
| Rostam | Frontline champion | Starting hero |
| Zal | Tactical support | Foresight, rescue, Simorgh-linked |
| Gordafarid | Mobile defender | Gate defense, rapid response |
| Esfandiyar | Armored frontline | Hold-the-line durability |
| Sohrab | High-risk aggression | Narrative weight |
| Kaveh | Morale leader | Derafsh synergy |
| Simorgh | Rare support | Rescue, purification, dramatic recovery |

Add heroes only after each tactical identity is clear.

---

## 13. Eight maps

| Map | Scale | Grid | Tactical lesson |
|-----|-------|------|-----------------|
| Khan 1 — Lion and Rakhsh | Medium | 32×18 | Basics, corruption warning, hero movement |
| Khan 2 — Desert of Thirst | Medium | 36×20 | Resource pressure, exposed lanes |
| Khan 3 — Azhdaha Canyon | Medium-large | 40×22 | Split routes, boss arena |
| Khan 4 — Sorceress Feast | Medium-large | 42×24 | Illusion routes, information clarity |
| Khan 5 — Olad Camp | Large | 48×27 | Branching priorities, staged fronts |
| Khan 6 — Arzhang Fortress | Large | 52×30 | Siege sectors, breach defense |
| Khan 7 — White Div Cavern | Very large | 56×32 | Visibility, chamber activation |
| Damavand Binding | Very large | 64×36 | Multi-objective finale, anchor control |

**Large-map rule:** staged sectors, minimap, camera anchors, threat-jump, off-screen warnings, short transitions, clear primary/secondary fronts — scale without fighting the camera.

---

## 14. Boss design

Every boss needs: readable entrance, recognizable silhouette, new battlefield question, visible telegraphs, teaching punishments, phase shift, satisfying defeat. Avoid health sponges.

| Boss | Tactical question |
|------|-------------------|
| Lion of the First Khan | Rostam + towers together? |
| Manifestation of Thirst | Scarce relief and exposed paths? |
| Azhdaha | Emergence, fire, split pressure? |
| Sorceress | Deception and post-reveal adaptation? |
| Olad | Human champion without monster fantasy? |
| Arzhang Div | Siege sectors under summons and slams? |
| Div-e Sepid | Blindness and heavy pressure? |
| Zahhak | Bind anchors during staged finale? |

---

## 15. Replayability systems

- **Fate cards:** Three at Pardeh Break; change specialization, Sacred Fire use, hero position, corruption timing, objectives, Forge, recovery — not minor % bumps only  
- **Relics:** Longer build arcs; readable; optional; combine with cards  
- **Route branches:** Safer reward, elite hunt, story, Forge, relic, corrupted shortcut, heal/repair, Blood Oath  
- **Blood Oaths:** Optional skill tests with meaningful but non-required rewards  
- **Zahhak Pacts:** Tempting power with visible cost before acceptance  
- **Memory Div:** Rival that remembers prior success patterns; encourages adaptation  
- **Daily Tale:** Validated seed — fair modifiers, fixed pool, score/mastery; no forced daily grind  
- **Endless:** Post-campaign mastery; scale combinations and pressure, not HP only  

---

## 16. UI hierarchy

**Always visible:** Lives/gate, Gold, Sacred Fire, wave, pause, speed, hero portrait/HP/energy/skill, tower cards, selected-object context.

**Contextual:** cleanse, Qanat, Forge, purge, repair, sell, reposition, tower/objective/boss details, Morale/Farr expansion, relic explanation.

**Alert priority (high → low):** gate danger → tower hijack → regional collapse → boss telegraph → objective warning → wave update → reward notification.

---

## 17. Visual UX rules

Warm-vs-cold contrast for Stable/Corrupted regions; strongest glow on important actions; route contrast over decorative terrain; enemies readable by silhouette; restrained screen shake; reducible flashes/particles; localization-safe UI; no baked text in assets.

---

## 18. Accessibility

UI scale, high contrast, color-safe corruption indicators, reduced flashes/particles/shake, volume sliders, narrative subtitles, readable fonts, vibration toggle, pause, speed controls, touch feedback, left-handed layout if practical. Do not rely only on red-vs-green.

---

## 19. Retention without manipulation

```
finish run → understand result → one meaningful reward → one new possibility → one-tap replay or next route
```

Avoid: many result screens, long reward animations, forced store visits, energy timers, streak anxiety, daily chores, confusing currency chains.

---

## 20. Khan 1 vertical-slice acceptance gate

Approved only when:

- First tower placement feels immediate  
- Route readable; Rostam movement matters  
- All four towers have distinct roles  
- Sacred Fire understood; corruption noticed before collapse  
- Hijack fair; Lion changes behavior  
- Stable FPS on target devices  
- Defeat explains failure; replay is one tap  
- **Testers voluntarily replay**  

Do not build seven polished maps around an unproven first battle.
