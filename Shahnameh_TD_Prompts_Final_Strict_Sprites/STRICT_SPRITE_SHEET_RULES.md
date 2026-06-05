# Strict Sprite-Sheet Rules

This final update fixes sprite-sheet failures such as blended frames, motion ghosts, pale-green backgrounds, cross-cell overlap, and continuous cinematic strips.

## Applied to
- character animation strips
- enemy and boss animation strips
- companion animation strips
- tower animation strips
- prop animation strips

## Not forced onto
- full maps and map layers
- UI screens
- cards and portraits
- illustrations
- VFX strips where trails or glow may be intentionally required

## Technical rule
Every technical sprite-sheet frame is isolated inside its own cell, with one clean opaque sprite pose and flat `#00FF00` outside the silhouette.

Updated strict sprite-sheet prompt files: 255
