class_name AccessibilityHelper
extends RefCounted

## Reads SettingsService / SaveSystem accessibility flags for gameplay and HUD.


static func is_high_contrast() -> bool:
	return SettingsService != null and SettingsService.high_contrast


static func should_reduce_shake() -> bool:
	return SettingsService != null and SettingsService.reduced_shake


static func should_reduce_particles() -> bool:
	return SettingsService != null and SettingsService.reduced_particles


static func should_reduce_flashes() -> bool:
	return SettingsService != null and SettingsService.reduced_flashes


static func subtitles_enabled() -> bool:
	return SettingsService != null and SettingsService.subtitles_enabled


static func is_left_handed() -> bool:
	return SettingsService != null and SettingsService.left_handed


static func vibration_enabled() -> bool:
	return SettingsService != null and SettingsService.vibration_enabled


static func flash_alpha_multiplier() -> float:
	return 0.25 if should_reduce_flashes() else 1.0


static func particle_scale() -> float:
	return 0.35 if should_reduce_particles() else 1.0


static func shake_strength_multiplier() -> float:
	return 0.2 if should_reduce_shake() else 1.0
