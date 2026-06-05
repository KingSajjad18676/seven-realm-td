# Godot Import and Generation QA Checklist

## Green sprite sheets
- Confirm canvas width and height exactly match the prompt.
- Confirm frame count, cell size, and frame order.
- Confirm unused pixels use opaque `#00FF00`.
- Confirm no printed guide lines appear in the final sheet.
- Confirm no green fringe, outline, cast shadow, or spill touches the artwork.
- Confirm the sprite remains fully inside every cell with safe padding.

## Maps, layers, and tilesets
- Confirm the asset fills the requested rectangle without green-screen background.
- Confirm the map is not cropped to the path, terrain silhouette, or active layer shape.
- Confirm TileMap coordinates remain aligned from top-left corner to bottom-right corner.
- Confirm tileset cells match the requested dimensions and transitions tile cleanly.
- Confirm no visible guide lines appear unless you explicitly add a temporary review overlay yourself.

## UI, portraits, icons, cards, and illustrations
- Confirm the entire composition fits the requested rectangle.
- Confirm no unintended green-screen fill was added.
- Confirm safe margins and mobile readability.

## Naming
Use the stable asset ID from each prompt as the exported basename.
