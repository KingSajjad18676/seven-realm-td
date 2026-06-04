# Asset Pipeline

**Last updated:** 2026-06-04  
**Design canon:** [design/01-art-phases.md](../design/01-art-phases.md)  
**Readability checklist:** [art/visual-vfx.md](../art/visual-vfx.md)  
**Active engine:** Godot 4.6 — `art/_placeholders/`

---

## 1. Modular AI prompt workflow

For each generation request, paste **in order** (do not repeat the full visual block inline every time):

1. **GLOBAL VISUAL BLOCK** — Shahnameh TD hand-painted 2D; Rostam reference as style anchor (system, not costume)  
2. **ONE ASSET-TYPE BLOCK** — character strip, tower, map package, VFX, UI, etc.  
3. **ONE ASSET SPECIFICATION** — asset ID, narrative role, gameplay role, dimensions  
4. **GLOBAL NEGATIVE BLOCK** — no Western fantasy, fake Persian text, green spill, cropped limbs, etc.

**One asset per request.** Approve isolated base design before animation strips.

Full prompt text and phase inventories: [design/01](../design/01-art-phases.md) · extract [_source/design/00_01_extracted.txt](_source/design/00_01_extracted.txt).

---

## 2. Review and production outputs

| Stage | Background | Notes |
|-------|------------|--------|
| **Review grid** | Chroma `#00FF00` + thin 2px dark-gray grid | Exact canvas/grid; no labels |
| **Production** | Transparent RGBA | Same approved design; no grid; clean edges |
| **Correction** | — | Regenerate with listed fixes; preserve dimensions |

Legacy rule still applies: **solid green chroma-key** for review generations before transparency pass.

---

## 3. Godot import rules

| Category | Pivot | Notes |
|----------|-------|--------|
| Characters, towers, enemies | bottom-center | 8-column animation strips where applicable |
| Projectiles, VFX | center | Pool at runtime |
| UI icons | center | No baked text unless required |
| Maps | TileMap-ready 128×128 tiles | Layered: terrain, route, pads, light, corruption, collision |

**Stable asset IDs** in `.tres` resources — gameplay must not guess filenames ([design/04](../design/04-production-roadmap.md)).

Placeholders until production art: `art/_placeholders/` — mark clearly in scenes.

---

## 4. Animation and sheet rules

| Rule | Value |
|------|--------|
| Character/creature strips | 8×1 row, consistent scale per frame |
| Tower strips | 8×1 @ 256×256, fixed footprint |
| Hero/companion cells | 256×256 |
| Small enemy cells | 192×192 |
| Boss cells | 384×512 depending on boss |
| Legacy minimum motion | 12+ real frames where using longer loops |
| Grid | Equal cells; no overlap; no fake duplicate frames |

---

## 5. Phase gates (production order)

| Phase | Gate |
|-------|------|
| **0** | Rostam + prototype HUD + Khan 1 map readable at mobile zoom |
| **1** | Four starter towers, jackal/boar/Lion, core VFX, production HUD — **voluntary Khan 1 replay** |
| **2+** | Campaign maps 2–7, advanced towers, boss sets — only after Phase 1 gate |

Do not mass-produce Phase 2–7 assets before Khan 1 replay is proven ([design/00](../design/00-project-index.md)).

---

## 6. Deep-systems art checklist (minimum before marketing)

1. Tower silhouettes per family + one Forge hybrid  
2. Regional darkness + hijack state on build pads  
3. Hero Sacred Tether beam (readable gradient/line)  
4. Corruptor + boss readable at ~48px height  
5. HUD icons: Sacred Fire, cleanse, core tower cards  

Details: [art/visual-vfx.md](../art/visual-vfx.md).

---

## 7.  (archived reference)

 rules for the archived project live under ` Use Godot import settings above for active work.
