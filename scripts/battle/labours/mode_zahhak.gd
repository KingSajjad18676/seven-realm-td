extends LabourMode


func initialize(ctx: BattleContext) -> void:
	super.initialize(ctx)
	if context == null or context.bridge == null:
		return
	if context.launch_data and context.launch_data.is_hunt_mode:
		context.bridge.alert_message.emit("Labour Mode: Hunt for Zahhak — bind the serpent king", 75)
	else:
		context.bridge.alert_message.emit("Labour Mode: Damavand Binding — shatter the chains", 75)


func on_wave_started(wave_index: int) -> void:
	if context == null or context.bridge == null:
		return
	var wave_num := wave_index + 1
	if wave_num == 1:
		context.bridge.alert_message.emit("Phase 1 — The Gauntlet: every hazard returns in miniature", 70)
	elif wave_num == 26:
		context.bridge.alert_message.emit("Phase 2 — Chainbreakers threaten your tower pads!", 75)
	elif wave_num == 51:
		context.bridge.alert_message.emit("Phase 3 — Forge Tax: scavenging fails; survive on skill alone", 75)
	elif wave_num == 76:
		context.bridge.alert_message.emit("Phase 4 — Zahhak's Guard: hold the line until binding completes", 80)
	elif wave_num == 100:
		context.bridge.alert_message.emit("Zahhak rises — drag Forge Chains to the anchors!", 90)
