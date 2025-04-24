class_name AnimationTester
extends Control

@export var actor_node:BaseActorNode
@export var load_actor_option_button:LoadedOptionButton
@export var animation_option_button:LoadedOptionButton
@export var ready_button:Button
@export var execute_button:Button
@export var cancel_button:Button
@export var off_hand_box:CheckBox

@export var rotate_clock_button:Button
@export var rotate_count_button:Button
@export var direction_option_button:OptionButton
@export var exit_button:Button

var current_actor:BaseActor
var facing_direction:MapPos.Directions:
	get:
		if actor_node:
			return actor_node.facing_dir
		return MapPos.Directions.South
	set(val):
		facing_direction = val
		if actor_node:
			actor_node.set_facing_dir(val)
		if direction_option_button:
			direction_option_button.select(val)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_actor_option_button.get_options_func = _get_actor_options
	load_actor_option_button.item_selected.connect(on_actor_selected)
	
	animation_option_button.get_options_func = _get_animation_options
	animation_option_button.item_selected.connect(on_animation_selected)
	ready_button.pressed.connect(on_ready_animation)
	execute_button.pressed.connect(on_execute_animation)
	cancel_button.pressed.connect(on_cancel_animation)
	
	direction_option_button.item_selected.connect(on_direction_selected)
	rotate_clock_button.pressed.connect(rotate_direction.bind(true))
	rotate_count_button.pressed.connect(rotate_direction.bind(false))
	exit_button.pressed.connect(queue_free)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _get_actor_options()->Array:
	return [
		'SoldierTemplate',
		'RogueTemplate',
		'BanditCaptain'
	]

func on_animation_selected(index):
	var aniname = animation_option_button.get_item_text(index)
	if aniname == 'WEAPON_DEFAULT' and actor_node.Actor:
		aniname = get_default_weapon_animation(actor_node.Actor, false)
	actor_node.ready_weapon_animation(aniname, 1, off_hand_box.button_pressed)

func on_ready_animation():
	if animation_option_button and animation_option_button.selected >= 0:
		var aniname = animation_option_button.get_current_option_text()
		if aniname == 'WEAPON_DEFAULT' and actor_node.Actor:
			aniname = get_default_weapon_animation(actor_node.Actor, false)
		actor_node.ready_weapon_animation(aniname, 1, off_hand_box.button_pressed)
func on_execute_animation():
	actor_node.execute_weapon_motion_animation(1, off_hand_box.button_pressed)
func on_cancel_animation():
	actor_node.cancel_weapon_animations()

func _get_animation_options()->Array:
	return [
		"WEAPON_DEFAULT",
		"Raise",
		"Stab",
		"Swing"
	]

func on_actor_selected(index):
	var actor_key = load_actor_option_button.get_item_text(index)
	current_actor =  ActorLibrary.get_or_create_actor(actor_key, actor_key+"_AnimationTest")
	actor_node.set_actor(current_actor)
	on_direction_selected(2)

func on_direction_selected(index):
	if index != facing_direction:
		facing_direction = index

func rotate_direction(clock:bool):
	var dir = facing_direction
	if clock:
		dir = (dir + 1 + 4) % 4
	else:
		dir = (dir - 1 + 4) % 4
	facing_direction = dir

func get_default_weapon_animation(actor:BaseActor, off_hand:bool):
	if off_hand:
		var off_weapon = actor.equipment.get_offhand_weapon()
		if off_weapon:
			return off_weapon.get_load_val("WeaponAnimation", null)
	else:
		var primary_weapon = actor.equipment.get_primary_weapon()
		if primary_weapon:
			return primary_weapon.get_load_val("WeaponAnimation", null)
	return null
	
