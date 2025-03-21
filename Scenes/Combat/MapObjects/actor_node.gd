@tool
class_name ActorNode
extends Node2D

const LOGGING = false

signal reached_motion_destination

#const FACING_ANIMATION:String = 'facing/facing'
@export var editing_facing_direction:MapPos.Directions:
	set(val):
		editing_facing_direction = val
		if Engine.is_editor_hint():
			set_facing_dir(val)
		
@export var vfx_holder:VfxHolder
@export var body_animation:AnimationPlayer
@export var death_animation:AnimationPlayer
@export var path_arrow:Sprite2D
@export var offset_node:Node2D
@export var actor_sprite:ActorBodySprite
@export var main_hand_node:ActorHandNode
@export var off_hand_node:ActorHandNode

## Represents the position of the actor accounting for movement
@export var actor_motion_node:Node2D

const WALK_ANIM_NAME = "move_walk/walk"

var Id:String 
var Actor:BaseActor 
var facing_dir:MapPos.Directions = MapPos.Directions.North
var paused:bool = false

var is_dieing:bool

var current_animation_speed:float=1.0
var current_body_animation_action
var current_main_weapon_animation_action
var current_off_weapon_animation_action


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	if CombatRootControl.Instance and is_instance_valid(CombatRootControl.Instance) and CombatRootControl.Instance.QueController:
		CombatRootControl.Instance.QueController.execution_paused.connect(pause_animations)
		CombatRootControl.Instance.QueController.execution_resumed.connect(resume_animations)
	#animation.animation_started.connect(animation_started)
	#animation.animation_finished.connect(animation_finished)

func set_actor(actor:BaseActor):
	Id = actor.Id
	Actor = actor
	self.name = actor.Id
	if not actor.equipment_changed.is_connected(sync_sprites):
		actor.equipment_changed.connect(sync_sprites)
		actor.on_move_failed.connect(_on_movement_failed)
		actor.action_failed.connect(_on_action_failed)
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
	#vfx_holder.position = Vector2i(offset[0], offset[1])
	
	if actor.is_player:
		var player_index = StoryState.get_player_index_of_actor(actor)
		path_arrow.modulate = StoryState.get_player_color(player_index)
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
	if LOGGING: print("ActorNode: OnActorMoved: Actor: %s | old_pos: %s | new_pos: %s" % [Actor.Id, old_pos, new_pos])
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
	if is_moving and cur_pos:
		set_facing_dir(cur_pos.dir)
		set_move_destination(cur_pos, CombatRootControl.get_remaining_frames_for_turn())
	

func _on_action_failed():
	cancel_weapon_animations()

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

func set_facing_dir(dir:MapPos.Directions):
	#if facing_dir == dir and not force_set:
		#return
	facing_dir = dir
	
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

var move_timmer = 0
func _process(delta: float) -> void:
	if paused:
		return
	if is_dieing:
		if death_animation.is_playing():
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
		if is_walking:
			printerr("%s: Stray walking animation without moving" % [Actor.Id])
			finsh_walk_animation()

var cur_map_pos:MapPos
var movement_start_position:Vector2
var movement_dest_position:Vector2
var movement_speed:float

var is_moving:bool
var is_walking:bool:
	get: return current_body_animation_action == WALK_ANIM_NAME

## Set the MapPosition the Actor is moving towards.
func set_move_destination(map_pos:MapPos, frames_to_reach:int, start_walking_if_not:bool=true, speed_scale:float=1):
	if _is_moving_on_script:
		printerr("ActorNode: Attemped set_move_destination while scripted movevment is active.")
		return
	movement_start_position = actor_motion_node.position
	var tile_map = get_parent()  as TileMapLayer
	if not tile_map: return
	if map_pos.dir != facing_dir:
		set_facing_dir(map_pos.dir)
	movement_dest_position = tile_map.map_to_local(map_pos.to_vector2i())  - self.position
	var secs_to_reach = (frames_to_reach * ActionQueController.SUB_ACTION_FRAME_TIME) 
	var dist = movement_start_position.distance_to(movement_dest_position)
	movement_speed =  (dist / secs_to_reach) * CombatRootControl.get_time_scale() * speed_scale
	is_moving = movement_start_position.distance_to(movement_dest_position) > 0.01
	if LOGGING: print("Starting Movement: FtR: %s | TtR: %s | Dist: %s | MS: %s " % [frames_to_reach, secs_to_reach,dist, movement_speed ])
	if LOGGING: print("Start Pos: %s | Target Pos: %s" % [movement_start_position, movement_dest_position])
	if  is_moving and start_walking_if_not and not is_walking:
		start_walk_animation()
	
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
	if is_walking:
		finsh_walk_animation()
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
		start_walk_animation()
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
		
	
	#while _movement_que.size() > 0 and (next_pos_data == null or next_pos_data['Pos'] == cur_map_pos):
		#next_pos_data = _movement_que[0]
		#_movement_que.remove_at(0)
	

####################################################
#			BODY ANIMATIONS
####################################################

func start_walk_animation():
	if LOGGING: print("Walk Animation Starting. Cur: %s" % [current_body_animation_action])
	if is_walking:
		return
	current_body_animation_action = WALK_ANIM_NAME
	body_animation.speed_scale = CombatRootControl.get_time_scale()
	body_animation.play(current_body_animation_action)

func finsh_walk_animation():
	if LOGGING: print("Walk Animation Finished. Cur: %s" % [current_body_animation_action])
	if not is_walking:
		return
	body_animation.stop()
	actor_sprite.frame_coords.x = 0
	current_body_animation_action = null


func fail_movement():
	if LOGGING: printerr("Movment Failed")
	if LOGGING: print("After_PlayConnecnd")
	

func play_shake():
	body_animation.play("shake_effect")
	pass

func queue_death():
	if is_dieing:
		return
	if LOGGING: print("########################## Que Dieing")
	death_animation.play("death_effect")
	is_dieing = true

func ready_weapon_animation(action_name:String, speed:float=1, off_hand:bool=false):
	var animation_name = action_name + "/ready" + _get_animation_dir_sufix()
	if off_hand and off_hand_node:
		off_hand_node.ready_arnimation(action_name)
	elif main_hand_node:
		main_hand_node.ready_arnimation(action_name)

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
	paused = true
	body_animation.pause()

func resume_animations():
	paused = false
	if current_body_animation_action:
		body_animation.play()

func _get_animation_dir_sufix()->String:
	if facing_dir == 0: return "_north"
	if facing_dir == 1: return "_east"
	if facing_dir == 2: return "_south"
	if facing_dir == 3: return "_west"
	return "_south"

func add_modulate(color:Color):
	offset_node.modulate = color

func remove_modulate(color:Color):
	if offset_node.modulate == color:
		offset_node.modulate = Color.WHITE
