# Cursor Prompt — Start the Unity Project

You are working inside a Unity 2D mobile landscape Tower Defense project called ShahnamehTD.

Read:

- docs/PRD.md
- docs/GAMEPLAY_SPEC.md
- docs/TECHNICAL_DESIGN.md
- docs/UNITY_ARCHITECTURE.md
- .cursor/rules/

Task:
Create the initial Unity folder structure and core C# script skeletons for the MVP battle loop.

Implement only safe starter code. Do not overbuild.

Create scripts for:

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

Also create ScriptableObject data classes:

- EnemyData
- TowerData
- ProjectileData
- WaveData
- LevelData

Requirements:

- use namespace ShahnamehTD
- use serialized fields
- avoid FindObjectOfType
- keep logic simple and readable
- include comments only where useful
- list manual Unity setup steps after coding
