class_name LeverActorNode
extends BaseActorNode

func set_actor(actor:BaseActor, connect_signals=true):
	super(actor, connect_signals)
	if actor is LeverActor:
		actor.triggered.connect(on_lever_triggered)
		offset_node.modulate = actor.get_load_val("GateColor", Color.WHITE)
	else:
		printerr("None LeverActor set on LevelActorNode")
		self.queue_free()

func on_lever_triggered(on:bool):
	if on:
		body_animation.play("toggle_lever_on")
	else:
		body_animation.play("toggle_lever_off")
	
