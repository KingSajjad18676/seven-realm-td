# Data resources (M6 pipeline)

Drop optional `.tres` files in subfolders (`towers/`, `enemies/`, `levels/`, etc.).
`ContentRegistry` merges them over the runtime catalog from `ContentCatalog`.

## Level geometry overrides

Map layout fields (`path_points`, `build_spot_positions`, `spawn_position`, `gate_position`, `region_ids`, `map_sprite_path`) can be authored with the runtime **Map Editor**:

- Scene: `res://scenes/tools/map_editor.tscn` (F6 in Godot, or main menu **[DEV] Map Editor** in debug builds)
- Output: `resources/data/levels/{level_id}.tres` (partial `LevelData` override)
- Khan 1 production background: `res://art/maps/campaign/khan_01_map.png`
- Tutorial production background: `res://art/maps/tutorial/toturial_map.png`

Validate with:

```powershell
powershell -File tools/validate_resources.ps1
```
