---
name: shahnameh-milestone
description: >-
  Deliver Shahnameh TD milestones (M0–M8) with correct docs, Khan 1 gate
  checks, and status updates. Use when completing features, preparing
  handoff, updating project-status, or scoping work against the roadmap.
---

# Shahnameh Milestone Delivery

## Product gate

Do **not** mass-produce full campaign until testers **voluntarily replay Khan 1** ([docs/design/00-project-index.md](docs/design/00-project-index.md)).

Default scope: **Khan 1 vertical slice** unless user explicitly widens.

## Reading order

1. [docs/design/00-project-index.md](docs/design/00-project-index.md) — locked decisions
2. [docs/engineering/project-status.md](docs/engineering/project-status.md) — repo truth
3. [docs/engineering/implementation-tracker.md](docs/engineering/implementation-tracker.md) — target vs built
4. [docs/design/04-production-roadmap.md](docs/design/04-production-roadmap.md) — M0–M8 definitions

## Milestone map (short)

| Milestone | Focus |
|-----------|-------|
| M0–M3 | Khan 1 graybox, corruption, hijack, Lion boss |
| M4 | Art vertical slice (placeholders OK for logic) |
| M5 | Pardeh, Fate, objectives, roguelite foundation |
| M6 | Content pipeline, validators, GUT, save versioning |
| M7 | Khans 2–7 + Damavand content |
| M8 | Accessibility, Hunt/Endless/Daily Tale stubs, release prep |

## Delivery checklist

**Before merge:**

- [ ] Smallest useful diff; no unrelated rewrites
- [ ] Stable IDs; no P2W / forced ads ([docs/design/03-monetization.md](docs/design/03-monetization.md))
- [ ] GUT + smoke_test pass if code/data touched ([gut-testing](gut-testing/SKILL.md))
- [ ] F5/F6 manual pass on affected flow

**After milestone-worthy work:**

- [ ] Update [docs/engineering/project-status.md](docs/engineering/project-status.md) — honest snapshot + "How to run"
- [ ] Flip rows in [docs/engineering/implementation-tracker.md](docs/engineering/implementation-tracker.md)
- [ ] Summarize changed files and gaps vs design canon
- [ ] Suggest next M-step from roadmap

## Khan 1 success questions (manual)

Tester should answer yes:

- Four towers distinguishable; route readable ~2s; Rostam movement matters
- Sacred Fire and corruption understood; hijack feels fair
- Lion boss changes tactics; defeat explains why; replay is one tap
- Stable FPS on target device

## Monetization guardrails

Launch: cosmetics-first only. No paid combat power, battle pass, or forced battle ads at launch.
