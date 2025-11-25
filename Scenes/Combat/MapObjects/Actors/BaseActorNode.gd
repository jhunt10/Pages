class_name BaseActorNode
extends Node2D

const LOGGING = false
const WALK_ANIM_NAME = "move_walk/walk"

signal reached_motion_destination

@export var vfx_holder:VfxHolder
@export var aura_holder:AuraHolder
@export var actor_sprite:ActorBodySprite
@export var path_arrow:Sprite2D

## Represents the dynamic position of the actor accounting for movement
@export var actor_motion_node:Node2D
## Represents the static position of the actor's sprite inside the tile
@export var offset_node:Node2D

## Player for death and on damage (shake) animations. Requires: "death_effect" and "shake_effect"
@export var damage_animation_player:AnimationPlayer
## Player for movement animations
@export var body_animation:AnimationPlayer

var Id:String 
var Actor:BaseActor 
var facing_dir:MapPos.Directions = MapPos.Directions.North
var paused:bool = false
var is_dieing:bool

var current_animation_speed:float=1.0
var current_body_animation_action

func _ready() -> void:
	if CombatRootControl.Instance and is_instance_valid(CombatRootControl.Instance) and CombatRootControl.Instance.QueController:
		CombatRootControl.Instance.QueController.execution_paused.connect(_on_pause_animations)
		CombatRootControl.Instance.QueController.execution_resumed.connect(_on_resume_animations)
		CombatRootControl.Instance.QueController.start_of_round.connect(hide_path_arrow)
	if not damage_animation_player.has_animation_library("DamageAnimations"):
		damage_animation_player.add_animation_library("DamageAnimations", load("res://Scenes/Combat/MapObjects/Actors/damage_animation_library.res"))


func _process(delta: float) -> void:
	if paused:
		return
	if is_dieing:
		if damage_animation_player.is_playing():
			return
		if vfx_holder.get_children().size() > 0:
			return
		self.queue_free()
		return
	if is_moving:
		var change = delta * movement_speed
		move_timmer += delta
		#print("Moveing: Pos: %s | Change: %s | Time: %s" % [self.position, change, move_timmer])
		if actor_motion_node.position.distance_to(movement_dest_position) < change:
			actor_motion_node.position = movement_dest_position
			is_moving = false
			if current_body_animation_action:
				_on_reached_dest()
				move_timmer = 0
		else:
			actor_motion_node.position = actor_motion_node.position.move_toward(movement_dest_position, change)
	# Not Moving
	else:
		if is_animated_moveing:
			printerr("%s: Stray walking animation without moving" % [Actor.Id])
			finish_move_animation()


func set_actor(actor:BaseActor):
	Id = actor.Id
	Actor = actor
	self.name = actor.Id
	if not actor.on_move.is_connected(_on_actor_moved):
		actor.on_move_failed.connect(_on_movement_failed)
		actor.action_failed.connect(_on_action_failed)
		actor.on_move.connect(_on_actor_moved)
		actor.on_death.connect(_on_actor_death)
		actor.on_revive.connect(_on_actor_revive)
		
	var frames = actor.get_load_val("SpriteFrameWH", [1,1])
	actor_sprite.hframes = frames[0]
	actor_sprite.vframes = frames[1]
	
	var offset = actor.get_load_val("SpriteOffset", [0,0])
	offset_node.position = Vector2i(offset[0], offset[1])
	
	actor_sprite.texture = Actor.sprite.get_body_sprite()

#Called when actor is added to combat_scene
func prep_for_combat():
	pass

###############################
##		Positioning
##############################

func set_facing_dir(dir):
	facing_dir = dir
	if actor_sprite:
		actor_sprite.direction = dir

## Forces the actor to given position
func set_map_pos(pos:MapPos, keep_movement_offset:bool=false):
	if !pos: return
	set_facing_dir(pos.dir)
	
	var parent = get_parent()
	var tile_map = parent as TileMapLayer
	if not tile_map: return
	
	self.position = parent.map_to_local(Vector2i(pos.x, pos.y))
	if not keep_movement_offset:
		actor_motion_node.position = Vector2.ZERO
	cur_map_pos = pos

##############################
##		MOVEMENT
##############################

var move_timmer = 0
var cur_map_pos:MapPos
var movement_start_position:Vector2
var movement_dest_position:Vector2
var movemen_speed_scale:float = 1
var movement_speed:float = 1

var is_moving:bool
var is_animated_moveing:bool:
	get: return current_body_animation_action == WALK_ANIM_NAME

