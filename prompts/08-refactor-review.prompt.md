# Cursor Prompt — Architecture Review

Review the current Godot codebase for:

- overcoupled systems
- hardcoded data that should be `.tres` Resources
- runtime allocations in battle hot paths
- unsafe `get_node` / string path lookups in `_process`
- UI code controlling deep gameplay directly
- scripts that are too large
- missing pooling opportunities
- missing manual test steps

Do not rewrite everything.
Return:

1. biggest risks
2. safest improvements
3. suggested file-by-file refactor plan
4. what not to change yet
