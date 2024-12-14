@tool
class_name ActorNode
extends Node2D

const LOGGING = false


enum FACING_DIRS {North, East, South, West}
const FACING_ANIMATION:String = 'facing/facing'
@export var editing_facing_direction:FACING_DIRS:
	set(val):
		editing_facing_direction = val
		if Engine.is_editor_hint():
			set_facing_dir(val)
		
@export var vfx_holder:Node2D
@export var animation:AnimationPlayer
@export var path_arrow:Sprite2D
@export var offset_node:Node2D
@export var actor_sprite:Sprite2D
@export var main_hand_node:ActorHandNode
@export var off_hand_node:ActorHandNode

## Represents the position of the actor accounting for movement
@export var actor_motion_node:Node2D

#func _load_nodes():
	#if !actor_sprite:
		#animation = $AnimationPlayer
		#offset_node = $ActorMotionNode/ActorSpriteNode/OffsetNode
		#actor_sprite = $ActorMotionNode/ActorSpriteNode/OffsetNode/ActorSprite
		##main_hand_sprite = $ActorMotionNode/ActorSpriteNode/OffsetNode/MainHandOverSprite
		##off_hand_sprite = $ActorMotionNode/ActorSpriteNode/OffsetNode/OffHandOverlaySprite
		##two_hand_sprite = $ActorMotionNode/ActorSpriteNode/OffsetNode/TwoHandOverSprite
		#main_hand_node = $ActorMotionNode/ActorSpriteNode/OffsetNode/MainHandNode
		#off_hand_node = $ActorMotionNode/ActorSpriteNode/OffsetNode/OffHandNode
		##two_hand_weapon_node = $ActorMotionNode/ActorSpriteNode/OffsetNode/TwoHandOverSprite/TwoHandWeaponNode

var Id:String 
var Actor:BaseActor 
var facing_dir
var start_walk_on_pos_change:bool
var is_walking

var is_dieing:bool

var current_animation_speed:float=1.0
var current_animation_action_name:String
#var current_animation_hand_name:String

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	if CombatRootControl.Instance and is_instance_valid(CombatRootControl.Instance) and CombatRootControl.Instance.QueController:
		CombatRootControl.Instance.QueController.execution_paused.connect(pause_animations)
		CombatRootControl.Instance.QueController.execution_resumed.connect(resume_animations)
	animation.animation_started.connect(animation_started)
	animation.animation_finished.connect(animation_finished)

func _process(delta: float) -> void:
	if is_dieing:
		if animation.is_playing():
			return
		if vfx_holder.get_children().size() > 0:
			return
		self.queue_free()

func set_actor(actor:BaseActor):
	Id = actor.Id
	Actor = actor
	if not actor.equipment_changed.is_connected(sync_sprites):
		actor.equipment_changed.connect(sync_sprites)
		actor.turn_failed.connect(_turn_failed_animations)
		actor.on_move.connect(on_actor_moved)
		actor.on_death.connect(queue_death)
	#_load_nodes()
	var frames = actor.get_load_val("SpriteFrameWH", [1,1])
	actor_sprite.hframes = frames[0]
	actor_sprite.vframes = frames[1]
	main_hand_node.hand_sprite.hframes = frames[0]
	main_hand_node.hand_sprite.vframes = frames[1]
	off_hand_node.hand_sprite.hframes = frames[0]
	off_hand_node.hand_sprite.vframes = frames[1]
	if frames[0] == 0:
		main_hand_node.visible = false
		off_hand_node.visible = false
	
	var offset = actor.get_load_val("SpriteOffset", [0,0])
	offset_node.position = Vector2i(offset[0], offset[1])
	sync_sprites()

func sync_sprites():
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

func on_actor_moved(old_pos:MapPos, new_pos:MapPos, move_data:Dictionary):
	set_display_pos(new_pos)

func set_facing_dir(dir:int):
	if facing_dir == dir:
		return
	facing_dir = dir
	#print("Facing Direction: %s" % [facing_dir])
	if animation:
		_start_anim(FACING_ANIMATION + get_animation_dir_sufix())
	if main_hand_node:
		main_hand_node.animation.play("weapon_" + FACING_ANIMATION + get_animation_dir_sufix())
	if off_hand_node:
		off_hand_node.animation.play("weapon_" + FACING_ANIMATION + get_animation_dir_sufix())

func set_display_pos(pos:MapPos):
	if Actor.ActorKey == 'TestActor':
		if LOGGING: print("-------set_display_pos------------")
	#_load_nodes()
	if !pos:
		return
	set_facing_dir(pos.dir)
	
	if actor_sprite.vframes == 1:
		#if facing_dir == 0: actor_sprite.set_rotation_degrees(0)
		#if facing_dir == 1: actor_sprite.set_rotation_degrees(90)
		#if facing_dir == 2: actor_sprite.set_rotation_degrees(180)
		#if facing_dir == 3: actor_sprite.set_rotation_degrees(270) 
		var parent = get_parent()
		if parent is TileMapLayer:
			self.position = parent.map_to_local(Vector2i(pos.x, pos.y))
		return
	
	if !is_walking:
		if LOGGING: print("%s | set Facing: %s"  % [Time.get_ticks_msec(), get_animation_dir_sufix()])
		#_start_anim("facing/facing"+get_animation_dir_sufix())
	else:
		if LOGGING:
			print("IS Walking")
	
	var parent = get_parent()
	if parent is TileMapLayer:
		var map_pos = parent.map_to_local(Vector2i(pos.x, pos.y))
		if LOGGING: print("%s | Set Pos"  % [Time.get_ticks_msec()])
		if LOGGING: print("HardSet pos")
		self.position = map_pos

