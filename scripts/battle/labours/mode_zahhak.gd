extends LabourMode


func initialize(ctx: BattleContext) -> void:
	super.initialize(ctx)
	if context == null or context.bridge == null:
		return
	if context.launch_data and context.launch_data.is_hunt_mode:
		context.bridge.alert_message.emit("Labour Mode: Hunt for Zahhak — bind the serpent king", 75)
	else:
		context.bridge.alert_message.emit("Labour Mode: Damavand Binding — shatter the chains", 75)
