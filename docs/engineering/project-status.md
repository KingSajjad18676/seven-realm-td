# Project Status (Godot)

**Last updated:** 2026-06-04 (campaign roadmap implementation)  
**Milestones:** [design/04-production-roadmap.md](../design/04-production-roadmap.md) · **Identity:** [design/00-project-index.md](../design/00-project-index.md)

---

## Repo snapshot (honest)

| Item | Status |
|------|--------|
| Godot project | ✅ `project.godot` — landscape mobile, main scene boot |
| `scripts/`, `scenes/`, `resources/` | ✅ M0–M8 engineering scaffold |
| Campaign levels | ✅ Tutorial + Khans 1–7 + Damavand (`ContentCatalog`) |
| Roguelite map | ✅ 3-node run + relic picks |
| Endless / Hunt | ✅ Launch flags + endless wave generator |
| M4 art hooks | ✅ `VisualAssetLoader` + `art/_placeholders/khan1/` |
| Meta services | ✅ Daily Tale, Store stub, Localization, CrashReporter stubs |
| Accessibility | ✅ Settings panel (UI scale, contrast, particles, shake) |

---

## Milestone alignment

| Milestone | Status | Notes |
|-----------|--------|-------|
| **M0–M3** | ✅ | Khan 1 slice, corruption, Lion boss |
| **M4** | 🟡 | Art import path wired; drop PNGs in placeholders |
| **M5** | ✅ | Full Pardeh flow, 8 Fate cards, objectives, relics, roguelite map, Morale, Sacred Tether, Ancestral Forge prototype |
| **M6** | ✅ | `ContentCatalog`, `resources/data/` merge, validators, debug menu, save v3 |
| **M7** | ✅ | Levels 02–08 data, Zal hero, large-map camera, world map, Khan seals |
| **M8** | ✅ | Accessibility settings, i18n stub, Daily Tale, store restore stub, crash reporter stub |

**Product gate:** still validate voluntary **Khan 1 replay** on device before marketing scale.

---

## How to run

1. Open repo root in **Godot 4.6** → **F5**.
2. Main menu → Campaign / Forge / Settings / Daily Tale.
3. World map → all Khans (unlock on clear) + Roguelite / Endless / Hunt (after 7 seals).

```powershell
powershell -File tools/validate_resources.ps1
godot --headless --path . --script res://tools/smoke_test.gd
```

---

## Immediate follow-up

1. Device playtest Khan 1 gate (replay analytics in save).
2. Import Phase 0–7 art into `art/_placeholders/` (run `tools/generate_map_placeholders.gd` in Godot for map PNGs).
3. Tune per-boss phases on device after playtest.