func get_animation_dir_sufix()->String:
	if facing_dir == 0: return "_north"
	if facing_dir == 1: return "_east"
	if facing_dir == 2: return "_south"
	if facing_dir == 3: return "_west"
	return "_south"

func animation_finished(name:String):
	if LOGGING: print("%s | Animation Finished: %s"  % [Time.get_ticks_msec(), name])
	is_walking = false
	if name.contains("motion_"):
		_start_anim("facing/facing"+get_animation_dir_sufix())
		

func animation_started(name:String):
	if LOGGING: print("%s | Animation Started: %s"  % [Time.get_ticks_msec(), name])
	if name.begins_with("move_"):
		is_walking = true
		if LOGGING: print("-Set Is Walking")
	else:
		is_walking = false
		if LOGGING: print("-Set Not Walking")

func _turn_failed_animations():
	if not current_animation_action_name.contains("/ready"):
		cancel_current_animation()

func fail_movement():
	if LOGGING: printerr("Movment Failed")
	is_walking = false
	_start_anim("facing/facing"+get_animation_dir_sufix())
	if LOGGING: print("After_PlayConnecnd")
	

func play_shake():
	_start_anim("shake_effect")

func queue_death():
	if is_dieing:
		return
	if LOGGING: print("########################## Que Dieing")
	_start_anim("death_effect")
	is_dieing = true


func _start_anim(animation_name, speed:float=current_animation_speed):
	if is_dieing:
		return
	if LOGGING: print("Playing Animation: %s" + animation_name)
	animation.play(animation_name)
	animation.speed_scale = speed * CombatRootControl.get_time_scale()
	current_animation_speed = speed


func start_weapon_animation(action_name:String, off_hand:bool=false, speed:float=1):
	var animation_name = action_name + "/ready" + get_animation_dir_sufix()
	if off_hand and off_hand_node:
		off_hand_node.ready_arnimation(action_name, get_animation_dir_sufix())
	elif main_hand_node:
		main_hand_node.ready_arnimation(action_name, get_animation_dir_sufix())
	current_animation_action_name = animation_name

func start_walk_animation(animation_name, speed:float=1):
	current_animation_action_name = animation_name + "/ready" + get_animation_dir_sufix()
	_start_anim(current_animation_action_name, speed)
	

func execute_animation_motion():
	if current_animation_action_name.begins_with("move_") or current_animation_action_name.begins_with("move_"):
		var animation_name = current_animation_action_name.replace("/ready_", "/motion_")
		_start_anim(animation_name)
		if LOGGING: print("Playing Motion Animation: " + animation_name)
	else:
		main_hand_node.execute_animation()

func cancel_current_animation():
	if current_animation_action_name.begins_with("weapon_"):
		if main_hand_node.current_animation.contains("/ready"):
			main_hand_node.cancel_animation()
	elif current_animation_action_name.contains("/ready_"):
		var animation_name = current_animation_action_name.replace("/ready_", "/cancel_")
		if LOGGING: print("Playing Cancel Animation: " + animation_name)
		_start_anim(animation_name)
		is_walking = false

func clear_any_animations():
	_start_anim("facing/facing"+get_animation_dir_sufix())
	main_hand_node.clear_any_animations(get_animation_dir_sufix())

#func start_walk_out_animation():
	#if LOGGING: print("Start Walk")
	#_start_anim("walk/ready_"+get_animation_dir_sufix())
	#
#func start_walk_in_animation():
	#if LOGGING: print("Finish Walk")
	#_start_anim("walk/motion_"+get_animation_dir_sufix())
	#is_walking = false

func set_corpse_sprite():
	actor_sprite.texture = Actor.sprite.get_corpse_sprite()
	actor_sprite.vframes = 1
	actor_sprite.hframes = 1
	actor_sprite.offset = Vector2i.ZERO

func hide_path_arrow():
	path_arrow.visible = false

func show_path_arrow():
	path_arrow.visible = true

func reset_path_arrow():
	path_arrow.visible = true
	path_arrow.position = Vector2.ZERO
	if facing_dir == 0: path_arrow.set_rotation_degrees(0) 
	if facing_dir == 1: path_arrow.set_rotation_degrees(90) 
	if facing_dir == 2: path_arrow.set_rotation_degrees(180) 
	if facing_dir == 3: path_arrow.set_rotation_degrees(270) 

func set_path_arrow_pos(pos:MapPos):
	if not path_arrow.visible:
		path_arrow.visible = true
	var tile_map = get_parent() as TileMapLayer
	var local_pos = tile_map.map_to_local(Vector2i(pos.x, pos.y)) - self.position
	path_arrow.position = local_pos
	path_arrow.visible = true
	if pos.dir == 0: path_arrow.set_rotation_degrees(0) 
	if pos.dir == 1: path_arrow.set_rotation_degrees(90) 
	if pos.dir == 2: path_arrow.set_rotation_degrees(180) 
	if pos.dir == 3: path_arrow.set_rotation_degrees(270) 

func pause_animations():
	animation.pause()

func resume_animations():
	animation.play()
