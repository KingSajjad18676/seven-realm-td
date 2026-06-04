# Cursor Prompt — Implement Core Battle Loop

Implement a playable prototype battle loop in Godot 4.6.

The battle loop should:

1. load LevelData (`.tres`)
2. spawn waves from WaveData
3. move enemies along a waypoint path
4. allow towers to target enemies in range
5. fire projectiles
6. damage and kill enemies
7. award battle gold
8. reduce lives if enemies reach the end
9. trigger victory when all waves are cleared
10. trigger defeat when lives reach zero

Keep it simple and stable.

Do not add:

- shops
- live events
- roguelite
- complex status effects
- networking
- analytics

After coding:

- summarize files changed
- give Godot scene setup instructions (`scenes/battle/`, autoloads if needed)
- give a manual test checklist (F5/F6)
