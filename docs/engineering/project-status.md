# Project Status (Godot)

**Last updated:** 2026-06-05 (game logic audit fixes)  
**Milestones:** [design/04-production-roadmap.md](../design/04-production-roadmap.md) · **Identity:** [design/00-project-index.md](../design/00-project-index.md)

---

## Repo snapshot (honest)

| Item | Status |
|------|--------|
| Godot project | ✅ `project.godot` — landscape mobile, main scene boot |
| Main menu → world map → battle | ✅ Campaign, roguelite, endless, hunt, daily tale |
| Tutorial gate | ✅ Khan 1 locked until tutorial cleared |
| Campaign levels | ✅ Tutorial + Khans 1–7 + Damavand with per-Khan enemy rosters |
| Signature systems | ✅ Corruption, hijack (SF purify), Pardeh/Fate (skip or pick), Morale at start, Sacred Tether via tower panel, Ancestral Forge nearest-pad fusion |
| Roguelite 5-node run | ✅ Persisted to save v4; resume from world map; defeat clears run |
| Hunt for Zahhak | ✅ 7 seals + Elite forge enforced in scene flow; binding shards weaken Zahhak |
| Campaign Damavand | ✅ After Khan 7 clear; binding guards + chainbreakers before boss |
| Kaveh's Forge | ✅ World map link; Elite notification unlocks Hunt |
| Save v4 | ✅ Hunt best, forge notification, roguelite run state, mode-aware battle saves |

---

## Milestone alignment

| Milestone | Status | Notes |
|-----------|--------|-------|
| **M0–M3** | ✅ | Khan 1 slice, corruption, Lion boss telegraphs |
| **M4** | 🟡 | Art import path wired; placeholders only |
| **M5** | ✅ | Pardeh enforced, 8 Fate cards aligned, objectives on results, relics in roguelite |
| **M6** | ✅ | ContentCatalog, validators, smoke_test expanded, save v4 |
| **M7** | ✅ | Per-Khan enemies/waves, boss phase logic, Zal on Khans 2–3 |
| **M8** | 🟡 | Accessibility + stubs; platform IAP/crash SDK deferred |

**Product gate:** still validate voluntary **Khan 1 replay** on device before marketing scale.

---

## How to run

1. Open repo root in **Godot 4.6** → **F5**.
2. **Play** → tutorial (first time) → world map → campaign Khans 1–7 → Damavand.
3. Forge Elite at **Kaveh's Forge** (world map button) to unlock **Hunt Zahhak** after 7 seals.
4. **Roguelite Path** — 5-node run with relic picks.

```powershell
powershell -File tools/validate_resources.ps1
godot --headless --path . --script res://tools/smoke_test.gd
```

---

## Logic fixes (2026-06-05 audit)

- Wave manager waits for enemy clear before Pardeh / next wave
- Per-spawn `EnemyData`/`HeroData` duplicate — no shared catalog mutation
- Boss debuffs cleared on death; pool reuse resets boss controller
- Tutorial Continue requires victory; world map shows hunt/forge alerts
- Objectives evaluated at victory (no_leaks / no_hijack / cleanse_twice)

## Known deferrals

- Production art/audio (placeholders sufficient for logic QA)
- Projectile-on-impact damage (instant damage today; cosmetic projectiles)
- Full 43 Fate card pool; extra heroes (Gordafarid, Esfandiyar, …)
- Company splash scene (boot → menu directly today)
- Platform IAP, crash SDK, Simorgh continue, Zervan Dial rewind
