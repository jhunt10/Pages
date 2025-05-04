class_name SimpleActorNode
extends BaseActorNode

func _ready() -> void:
	super()

func _process(delta: float) -> void:
	super(delta)

func ready_action_animation(action_name:String, speed:float=1, off_hand:bool=false):
	if action_name == "Default:Self":
		current_body_animation_action = "SelfAnimation"
	if action_name == "Default:Forward":
		current_body_animation_action = "ForwardAnimation"
	if action_name == "Default:Forward:Arch":
		current_body_animation_action = "ForwardAnimation"
	body_animation.play(current_body_animation_action + "_ready")

func execute_action_motion_animation(speed:float=1, off_hand:bool=false):
	body_animation.play(current_body_animation_action + "_motion")
	pass

func cancel_action_animations():
	body_animation.play(current_body_animation_action + "_cancel")
	pass
