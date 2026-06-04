# Design 01 — Phase-Based Asset Generation

**Last updated:** 2026-06-04  
**Design canon** — modular prompt system and production phases.  
**Related:** [art/pipeline.md](../art/pipeline.md) · [art/visual-vfx.md](../art/visual-vfx.md)  
**Full extract:** [_source/design/00_01_extracted.txt](_source/design/00_01_extracted.txt)

---

## 1. Why the prompt system is modular

Do not paste the same 50-line visual block into every prompt. For each generation request, paste in order:

1. **GLOBAL VISUAL BLOCK**  
2. **ONE ASSET-TYPE BLOCK**  
3. **ONE ASSET SPECIFICATION**  
4. **GLOBAL NEGATIVE BLOCK**  

Generate **one** isolated asset, atlas, strip, map package, or UI screen per request. Approve base design before animations.

---

## 2. Global visual block (summary)

Hand-painted 2D for landscape-mobile Shahnameh TD (Ferdowsi + Persian miniature). Use approved **Rostam** reference as style anchor — transfer the **visual system**, not Rostam’s exact costume.

- Strong dark-brown/near-black contours; controlled internal lines  
- Painterly cel-shading; bronze, gold, copper, leather, timber, stone, textile, parchment  
- Deep teal, lapis blue, crimson, rust red, ivory, charcoal; warm-orange Sacred Fire accents  
- Restrained cold-blue and shadow-violet corruption  
- Iranian epic identity; mobile-readable silhouettes; elevated three-quarter gameplay perspective  

**Canonical rule:** Shahnameh figures preserve narrative role and dignity. **Gameplay-adaptation rule:** Invented enemies/towers/props must belong in the same world without false canon claims.

---

## 3. Global negative block (summary)

Avoid: photorealistic, 3D-render look, generic Western fantasy, European plate armor, Viking/Roman/samurai styling, sci-fi/neon, flat vector cartoon, anime, fake Persian writing, readable text, logos, watermarks, excessive spikes/glow/particles, cropped limbs/weapons, broken anatomy, inconsistent scale/perspective/lighting, green spill/outline/shadow.

---

## 4. Output control prompts

| Version | Requirements |
|---------|----------------|
| **Review grid** | Chroma `#00FF00`, thin 2px dark-gray grid, exact canvas/grid, no labels/text/watermark |
| **Production** | Same design, transparent RGBA, no grid, clean edges, no scenery |
| **Correction** | Preserve approved system; match Rostam anchor; no crop; consistent scale/perspective; exact grid dimensions |

---

## 5. Asset-type technical outputs

| Type | Grid / size | Pivot | Notes |
|------|-------------|-------|-------|
| Isolated character/creature | Single design | bottom-center | Safe padding; no scenery |
| Animation strip | 8×1 | bottom-center | Identical costume/scale per frame |
| Tower base | 256×256 cell | bottom-center | Clear projectile origin; no baked terrain |
| Tower animation | 8×1 @ 256×256 | bottom-center | Fixed footprint |
| Map package | 128×128 tiles, 16:9 | — | Separate layers: terrain, path, pads, light, corruption, collision, anchors, sectors |
| Tileset atlas | 8×8 @ 128 = 1024² | — | Seamless transitions incl. corruption/sacred |
| Props/UI atlas | Per spec | center | Strong silhouettes |
| VFX strip | 8×1 @ 256 (default) | center | Controlled particles |
| UI screen | 4096×2304 landscape | — | No baked text; deliver mockup + atlases + accessibility variant |

**Animation cell sizes:** small enemy 192²; hero/companion 256²; standard boss 384²; finale boss 512².

---

## 6. Map scale progression

| Map | Scale | Logical grid |
|-----|-------|--------------|
| Khan 1 — Lion and Rakhsh | Medium | 32×18 |
| Khan 2 — Desert of Thirst | Medium | 36×20 |
| Khan 3 — Azhdaha Canyon | Medium-large | 40×22 |
| Khan 4 — Sorceress Feast | Medium-large | 42×24 |
| Khan 5 — Olad Camp | Large | 48×27 |
| Khan 6 — Arzhang Fortress | Large | 52×30 |
| Khan 7 — White Div Cavern | Very large | 56×32 |
| Damavand Binding | Very large | 64×36 |

Large maps use layered TileMaps and staged sectors — not single giant empty bitmaps.

---

## 7. Phase 0 — Visual lock (before mass production)

| Asset ID | Purpose |
|----------|---------|
| `hero_rostam` | Style anchor; 256×256 animation cells |
| `hero_rostam_idle` / `walk` / `basic_attack` | 8-frame strips |
| `ui_battle_hud_prototype` | Lives, Gold, Sacred Fire, Wave; pause/speed/cleanse; hero + 4 tower cards |
| `map_khan_01_lion_rakhsh` | 32×18; entrance upper-right, gate lower-left; lion arena; 8 build pads; 3 light sectors |

**Phase 0 gate:** Rostam readable at mobile zoom; animations fit cells; route understandable in 2s; pads visible; HUD thumb-friendly; Sacred Fire identifiable without tutorial wall.

---

## 8. Phase 1 — Khan 1 playable slice

**Base designs:** `companion_rakhsh`, `enemy_corrupted_jackal`, `enemy_corrupted_boar`, `boss_mythic_lion`, four starter towers (`tower_archer`, `tower_sacred_fire`, `tower_heavy`, `tower_control`).

**Tower animations (each):** idle, attack, construction, corruption_warning, hijacked, purification.

**Khan 1 VFX:** `vfx_arrow_release`, `vfx_arrow_impact`, `vfx_sacred_fire_cleanse`, `vfx_region_corruption_stage_01`, `vfx_tower_hijack_start`.

**Production HUD:** `ui_battle_hud` — progressive disclosure; contextual Morale/Farr/Forge/etc.

**Phase 1 gate:** Four tower roles clear; corruption before collapse; fair hijack; Rostam useful not exhausting; Lion changes tactics; readable on mid-range phone; **voluntary Khan 1 replay**.

---

## 9. Phases 2–7 (summary)

| Phase | Scope |
|-------|--------|
| **2** | Seven Khans campaign assets (heroes Zal/Gordafarid/Esfandiyar; campaign enemies/bosses; maps 2–7 tilesets; advanced towers; boss VFX) |
| **3** | Roguelite UI (`ui_pardeh_break`, `ui_scroll_of_fate`, Fate card art pool, strategic-action cards, relic icons, challenge assets) |
| **4** | Narrative portraits, collection/meta UI (hero hall, tower codex, relic collection, narrator’s book, forge) |
| **5** | Hunt/Endless/Daily Tale/cosmetic shop UI; Damavand map; Zahhak assets — **no battle-pass UI at initial launch** |
| **6** | Settings, accessibility, victory/defeat, branding, loading screens, audio briefs |
| **7** | Godot integration: import pipeline, validators, HUD, Pardeh Break, VFX pooling, data resources, analytics |

---

## 10. Engineering rule

Every production asset uses a **stable asset ID** in data resources. Never guess filenames in gameplay code. See [design/04-production-roadmap.md](../design/04-production-roadmap.md).

---

## 11. Final asset QA checklist

- **Style:** Matches Rostam anchor; consistent cel-shading; same illustrated world  
- **Culture:** Iranian-epic inspired; no accidental Western fantasy; no fake writing  
- **Readability:** Mobile silhouette; distinguishable enemies; readable pads/routes; controlled VFX  
- **Technical:** Clean transparency; consistent pivots; animations in cells; separable map layers; large touch targets; stable IDs  
- **Discipline:** Approved before animation; needed for current milestone; tested in-game  
