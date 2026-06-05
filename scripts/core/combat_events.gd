extends Node

signal enemy_killed(enemy_id: String, gold_reward: int, sacred_fire_reward: int)
signal tower_built(tower_id: String)
signal tower_upgraded(tower_id: String, new_level: int)
signal tower_sold(tower_id: String, refund: int)
signal tower_hijack_started(build_spot_id: String)
signal tower_hijack_recovered(build_spot_id: String)
signal region_state_changed(region_id: String, state: GameEnums.RegionLightState)
signal wave_started(wave_index: int)
signal wave_phase_started(wave_index: int, phase: String)
signal wave_completed(wave_index: int)
signal battle_started(level_id: String)
signal battle_completed(victory: bool, level_id: String)
signal fate_card_selected(card_id: String)
signal cleanse_used(region_id: String)
signal hero_moved
signal hero_skill_used(skill_id: String)