## Set the MapPosition the Actor is moving towards.
func set_move_destination(map_pos:MapPos, frames_to_reach:int, start_walking_if_not:bool=true, speed_scale:float=movemen_speed_scale):
	if _is_moving_on_script:
		printerr("BaseActorNode: Attemped set_move_destination while scripted movevment is active.")
		return
	movement_start_position = actor_motion_node.position
	var tile_map = get_parent()  as TileMapLayer
	if not tile_map: return
	if map_pos.dir != facing_dir:
		set_facing_dir(map_pos.dir)
	movement_dest_position = tile_map.map_to_local(map_pos.to_vector2i())  - self.position
	var secs_to_reach = (frames_to_reach * ActionQueController.SUB_ACTION_FRAME_TIME) 
	var dist = movement_start_position.distance_to(movement_dest_position)
	movemen_speed_scale = speed_scale
	movement_speed =  (dist / secs_to_reach) * CombatRootControl.get_time_scale() * speed_scale
	is_moving = movement_start_position.distance_to(movement_dest_position) > 0.01
	if LOGGING: print("Starting Movement: FtR: %s | TtR: %s | Dist: %s | MS: %s " % [frames_to_reach, secs_to_reach,dist, movement_speed ])
	if LOGGING: print("Start Pos: %s | Target Pos: %s" % [movement_start_position, movement_dest_position])
	if  is_moving and start_walking_if_not and not is_animated_moveing:
		start_move_animation()
	
	if not is_moving and _is_moving_on_script:
		_scripted_move_finshed()
	
	pass

var _movement_que:Array
var _moving_in_loop:bool
var _is_moving_on_script:bool

func force_finish_movement():
	if not _is_moving_on_script or _movement_que.size() == 0:
		return
	var last_pos = _movement_que[-1].get("Pos", null)
	_movement_que.clear()
	_moving_in_loop = false
	_is_moving_on_script = false
	is_moving = false
	if last_pos:
		set_map_pos(last_pos, false)

func que_scripted_movement(path_pos_data:Array):
	_moving_in_loop = false
	if path_pos_data.size() == 0:
		return
	for pos in path_pos_data:
		_movement_que.append(pos)
	if not is_moving:
		_start_next_queued_movement()

func set_scripted_movement_loop(path_pos_data:Array):
	if path_pos_data.size() == 0:
		return
	_moving_in_loop = true
	_movement_que.clear()
	for pos in path_pos_data:
		_movement_que.append(pos)
	if not is_moving:
		_start_next_queued_movement()

func _on_reached_dest():
	if LOGGING: print("Reached Dest")
	if is_animated_moveing:
		finish_move_animation()
	is_moving = false
	if _is_moving_on_script:
		if LOGGING: print("Was Moving On Script")
		_scripted_move_finshed()
		return
	reached_motion_destination.emit()

func _start_next_queued_movement():
	if LOGGING: print("Starting Movemnt")
	if _movement_que.size() <= 0:
		if LOGGING: print("--Move Que Empty")
		_is_moving_on_script = false
		return
	
	var next_pos_data = _movement_que[0]
	if not _moving_in_loop and next_pos_data.get("End", false):
		var index = 0
		while index < _movement_que.size():
			if not next_pos_data.get("End", false) and _movement_que[index].get("Looped", false):
				_movement_que.remove_at(index)
			else:
				index += 1
	if (next_pos_data == null or next_pos_data['Pos'] == cur_map_pos):
		print("MoveActor: Already at pos: %s | %s " % [next_pos_data['Pos'], cur_map_pos])
		_scripted_move_finshed()
		return
	
	if LOGGING: print("--Starting Queued Pos: %s " % [next_pos_data['Pos']])
	var pos = next_pos_data['Pos']
	var frames = next_pos_data['Frames']
	var speed = next_pos_data['Speed']
	
	movement_start_position = actor_motion_node.position
	var tile_map = get_parent()  as TileMapLayer
	if not tile_map: 
		_is_moving_on_script = false
		return
	
	movement_dest_position = tile_map.map_to_local(pos.to_vector2i())  - self.position
	var secs_to_reach = (frames * ActionQueController.SUB_ACTION_FRAME_TIME) 
	var dist = movement_start_position.distance_to(movement_dest_position)
	movement_speed =  (dist / secs_to_reach) * CombatRootControl.get_time_scale() * speed
	is_moving = movement_start_position.distance_to(movement_dest_position) > 0.01
	if not is_moving:
		_is_moving_on_script = true
		_on_reached_dest()
	else:
		start_move_animation()
		_is_moving_on_script = true

