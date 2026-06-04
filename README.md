# Shahnameh Mobile Landscape TD

Mobile landscape 2D **active tower-defense roguelite** inspired by the Shahnameh — Persian mythology, Zoroastrian fire symbolism, and classical Persian miniature painting.

## Active engine: Godot 4.6

**Project path:** `shahname-td-godot/shahname-td/`

1. Open that folder in Godot 4.6  
2. Press **F5** (`scenes/boot/boot.tscn`)  
3. See [GODOT_PORT_STATUS.md](docs/GODOT_PORT_STATUS.md) for validation and gaps  

## Documentation

**Start here:** [docs/DOC_INDEX.md](docs/DOC_INDEX.md) → [README_00_MASTER_PROJECT_INDEX.md](docs/README_00_MASTER_PROJECT_INDEX.md)

| Doc | Use for |
|-----|---------|
| [DOC_INDEX.md](docs/DOC_INDEX.md) | Full reading order (README_00–05 + implementation docs) |
| [GAME_HANDOFF.md](docs/GAME_HANDOFF.md) | Onboarding: gameplay + code map |
| [GODOT_PORT_STATUS.md](docs/GODOT_PORT_STATUS.md) | What is playable in Godot today |
| [IMPLEMENTATION_STATUS.md](docs/IMPLEMENTATION_STATUS.md) | Feature status (design vs built) |

Design PDFs (repo root): `Shahnameh TD README.pdf`, `Shahnameh TD Gameplay Design.pdf`, `SHAHNAMEH TD - Ethical Monetization and Business Roadmap.pdf`

## Unity reference (archived)

Original C# / Unity implementation: `_archive/unity/` (git tag `unity-final-reference`)

Re-import Unity `.asset` data into Godot `.tres`:

```powershell
powershell -File tools/import_unity_refs.ps1
powershell -File tools/validate_resources.ps1
```

## Cursor rules

- **00, 10–19:** Godot-first development  
- **01–09:** Unity archive only (`_archive/unity/`)
