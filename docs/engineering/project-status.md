# Project Status (Godot)

**Last updated:** 2026-06-04  
**Milestones:** [design/04-production-roadmap.md](../design/04-production-roadmap.md) · **Identity:** [design/00-project-index.md](../design/00-project-index.md)

---

## Repo snapshot (honest)

| Item | Status |
|------|--------|
| Godot project | ✅ `project.godot` at repo root (Godot 4.6, Mobile renderer) |
| `scripts/`, `scenes/`, `resources/` | ❌ **Not present** — scaffold only |
| Main scene / boot flow | ❌ Not configured (`config/name` still default) |
| Design data (`.tres`) | ❌ None committed |
| Playable TD battle | ❌ Not yet — start at **M0** |

**Implication:** Docs that describe waves, autoloads, 115+ resources, or Boot → World Map describe the **target architecture**, not this checkout. Use [implementation-tracker.md](implementation-tracker.md) for planned features; use this file for **what is on disk**.

---

## Milestone alignment

| Milestone | Status | Next step |
|-----------|--------|-----------|
| **M0** Technical proof | ❌ Not started | Landscape viewport, touch, one path, one tower, one enemy, gate leak |
| **M1** Khan 1 graybox | ❌ | Rostam, 4 tower behaviors, 5 waves, replay button |
| **M2** Signature systems | ❌ | Regional light, corruption, Sacred Fire, hijack |
| **M3** Lion boss | ❌ | Arena + telegraphs |
| **M4** Visual slice | ❌ | [design/01-art-phases.md](../design/01-art-phases.md) Phase 0/1 assets |
| **M5–M8** | ❌ | Per [design/04-production-roadmap.md](../design/04-production-roadmap.md) |

**Product gate (unchanged):** voluntary **Khan 1 replay** before campaign expansion ([design/00-project-index.md](../design/00-project-index.md)).

---

## Target layout (when M0+ lands)

```text
project.godot
scenes/boot/boot.tscn          # main scene (F5)
scripts/                       # GDScript systems
resources/                     # .tres design data
art/_placeholders/
tools/                         # validators, smoke tests
```

See [architecture.md](architecture.md) and [handoff.md](handoff.md).

---

## How to run (today)

1. Open the repository root in **Godot 4.6**.
2. Press **F5** — empty project until scenes exist.
3. Set **Project → Project Settings → Application → Run → Main Scene** to `res://scenes/boot/boot.tscn` once boot exists.

---

## Immediate engineering backlog

1. Rename project in `project.godot` → `Shahnameh TD`.
2. Create folder skeleton per [architecture.md](architecture.md).
3. Implement **M0**: graybox battle scene with one enemy path, one tower, lives/gate.
4. Add `tools/validate_resources.ps1` when first `.tres` files exist.
5. Update [implementation-tracker.md](implementation-tracker.md) as features land.

---

## Maintenance

When you ship a milestone, update **this file first**, then adjust tables in `implementation-tracker.md`. Do not mark features ✅ here without matching files under `scripts/`, `scenes/`, or `resources/`.
