# Cursor Prompt — Build Tower System

Implement the tower system for the MVP.

Features:

- tap/select build spot
- build tower if enough gold
- tower scans for target in range
- tower shoots projectile
- projectile damages enemy
- tower can be upgraded with simple level increase
- tower can be sold

Use:

- TowerData ScriptableObject
- ProjectileData ScriptableObject
- BattleEconomy
- object pooling if a pool already exists; otherwise write simple code and mark pooling as next step

Rules:

- no UI clutter
- no hardcoded tower values inside TowerController
- no direct tower dependency on specific enemy class beyond interfaces if possible