func _scripted_move_finshed():
	var current_pos_data = _movement_que[0]
	if LOGGING: print("Script Finished: %s" % [current_pos_data])
	_movement_que.remove_at(0)
	if _moving_in_loop:
		if _movement_que.size() == 0:
			printerr("Infanate movement loop due to singe spot")
		else:
			current_pos_data['Looped'] = true
			_movement_que.append(current_pos_data)
	var reached_pos = current_pos_data['Pos']
	if reached_pos != cur_map_pos:
		set_map_pos(reached_pos)
	
	# Force end loops when disabled
	if not _moving_in_loop and current_pos_data.get('End', false):
		_movement_que.clear()
	
	if _movement_que.size() == 0:
		_is_moving_on_script = false
		reached_motion_destination.emit()
	else:
		_start_next_queued_movement()

##############################
##		Animations
##############################

func play_shake():
	if damage_animation_player.current_animation != "DamageAnimations/death_effect":
		damage_animation_player.play("DamageAnimations/shake_effect")
	pass

func start_death_animation():
	damage_animation_player.play("DamageAnimations/death_effect")
	damage_animation_player.animation_finished.connect(on_death_animation_finished)

func start_move_animation():
	if LOGGING: print("Walk Animation Starting. Cur: %s" % [current_body_animation_action])
	if is_animated_moveing:
		return
	current_body_animation_action = WALK_ANIM_NAME
	body_animation.speed_scale = CombatRootControl.get_time_scale()
	body_animation.play(current_body_animation_action)

func finish_move_animation():
	if LOGGING: print("Walk Animation Finished. Cur: %s" % [current_body_animation_action])
	if not is_animated_moveing:
		return
	body_animation.stop()
	actor_sprite.frame_coords.x = 0
	current_body_animation_action = null

func add_modulate(color:Color):
	offset_node.modulate = color

func remove_modulate(color:Color):
	if offset_node.modulate == color:
		offset_node.modulate = Color.WHITE

func ready_action_animation(action_name:String, speed:float=1, off_hand:bool=false):
	pass

func execute_action_motion_animation(speed:float=1, off_hand:bool=false):
	pass

func cancel_action_animations():
	pass

func _get_animation_dir_sufix()->String:
	if facing_dir == 0: return "_north"
	if facing_dir == 1: return "_east"
	if facing_dir == 2: return "_south"
	if facing_dir == 3: return "_west"
	return "_south"


##############################
##		Triggers
##############################
func _on_pause_animations():
	paused = true
	damage_animation_player.pause()

func _on_resume_animations():
	paused = false
	if current_body_animation_action:
		if damage_animation_player.current_animation:
			damage_animation_player.play()

func _on_actor_moved(old_pos:MapPos, new_pos:MapPos, move_data:Dictionary):
	if LOGGING: print("BaseActorNode: OnActorMoved: Actor: %s | old_pos: %s | new_pos: %s" % [Actor.Id, old_pos, new_pos])
	if is_moving and new_pos:
		set_facing_dir(new_pos.dir)
		set_move_destination(new_pos, CombatRootControl.get_remaining_frames_for_turn())
		var global_motion_pos = self.global_position + actor_motion_node.position
		var global_motion_dest_pos = self.global_position + movement_dest_position
		set_map_pos(new_pos, true)
		actor_motion_node.position = global_motion_pos - self.global_position
		movement_dest_position = global_motion_dest_pos - self.global_position
	else:
		set_map_pos(new_pos)
	pass

func _on_movement_failed(cur_pos:MapPos):
	# Reappear if teleporting fails
	if !self.visible:
		self.visible = true
	if is_moving and cur_pos:
		set_facing_dir(cur_pos.dir)
		set_move_destination(cur_pos, CombatRootControl.get_remaining_frames_for_turn())

func _on_action_failed():
	pass

# Starts process of dying (have to wait for some animations)
func _on_actor_death():
	if is_dieing:
		return
	if LOGGING: print("########################## Que Dieing")
	start_death_animation()
	is_dieing = true

func _on_actor_revive():
	is_dieing = false
	damage_animation_player.play("DamageAnimations/revive_effect")

func on_death_animation_finished(animation_name:String):
	pass

##############################
##		Path Arrow
##############################
func hide_path_arrow():
	if not path_arrow:
		return
	path_arrow.visible = false

func show_path_arrow():
	if not path_arrow:
		return
	path_arrow.visible = true

func reset_path_arrow():
	if not path_arrow:
		return
	path_arrow.visible = true
	path_arrow.position = Vector2.ZERO
	if facing_dir == 0: path_arrow.set_rotation_degrees(0) 
	if facing_dir == 1: path_arrow.set_rotation_degrees(90) 
	if facing_dir == 2: path_arrow.set_rotation_degrees(180) 
	if facing_dir == 3: path_arrow.set_rotation_degrees(270) 

func set_path_arrow_pos(pos:MapPos):
	if not path_arrow:
		return
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
