# Design 00 — Project Index

**Last updated:** 2026-06-04  
**Design canon** for project identity, reading order, and locked decisions.  
**Implementation truth:** [engineering/project-status.md](../engineering/project-status.md) · [engineering/implementation-tracker.md](../engineering/implementation-tracker.md)

**Engine:** Godot 4.6 · **Platform:** landscape mobile · **Genre:** active 2D tower-defense roguelite  
**Campaign:** Seven Khans + Damavand Binding finale · **Main battlefields:** 8  
**Visual identity:** hand-painted Shahnameh-inspired Iranian epic art with strong mobile readability

---

## 1. Project promise

Shahnameh TD is a heroic illustrated tower-defense roguelite inspired by Ferdowsi’s Shahnameh. The player builds a defense, moves a legendary champion, protects regions of sacred light, purifies corruption, rescues hijacked towers, drafts Fate cards, and confronts mythic bosses.

Identity must appear in story structure, characters and mythic ordeals, tower shape language, Sacred Fire vs corruption, regional map design, ornamental UI rhythm, soundtrack and SFX, narrator presentation, and replayable roguelite choices — not as generic TD with Persian decorations.

---

## 2. Core player loop

```
read the battlefield
  → place a tower
  → react to enemy pressure
  → reposition the hero
  → earn and spend Sacred Fire
  → cleanse corruption
  → rescue threatened towers
  → choose a Fate card
  → defeat a mythic boss
  → unlock a discovery
  → replay with a different build
```

---

## 3. First production target (Khan 1 vertical slice)

Build **only** Khan 1 first:

1. Place Archer Tower  
2. Defeat a readable enemy group  
3. Move Rostam near a leak  
4. Notice regional corruption  
5. Activate Sacred Fire cleanse  
6. Prevent tower hijack  
7. Survive five waves  
8. Choose one Fate card  
9. Defeat the Lion of the First Khan  
10. Press **replay**

Do not mass-produce the full campaign until real testers **voluntarily replay** Khan 1.

---

## 4. Documentation reading order

| Doc | File | Purpose |
|-----|------|---------|
| 00 | [00-project-index.md](00-project-index.md) | Identity, locked decisions, work order |
| 01 | [01-art-phases.md](01-art-phases.md) | Art direction, modular prompts, phase inventories |
| 02 | [02-gameplay-ux.md](02-gameplay-ux.md) | Combat, maps, towers, heroes, UI, replayability |
| 03 | [03-monetization.md](03-monetization.md) | Fair revenue, products, ads, business stages |
| 04 | [04-production-roadmap.md](04-production-roadmap.md) | Godot architecture, milestones, QA, performance |
| 05 | [05-launch-liveops.md](05-launch-liveops.md) | Soft launch, analytics, community, support |

**Index of all docs:** [index.md](../index.md)

**Source PDFs (repo root):** `Shahnameh TD README.pdf`, `Shahnameh TD Gameplay Design.pdf`, `SHAHNAMEH TD - Ethical Monetization and Business Roadmap.pdf`

---

## 5. Locked design decisions

| Area | Decision |
|------|----------|
| Genre | Active hero-led tower defense with roguelite runs |
| Platform | Landscape mobile first |
| Core battle resource | Gold |
| Signature resource | Sacred Fire |
| Signature threat | Regional corruption and tower hijacking |
| Main campaign | Seven Khans + Damavand Binding |
| Map count | 8 |
| Map progression | Medium → very large |
| Large maps | Layered TileMaps, active sectors, camera anchors, minimap, threat-jump navigation |
| Starting towers | Archer, Sacred Fire, Heavy, Control |
| Starting hero | Rostam |
| Replayability | Cards, relics, routes, Forge hybrids, objectives, heroes, Pacts, Hunt, Endless, Daily Tale |
| Monetization | Cosmetics-first, supporter pack, ad removal, limited optional rewarded ads |
| **Forbidden monetization** | Paid combat power, paid loot boxes, forced ads during battle, manipulative defeat-screen offers |
| Production rule | Prove Khan 1 gameplay before full asset catalog |

---

## 6. Correct work order

1. Lock visual style: Rostam, one map, one HUD, core animations  
2. Build Khan 1 graybox before full asset library  
3. Test touch controls and battlefield readability on real phones  
4. Integrate Phase 0 and Phase 1 assets only  
5. Tune first boss and replay flow  
6. Prove corruption understanding and voluntary replay  
7. Build roguelite foundations  
8. Expand Seven Khans campaign  
9. Add meta progression and collections  
10. Add Hunt, Endless, Daily Tale, cosmetics, launch content  
11. Soft-launch with small audience  
12. Improve retention before scaling marketing  

---

## 7. Success test (first playable build)

A tester should answer:

- What do the four starter towers do?  
- Where will enemies travel?  
- What is Rostam useful for?  
- What does Sacred Fire do?  
- What does corruption look like before collapse?  
- How do I rescue a hijacked tower?  
- Why did I win or lose?  
- What would I try differently on replay?  

**Primary signal:** After finishing or failing Khan 1, does the player press **replay** without being asked?

---

## 8. Non-negotiable quality rules

- Never sacrifice readability for decoration  
- Never use fake Persian writing  
- Never cover critical gameplay with particles  
- Never make a boss only a large health bar  
- Never create large empty maps merely to claim scale  
- Never hide the reason for a defeat  
- Never require spending to recover from difficulty  
- Never generate hundreds of assets before proving the gameplay loop  

---

## Related implementation docs

| Doc | Use for |
|-----|---------|
| [engineering/handoff.md](../engineering/handoff.md) | Onboarding: flow + how code maps to design |
| [spec/gameplay.md](../spec/gameplay.md) | Detailed mechanics (may include post-launch systems) |
| [PRD.md](../product/prd.md) | Product summary aligned to this index |
