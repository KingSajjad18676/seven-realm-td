# Visual & VFX Specification — Deep Systems Readability

**Last updated:** 2026-06-04  
**Design canon:** [design/01-art-phases.md](../design/01-art-phases.md) · [design/02-gameplay-ux.md](../design/02-gameplay-ux.md)

This document defines **what art and UI must exist** so gameplay reads clearly on mobile landscape. Code can run without these assets, but the game will not feel premium until this checklist is satisfied.

**Art direction:** Hand-painted Shahnameh / Persian miniature — strong dark contours, painterly cel-shading, bronze/teal/crimson/ivory palette, warm-orange Sacred Fire accents, restrained cold-violet corruption. See [art/pipeline.md](../art/pipeline.md) for import and prompt workflow.

**Khan 1 priority VFX IDs:** `vfx_sacred_fire_cleanse`, `vfx_region_corruption_stage_01`, `vfx_tower_hijack_start`, `vfx_arrow_release`, `vfx_arrow_impact` (design/01 Phase 1).

---

## 1. Design principles (mobile landscape)

1. **Silhouette first** — Player must identify tower family, hero, corruptor, and boss in under 0.5s.
2. **State over decoration** — Hijacked, lit, and corrupted states change **color + outline + icon**, not only subtle tint.
3. **One focal VFX per action** — Tether beam, cleanse pulse, rewind ripple; avoid stacking opaque fullscreen effects.
4. **HUD is myth, not spreadsheet** — Meters use icons (flame, serpent, dial) with short banners; avoid long text during waves.
5. **Thumb zones** — Rewind, cleanse, brazier, skill sit in reachable corners; center stays battlefield-clear.

---

## 2. Map & regional light (Module 1)

### Required

| Asset | Purpose | Notes |
|-------|---------|-------|
| Build-spot base tile | Neutral ground under tower | Bottom-center pivot |
| Regional darkness overlay | Per-spot `SpriteRenderer` multiply | Alpha scales with `1 - light/100`; purple-black, not gray |
| Permanent corruption overlay | Distinct from temporary dark | Cracked texture, red vein border; never fully cleansable |
| Brazier prop (lit) | Player-placed light source | Small fire bowl, gold rim; idle flame loop |
| Cleanse burst VFX | Tap cleanse / hero aura tick | Gold-white radial, 0.3–0.5s |
| Hijack transition VFX | Light hits 0 | Purple flash + smoke wisps on tower |

### Strongly recommended

- Path **glow trail** on high-light corridors (subtle) so A* herding is visible.
- **Gate / core** landmark at path end — enemies and A* goal must read as “this way.”

### Color language

| Light level | Read |
|-------------|------|
| 100 | Warm gold rim on spot edge |
| 30–99 | Normal; slight cool shadow |
| 1–29 | Desaturated spot + weak tower |
| 0 (hijack) | Purple core glow, hostile outline |

---

## 3. Towers (all families + hybrids)

### Per-tower sheet requirements

Each tower family needs:

| Element | Frames | Pivot |
|---------|--------|-------|
| Idle | 1 or 4 | bottom-center |
| Attack | 8–12 | bottom-center |
| Upgrade tier visual | tint or attachment | — |
| **Hijacked state** | tint + optional 4-frame “twisted” | same |
| Range ring (UI) | vector or sprite circle | center on spot |

### Family silhouette checklist

| Family | Silhouette cue | Projectile VFX |
|--------|----------------|----------------|
| Arrow | Slim vertical turret, bow motif | Thin gold arrow |
| Fire | Brazier / mage column, upward flame | Fire orb + trail |
| Siege | Wide base, stone arm | Rock chunk arc |
| Barracks | Tent or gate, no tall barrel | — (units if added) |
| Shrine | Dome + bird motif (Simorgh) | Soft pulse |
| Command | Banner pole, royal standard | — (aura ring) |
| Forge | Anvil + chain motif (Damavand) | Spark on build |
| Hybrid (Phoenix Bow) | **Distinct merged shape** — not recolor | Phoenix trail projectile |

### Ancestral hybrids (critical)

Hybrids must look **crafted**, not palette-swapped:

- Phoenix Bow: fire wings on arrow chassis + gold string.
- Add **small “hybrid” icon** on build card and selected panel.
- Refraction tether: secondary beam color **differs** from primary (e.g. gold primary, violet refracted).

### Hijacked tower read

- Layer: `HijackedTower` () for targeting/debug.
- Sprite: purple tint + eyes/mark of corruption (miniature demon mask).
- Attack VFX: dark bolt toward hero/allies, not enemy-colored.

---

## 4. Hero (Module 2 + 6)

### Rostam / Zal (minimum)

| Asset | Notes |
|-------|-------|
| Portrait (HUD) | 256×256, face readable |
| World sprite sheet | Move 8–12, attack 6–8, skill 8–12 |
| Tether origin point | Hand or chest transform for LineRenderer |
| Defeat / revive | 4-frame fall, gold revive flash |

