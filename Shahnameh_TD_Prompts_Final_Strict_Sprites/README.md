# FINAL STRICT SPRITE-SHEET UPDATE

This version includes all earlier smart-background and Shahnameh-character fixes, plus strict cell-isolation rules for animation sprite sheets. It specifically rejects blended frames, motion ghosts, pale-green backgrounds, continuous scene strips, and cross-cell blur.

See `STRICT_SPRITE_SHEET_RULES.md`.

# Shahnameh TD Prompt Pack — Full Updated Version with Stronger Shahnameh Character References

This version fixes the main art-direction issue reported after testing:

> Generated characters were drifting into **generic fantasy warrior** designs instead of reading clearly as **Shahnameh / Persian epic** characters.

## Main fixes in this version
- Added a **mandatory Shahnameh character reference block** to all character-related prompts.
- Strengthened **Rostam identity cues** across Rostam base, portrait, and animation prompts.
- Strengthened **Persian mythic identity** for enemies, bosses, and companions.
- Expanded the **negative prompts** to reject generic medieval / mobile-fantasy character outputs.
- Kept the corrected **smart background policy**:
  - isolated sprites and sprite sheets => green `#00FF00` background
  - maps / map layers / UI / cards / portraits / illustrations => full canvas, no forced green background

## Key docs
- `SHAHNAMEH_CHARACTER_REFERENCE_RULES.md`
- `BACKGROUND_POLICY_GUIDE.md`
- `GODOT_GENERATION_QA.md`
- `PROMPT_INDEX.md`

## Included structure
- `prompts_by_phase/` — all ready-to-paste prompts by phase
- `EASY_TEXT_BACKUPS/` — flat text copies per phase for easier access

