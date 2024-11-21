class_name AnimationTester
extends HBoxContainer

@export var actor_node:ActorNode
@export var option_button:LoadedOptionButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	actor_node.animation.animation_finished.connect(on_animation_end)
	actor_node.main_hand_node.animation.animation_finished.connect(on_animation_end)
	option_button.get_options_func = animation_list
	option_button.item_selected.connect(on_animation_selected)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func animation_list()->Array:
	return [
		'None',
		'Walk',
		'weapon_raise',
		'weapon_swing',
		'weapon_stab'
	]

func on_animation_selected(index):
	var animation = option_button.get_current_option_text()
	if animation == 'None':
		actor_node.set_display_pos(MapPos.new(0,0,0,2))
	elif animation == 'Walk':
		actor_node.start_walk_animation()
	else:
		actor_node.start_weapon_animation(animation)

func on_animation_end(animation:String):
	print("Test Animation Finished: " + animation)
	if animation.begins_with("walk/walk_out"):
		actor_node.execute_animation_motion()
	if animation.contains("ready_"):
		actor_node.execute_animation_motion()