### Tether VFX (code uses LineRenderer — art enhances)

| Type | Visual spec |
|------|-------------|
| Primary tether | Gold-white core line, soft additive trail |
| Drag preview | Dashed cyan while dragging |
| Refraction beams | Thinner violet lines to 2 neighbors |
| Offensive tether (Zahhak) | Red-gold heavy chain texture on line |

### Energy read

- Circular or flame **energy ring** under hero feet when tether active.
- Low energy: desaturate hero rim glow.

---

## 5. Enemies & bosses

### Standard enemies

| Type | Silhouette | VFX on death |
|------|------------|--------------|
| Grunt | Hunched div | Small ash puff |
| Runner | Lean, fast legs | Speed lines optional |
| Brute | Wide armor | Heavy impact |
| Corruptor | Carries dark jar / serpent | Corruption splash on death |
| Moth Corruptor | Moth wings, luminous eyes | Light-seeking trail particles |

### Boss (Khan phases)

| Asset | Purpose |
|-------|---------|
| Boss sheet 12+ frames per phase | Phase 2+ armor swap or aura color |
| Phase banner UI frame | Ornate Persian border + phase number |
| Modifier acquired toast | Icon per `BossModifierData` (Ash Cloak, etc.) |
| HP bar | Wide, manuscript-style frame |

### Zahhak (Module 6 — flagship spectacle)

| Asset | Purpose |
|-------|---------|
| Zahhak body | Two serpent shoulders readable at mobile scale |
| Serpent HUD | Twin serpent icons filling toward tribute |
| Infinite HP bar | Different style (ornate unbreakable chain motif) |
| Slowed by tether | Chain glyphs on ankles, 90% slow read |
| Damavand mountain | Large static or parallax prop + trigger zone glow |
| Chain VFX | Forge towers shoot chains when win condition near |

---

## 6. UI / HUD (integration)

### Battle HUD additions

| Control | Visual |
|---------|--------|
| Sacred Fire meter | Flame icon + numeric; gold fill |
| Morale bar | Already present — style as manuscript ribbon |
| Rewind button | Zervan dial / sun disk icon; hold state glow |
| Cleanse / Brazier | Distinct icons; disabled when permanent corrupt |
| Khan phase banner | Top-center scroll, 2s fade |
| Director warning | Red-gold border: “Khan adapts…” + modifier icon |
| Tribute prompt | Serpent border overlay + “Sacrifice a tower” |
| Rhyme Window | Golden couplet frame pulse 1.5s; screen edge vignette |
| Hybrid upgrade panel | Show Phoenix name + merged icon |

### Roguelite / Fate

- Fate cards: **boon top / curse bottom** split art, never single green panel.
- `fate_shattered_chrono_dial`, `fate_couplet_immortal`: unique border motifs.

---

## 7. VFX systems summary

| System | Priority | Description |
|--------|----------|-------------|
| Regional light overlay | P0 | Without this, corruption is invisible |
| Hijack + purge hit | P0 | Core fantasy payoff |
| Sacred tether beam | P0 | Primary skill expression |
| Cleanse / brazier | P1 | Territory control feedback |
| Zervan rewind ripple | P1 | Time distortion on enemies + map |
| Epic Couplet clear | P1 | Brief gold wash + enemy dissolve |
| A* path herding | P2 | Optional path ghost when recalcing |
| Forge chains | P2 | Damavand finale spectacle |
| Organ mutation drag | P3 | UI ghost icon from boss drop |

---

## 8. s & tags (project setup)

Configure in **Edit → Project Settings → Tags and Layers**:

| Layer / tag | Use |
|-------------|-----|
| `Tower` | Friendly towers |
| `HijackedTower` | Corrupted friendly targeting |
| Tag `HijackedTower` | Fallback if layer missing |

---

## 9. Production order (art team)

1. **Regional overlay + hijack read** (unblocks Sacred Fire fantasy)
2. **Tower family silhouettes** (Arrow, Fire, Siege) + projectiles
3. **Hero + tether beam** materials
4. **Corruptor + Moth** enemies
5. **HUD meters** (SF, tribute, rewind, rhyme)
6. **Boss + Zahhak + Damavand** set piece
7. **Hybrids + forge** props
8. Polish VFX pass (combine, mobile perf)

---

## 10. Performance notes

- Prefer **sprite atlases** by feature: `UI`, `Towers`, `Enemies`, `VFX`.
- LineRenderer tether: use **one shared material**; no per-frame mesh gen.
- Regional overlay: single multiply sprite per build spot, not fullscreen post.
- Limit simultaneous VFX to **8–12** particles per spot during waves.
- Boss phase banner: UI canvas static batch, not world TextMesh.

---

## Related docs

- [spec/gameplay.md](../spec/gameplay.md) — rules and math
- [art/pipeline.md](../art/pipeline.md) — AI generation and import
- [product/roadmap.md](../product/roadmap.md) — Phase 5.6 visual polish
