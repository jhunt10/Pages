@tool
class_name ComplexActorNode
extends BaseActorNode

#const FACING_ANIMATION:String = 'facing/facing'
@export var editing_facing_direction:MapPos.Directions:
	set(val):
		editing_facing_direction = val
		if Engine.is_editor_hint():
			set_facing_dir(val)
		
@export var main_hand_node:ActorHandNode
@export var off_hand_node:ActorHandNode

var current_main_weapon_animation_action
var current_off_weapon_animation_action

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	super()

func set_actor(actor:BaseActor):
	super(actor)
	if not actor.equipment_changed.is_connected(_sync_sprites):
		actor.equipment_changed.connect(_sync_sprites)
	main_hand_node.hand_sprite.hframes = actor_sprite.hframes
	main_hand_node.hand_sprite.vframes = actor_sprite.vframes
	off_hand_node.hand_sprite.hframes = actor_sprite.hframes
	off_hand_node.hand_sprite.vframes = actor_sprite.vframes
	
	if actor.is_player:
		var player_index = StoryState.get_player_index_of_actor(actor)
		path_arrow.modulate = StoryState.get_player_color(player_index)
	_sync_sprites()

func _sync_sprites():
	actor_sprite.texture = Actor.sprite.get_body_sprite()
	if actor_sprite.hframes == 1:
		main_hand_node.visible = false
		off_hand_node.visible = false
		return
		
	main_hand_node.main_hand_sprite_sheet = Actor.sprite.get_main_hand_sprite()
	main_hand_node.two_hand_sprite_sheet = Actor.sprite.get_two_hand_sprite()
	off_hand_node.off_hand_sprite_sheet = Actor.sprite.get_off_hand_sprite()
	
	if Actor.equipment.is_two_handing():
		main_hand_node.hand = ActorHandNode.HANDS.TwoHand
		off_hand_node.visible = false
	else:
		main_hand_node.hand = ActorHandNode.HANDS.MainHand
		off_hand_node.visible = true
		
	var main_hand_weapon = Actor.equipment.get_primary_weapon()
	if main_hand_weapon:
		main_hand_node.set_weapon(main_hand_weapon)
	else:
		main_hand_node.hide_weapon()
	
	# Resets sprite
	off_hand_node.hand = ActorHandNode.HANDS.OffHand
	var off_hand_weapon = Actor.equipment.get_offhand_weapon()
	if off_hand_weapon:
		off_hand_node.set_weapon(off_hand_weapon)
	else:
		off_hand_node.hide_weapon()

func _on_action_failed():
	super()
	cancel_weapon_animations()


func set_facing_dir(dir:MapPos.Directions):
	super(dir)
	print("Setting Complex Actor Dir: %s" % [dir])
	if actor_sprite: 
		actor_sprite.direction = facing_dir
	else:
		return
		
	if facing_dir == MapPos.Directions.North:
		actor_sprite.z_index = 4
		main_hand_node.z_index = 2
		off_hand_node.z_index = 0
		main_hand_node.two_hand_z_west_override = false
	if facing_dir == MapPos.Directions.East:
		actor_sprite.z_index = 3
		main_hand_node.z_index = 3
		off_hand_node.z_index = 0
		main_hand_node.two_hand_z_west_override = false
	if facing_dir == MapPos.Directions.South:
		actor_sprite.z_index = 0
		main_hand_node.z_index = 2
		off_hand_node.z_index = 1
		main_hand_node.two_hand_z_west_override = false
	if facing_dir == MapPos.Directions.West:
		actor_sprite.z_index = 3
		main_hand_node.z_index = 0
		off_hand_node.z_index = 3
		main_hand_node.two_hand_z_west_override = true
	
	if main_hand_node: main_hand_node.set_facing_dir(facing_dir)
	if off_hand_node: off_hand_node.set_facing_dir(facing_dir)
	
	vfx_holder.position = actor_sprite.get_sprite_center() + offset_node.position

####################################################
#			Weapon ANIMATIONS
####################################################
func _on_pause_animations():
	super()
	body_animation.pause()

func _on_resume_animations():
	super()
	if current_body_animation_action:
		body_animation.play()

func ready_action_animation(action_name:String, speed:float=1, off_hand:bool=false):
	var weapon_animation = ''
	if action_name == "Default:Weapon":
		weapon_animation = 'WEAPON_DEFAULT'
	elif action_name == "Default:Self":
		weapon_animation = 'Raise'
	elif action_name == "Default:Forward":
		weapon_animation = 'Stab'
	elif action_name == "Default:Forward:Arch":
		weapon_animation = 'Swing'
	elif ['Swing', 'Raise', 'Stab'].has(action_name):
		weapon_animation = action_name
		
	if weapon_animation != '':
		ready_weapon_animation(weapon_animation, speed, off_hand)

func execute_action_motion_animation(speed:float=1, off_hand:bool=false):
	execute_weapon_motion_animation(speed, off_hand)
	pass

func cancel_action_animations():
	cancel_weapon_animations()
	
func ready_weapon_animation(action_name:String, speed:float=1, off_hand:bool=false):
	if off_hand and off_hand_node:
		off_hand_node.ready_arnimation(action_name, speed)
	elif main_hand_node:
		main_hand_node.ready_arnimation(action_name, speed)

func execute_weapon_motion_animation(speed:float=1, off_hand:bool=false):
	if off_hand and off_hand_node:
		off_hand_node.execute_animation(speed)
	elif main_hand_node:
		main_hand_node.execute_animation(speed)

func cancel_weapon_animations():
	if main_hand_node and main_hand_node.animation_is_ready:
		main_hand_node.cancel_animation()
	if off_hand_node and off_hand_node.animation_is_ready:
		off_hand_node.cancel_animation()

func execute_animation_motion():
	if current_body_animation_action and (current_body_animation_action.begins_with("move_") or current_body_animation_action.begins_with("move_")):
		var animation_name = current_body_animation_action.replace("/ready_", "/motion_")
		#_start_anim(animation_name)
		if LOGGING: print("Playing Motion Animation: " + animation_name)
	elif main_hand_node.readied_animation:
		main_hand_node.execute_animation()

#func cancel_current_animation():
	#if current_body_animation_action:
		#if current_body_animation_action.begins_with("weapon_"):
			#if main_hand_node.current_animation.contains("/ready"):
				#main_hand_node.cancel_animation()
		#elif current_body_animation_action.contains("/ready_"):
			#var animation_name = current_body_animation_action.replace("/ready_", "/cancel_")
			#if LOGGING: print("Playing Cancel Animation: " + animation_name)

#func clear_any_animations():
	#main_hand_node.clear_any_animations(_get_animation_dir_sufix())

func set_corpse_sprite():
	actor_sprite.texture = Actor.sprite.get_corpse_sprite()
	actor_sprite.vframes = 1
	actor_sprite.hframes = 1
	actor_sprite.offset = Vector2i.ZERO
