class_name BaseMissile

var Id : String = str(ResourceUID.create_id())
func get_tagable_id(): return Id
func get_tags(): return _missle_data.get('Tags', [])

var node:MissileNode
var _source_actor_id:String
var _source_action_key:String
#var _target_key:String
var _missle_data:Dictionary
var _missle_animation_data:AnimatedSpriteData

var SourceActor:BaseActor:
	get:
		return CombatRootControl.Instance.GameState.get_actor(_source_actor_id, true)
var SourceAction:BaseAction:
	get:
		return MainRootNode.action_libary.get_action(_source_action_key)

var StartSpot:Vector2i
var TargetSpot:Vector2i

# Number of frames to travel 1 tile of distance
# inverted so that it stays an int and arounds rounding issues
var _frames_per_tile:int
var _start_frame:int
var _end_frame:int
var _position_per_frame:Array=[]

func _init(actor:BaseActor, action:BaseAction, missile_data:Dictionary, target, start_pos=null) -> void:
	_source_actor_id = actor.Id
	_source_action_key = action.ActionKey
	_missle_data = missile_data
	if _missle_data.has("AnimationData"):
		_missle_animation_data = AnimatedSpriteData.new(_missle_data['AnimationData'], action.LoadPath)
	
	_frames_per_tile = missile_data['FramesPerTile']
	_start_frame = CombatRootControl.Instance.QueController.sub_action_index
	# Use potition if given, otherwise start at actor position
	if start_pos and start_pos is Vector3i:
		StartSpot = Vector2i(start_pos.x, start_pos.y)
	if start_pos and start_pos is Vector2i:
		StartSpot = Vector2i(start_pos.x, start_pos.y)
	else:
		var actor_pos = CombatRootControl.Instance.GameState.MapState.get_actor_pos(actor)
		StartSpot = Vector2i(actor_pos.x, actor_pos.y)
	
	var meta_data:QueExecutionData = actor.Que.QueExecData
	var turn_data = meta_data.get_current_turn_data()
	if target is Vector2i:
		TargetSpot = target
	if target is String:
		var target_actor = CombatRootControl.Instance.GameState.get_actor(target, true)
		var spot = CombatRootControl.Instance.GameState.MapState.get_actor_pos(target_actor)
		TargetSpot = Vector2i(spot.x, spot.y)
	
	_calc_positions()

func get_missile_animation_data()->AnimatedSpriteData:
	return _missle_animation_data

func on_reach_target():
	var actor_on_spots = CombatRootControl.Instance.GameState.MapState.get_actors_at_pos(TargetSpot)
	if actor_on_spots.size() == 0:
		return
	#TODO: Multiple Actors
	var actor_on_spot:BaseActor = actor_on_spots[0]
	var tag_chain = SourceTagChain.new()
	DamageHelper.handle_damage(SourceActor, actor_on_spot, _missle_data['DamageData'], tag_chain)
		
		
func get_position_for_frame(frame:int):
	var index = frame - _start_frame
	if index < 0 or index >= _position_per_frame.size():
		return null
	return _position_per_frame[index]

func has_reached_target()->bool:
	return _end_frame == CombatRootControl.Instance.QueController.sub_action_index
	

func do_thing(_game_state:GameStateData):
	print('Missile ' + str(Id) + " has done thing.")
	
	node.on_missile_reach_target()

func _calc_positions():
	# Get distance in pixels between start and end point
	var start_pos = CombatRootControl.Instance.MapController.actor_tile_map.map_to_local(StartSpot)
	var end_pos = CombatRootControl.Instance.MapController.actor_tile_map.map_to_local(TargetSpot)
	var local_distance = start_pos.distance_to(end_pos)
	
	# Get distance in tiles between start and end 
	# diagnal movement counts as 1, so we only need greatest side
	var tile_distance = maxi(abs(TargetSpot.x - StartSpot.x), abs(TargetSpot.y - StartSpot.y))
	
	# Convert from frames_per_tile to pixels_per_frame
	var pixels_per_tile = local_distance / tile_distance
	var pixels_per_frame = pixels_per_tile / _frames_per_tile
	var frames_till_hit = tile_distance * _frames_per_tile
	_end_frame = _start_frame + frames_till_hit
	
	# Check if the missile will take more frames to reach the target then there are frames left in turn
	# If so, log an error and clap the end frame.
	if  _end_frame > BaseAction.SUB_ACTIONS_PER_ACTION:
		printerr("Missile " + str(Id) + " created by " + SourceAction.ActionKey + " would not reach target before end of turn.")
		_end_frame = BaseAction.SUB_ACTIONS_PER_ACTION - 1
		
	# Calculate position per frame upfront
	_position_per_frame.clear()
	for n in range(_start_frame, _end_frame + 1):
		var delta = n - _start_frame
		var dist = delta * pixels_per_frame
		var new_pos = start_pos.move_toward(end_pos, dist)
		_position_per_frame.append(new_pos)
		
	pass
