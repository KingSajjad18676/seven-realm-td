# Background Policy Guide

## GREEN SPRITE GRID — use `#00FF00`
Use for isolated gameplay elements that need separation from unused space:
- heroes, enemies, bosses, companions
- character animation strips
- towers and tower animation strips
- isolated gameplay props and prop atlases
- isolated VFX, beam textures, and environmental animation overlays

Rules:
- unused pixels are solid opaque `#00FF00`
- no transparency
- no green spill or green cast shadows
- exact sheet dimensions and frame coordinates
- no visible printed grid lines

## FULL CANVAS — NO GREEN
Use for assets that need their full rectangle, composition, or tile coverage:
- complete maps and all TileMap layers
- tileset atlases and tile overlays
- UI screens, HUD layouts, frames, menus, marketing art
- Fate cards, relic icons, icon atlases
- portraits and codex designs
- loading art and illustrations

Rules:
- no forced chroma-green fill
- no transparent cut-out presentation
- do not crop to active shapes
- preserve the full requested rectangle
- maps and map layers remain tile-coordinate locked from corner to corner
- tilesets populate intended cells and preserve seamless tile edges
