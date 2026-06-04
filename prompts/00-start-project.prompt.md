# Cursor Prompt — Start the Godot project

You are working inside **Shahnameh TD**, a Godot 4.6 mobile landscape tower-defense roguelite.

Read:

- docs/product/prd.md
- docs/spec/gameplay.md
- docs/engineering/technical-design.md
- docs/engineering/architecture.md
- docs/engineering/project-status.md
- docs/index.md
- .cursor/rules/

Task:
Create the initial Godot folder structure and core GDScript skeletons for the MVP battle loop.

Implement only safe starter code. Do not overbuild.

Create scripts under `scripts/` for:

- BattleStateController
- WaveManager
- EnemySpawner
- EnemyController
- PathFollower
- TowerBuildSpot
- TowerController
- ProjectileController
- BattleEconomy
- LivesController
- BattleHUDController

Also create Resource data classes (`.gd` + sample `.tres`):

- EnemyData
- TowerData
- ProjectileData
- WaveData
- LevelData

Requirements:

- GDScript with typed exports where useful
- cache node references in `_ready()`; avoid `find_child` in hot paths
- keep logic simple and readable
- include comments only where useful
- list manual Godot test steps after coding (F5/F6)
