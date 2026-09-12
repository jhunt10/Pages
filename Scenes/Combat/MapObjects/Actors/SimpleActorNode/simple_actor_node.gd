class_name SimpleActorNode
extends BaseActorNode

func _ready() -> void:
	super()

func _process(delta: float) -> void:
	super(delta)

func ready_action_animation(action_name:String, speed:float=1, _off_hand:bool=false):
	if action_name == "Default":
		current_body_animation_action = "ForwardAnimation"
	if action_name == "Self":
		current_body_animation_action = "SelfAnimation"
	if action_name == "Forward":
		current_body_animation_action = "ForwardAnimation"
	if action_name == "Arch":
		current_body_animation_action = "ForwardAnimation"
	if !current_body_animation_action:
		printerr("SimpleActorNode.ready_action_animation: Unknown Action Name '%s'." % [action_name])
		return
	body_animation.play(current_body_animation_action + "_ready")
	body_animation.speed_scale = speed

func execute_action_motion_animation(speed:float=1, _off_hand:bool=false):
	if !current_body_animation_action:
		return
	body_animation.play(current_body_animation_action + "_motion")
	body_animation.speed_scale = speed

func cancel_action_animations():
	if current_body_animation_action:
		body_animation.play(current_body_animation_action + "_cancel")
	pass


func _on_action_failed():
	super()
	cancel_action_animations()
