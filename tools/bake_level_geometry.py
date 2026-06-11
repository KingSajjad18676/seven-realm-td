#!/usr/bin/env python3
"""Generate level_02..level_08_damavand.tres geometry (mirrors bake_level_geometry.gd)."""

from pathlib import Path

LEVEL_IDS = [
    "level_02", "level_03", "level_04", "level_05",
    "level_06", "level_07", "level_08_damavand",
]
PATHS = {
    "level_02": [(60, 380), (300, 380), (500, 300), (700, 300), (900, 380), (1200, 380)],
    "level_03": [(80, 200), (350, 200), (500, 360), (700, 360), (850, 200), (1100, 200), (1200, 360)],
    "level_04": [(100, 360), (350, 480), (550, 360), (750, 240), (950, 360), (1150, 360)],
    "level_05": [(80, 300), (400, 300), (600, 450), (800, 300), (1000, 450), (1250, 300)],
    "level_06": [(100, 250), (400, 250), (550, 400), (750, 400), (900, 250), (1150, 250), (1250, 400)],
    "level_07": [(120, 200), (450, 200), (600, 380), (800, 380), (950, 200), (1200, 200), (1280, 380)],
    "level_08_damavand": [(100, 360), (400, 360), (600, 200), (800, 200), (1000, 360), (1200, 360), (1400, 280)],
}
KHAN = {lid: i + 2 for i, lid in enumerate(LEVEL_IDS)}
VIEW_W, VIEW_H, MARGIN = 1280, 720, 48
OUT = Path(__file__).resolve().parent.parent / "resources" / "data" / "levels"


def scale_path(points):
    min_x = min(p[0] for p in points)
    max_x = max(p[0] for p in points)
    min_y = min(p[1] for p in points)
    max_y = max(p[1] for p in points)
    sw = max(max_x - min_x, 1)
    sh = max(max_y - min_y, 1)
    dw = VIEW_W - 2 * MARGIN
    dh = VIEW_H - 2 * MARGIN
    s = min(dw / sw, dh / sh)
    return [
        (round(MARGIN + (x - min_x) * s, 1), round(MARGIN + (y - min_y) * s, 1))
        for x, y in points
    ]


def pads_along_path(path, count, oy=-60):
    pads = []
    for i in range(count):
        t = (i + 1) / (count + 1)
        idx = min(int(t * (len(path) - 1)), len(path) - 1)
        side = 1 if i % 2 == 0 else -1
        px, py = path[idx]
        pads.append((round(px + 40 * side, 1), round(py + oy, 1)))
    return pads


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    for lid in LEVEL_IDS:
        scaled = scale_path(PATHS[lid])
        khan = KHAN[lid]
        pad_count = 6 if khan <= 4 else 8
        pads = pads_along_path(scaled, pad_count)
        gate = (round(scaled[-1][0] + 20, 1), round(scaled[-1][1] - 10, 1))
        spawn = (round(scaled[0][0] - 20, 1), round(scaled[0][1], 1))
        routes = [("route_main", scaled)]
        spawns = [("spawn_main", spawn, "route_main")]
        if khan >= 3:
            lateral = 70 if khan < 5 else 90
            fork = [
                (round(x + lateral * 0.35, 1), round(y + lateral, 1))
                for x, y in scaled
            ]
            routes.append(("route_2", fork))
            spawns.append(
                ("spawn_2", (round(fork[0][0] - 20, 1), fork[0][1]), "route_2")
            )
        lines = [
            '[gd_resource type="Resource" script_class="LevelData" load_steps=4 format=3]',
            "",
            '[ext_resource type="Script" path="res://scripts/data/level_data.gd" id="1"]',
            '[ext_resource type="Script" path="res://scripts/data/path_route_data.gd" id="2"]',
            '[ext_resource type="Script" path="res://scripts/data/spawn_point_data.gd" id="3"]',
            "",
        ]
        for i, (rid, pts) in enumerate(routes):
            arr = ", ".join(f"Vector2({x}, {y})" for x, y in pts)
            lines += [
                f'[sub_resource type="Resource" id="Route_{i}"]',
                'script = ExtResource("2")',
                f'route_id = "{rid}"',
                f"points = Array[Vector2]([{arr}])",
                "",
            ]
        for i, (sid, pos, rid) in enumerate(spawns):
            lines += [
                f'[sub_resource type="Resource" id="Spawn_{i}"]',
                'script = ExtResource("3")',
                f'spawn_id = "{sid}"',
                f"position = Vector2({pos[0]}, {pos[1]})",
                f'route_id = "{rid}"',
                "",
            ]
        route_refs = ", ".join(f'SubResource("Route_{i}")' for i in range(len(routes)))
        spawn_refs = ", ".join(f'SubResource("Spawn_{i}")' for i in range(len(spawns)))
        pad_arr = ", ".join(f"Vector2({x}, {y})" for x, y in pads)
        primary = ", ".join(f"Vector2({x}, {y})" for x, y in scaled)
        map_path = f"res://art/_placeholders/maps/{lid}.png"
        extra = ""
        if lid == "level_02":
            extra = (
                "starting_gold = 175\n"
                "starting_sacred_fire = 6\n"
                'default_objective_id = "obj_cleanse_twice"\n'
            )
        lines += [
            "[resource]",
            'script = ExtResource("1")',
            f'level_id = "{lid}"',
            extra
            + f'path_routes = Array[ExtResource("2")]([{route_refs}])',
            f'spawn_points = Array[ExtResource("3")]([{spawn_refs}])',
            f"build_spot_positions = Array[Vector2]([{pad_arr}])",
            f"path_points = Array[Vector2]([{primary}])",
            f"gate_position = Vector2({gate[0]}, {gate[1]})",
            f"spawn_position = Vector2({spawn[0]}, {spawn[1]})",
            f'map_sprite_path = "{map_path}"',
            "",
        ]
        out_path = OUT / f"{lid}.tres"
        out_path.write_text("\n".join(lines), encoding="utf-8")
        print("Wrote", out_path)


if __name__ == "__main__":
    main()
