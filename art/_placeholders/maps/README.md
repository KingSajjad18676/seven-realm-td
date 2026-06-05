# Map placeholders

PNG files named by `level_id` (e.g. `level_02.png`) at 1280×720.

`VisualAssetLoader.map_sprite()` and `LevelData.map_sprite_path` resolve to this folder.

## Generate placeholders

**Option A — PowerShell (no Godot menu):**

```powershell
powershell -File tools/generate_map_placeholders.ps1
```

**Option B — Godot headless (from repo root):**

```powershell
godot --headless --path . --script res://tools/generate_map_placeholders.gd
```

Or drop production map art here manually.
