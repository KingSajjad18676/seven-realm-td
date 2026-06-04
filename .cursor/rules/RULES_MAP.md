# Cursor rules — naming

**Convention:** `{domain}-{topic}.mdc` — matches `docs/` areas (`design/`, `engineering/`, `art/`, `liveops/`).

| File | `alwaysApply` | Topic |
|------|---------------|--------|
| `always-project.mdc` | yes | Identity, docs index, locked decisions |
| `always-workflow.mdc` | yes | Agent workflow before/after coding |
| `code-editor.mdc` | no | Godot editor, F5/F6, project root |
| `code-gdscript.mdc` | no | GDScript standards |
| `code-battle.mdc` | no | Battle architecture, corruption, hijack |
| `code-resources.mdc` | no | `.tres` data and stable IDs |
| `code-performance.mdc` | no | Mobile FPS, pooling |
| `code-hud.mdc` | no | Landscape HUD and touch UX |
| `code-testing.mdc` | no | Manual tests, Khan 1 gate |
| `art-pipeline.mdc` | no | Sprites, pivots, phases |
| `liveops-economy.mdc` | no | Fair monetization, meta |
| `docs-editing.mdc` | no | Editing `docs/**/*.md` |

## Historical renames

| Oldest | Intermediate | Current |
|--------|--------------|---------|
| `00-project-context.mdc` | `00-project.mdc` | `always-project.mdc` |
| `19-godot-agent-workflow.mdc` | `01-workflow.mdc` | `always-workflow.mdc` |
| `10-godot-project-context.mdc` | `10-editor.mdc` | `code-editor.mdc` |
| `11-godot-gdscript-standards.mdc` | `11-gdscript.mdc` | `code-gdscript.mdc` |
| `12-godot-gameplay-architecture.mdc` | `12-battle.mdc` | `code-battle.mdc` |
| `13-godot-resource-data.mdc` | `13-resources.mdc` | `code-resources.mdc` |
| `14-godot-mobile-performance.mdc` | `14-performance.mdc` | `code-performance.mdc` |
| `15-godot-mobile-landscape-ux.mdc` | `15-hud.mdc` | `code-hud.mdc` |
| `16-godot-asset-pipeline.mdc` | `16-art.mdc` | `art-pipeline.mdc` |
| `17-godot-liveops-economy.mdc` | `17-liveops.mdc` | `liveops-economy.mdc` |
| `18-godot-testing-debugging.mdc` | `18-testing.mdc` | `code-testing.mdc` |
| `20-docs-and-design-canon.mdc` | `20-docs.mdc` | `docs-editing.mdc` |
