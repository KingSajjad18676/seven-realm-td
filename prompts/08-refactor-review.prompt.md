# Cursor Prompt — Architecture Review

Review the current Unity project for:

- overcoupled systems
- hardcoded data that should be ScriptableObjects
- runtime allocations in battle
- unsafe use of FindObjectOfType or GameObject.Find
- UI code controlling deep gameplay directly
- classes that are too large
- missing pooling opportunities
- missing manual test steps

Do not rewrite everything.
Return:

1. biggest risks
2. safest improvements
3. suggested file-by-file refactor plan
4. what not to change yet
