# Data resources (M6 pipeline)

Drop optional `.tres` files in subfolders (`towers/`, `enemies/`, `levels/`, etc.).
`ContentRegistry` merges them over the runtime catalog from `ContentCatalog`.

Validate with:

```powershell
powershell -File tools/validate_resources.ps1
```
