class_name BaseMissile

const LOGGING = false

var Id : String = str(ResourceUID.create_id())
var _load_path:String
func get_tagable_id(): return Id
func get_tags(): return _missle_data.get('Tags', [])

var node#:MissileNode
var _source_actor_id:String
var _source_target_chain:SourceTagChain
var _missle_data:Dictionary
var StartSpot:Vector2i
var TargetSpot:Vector2i
var _lob_path:bool = false
# Number of frames to travel 1 tile of distance
# inverted so that it stays an int and arounds rounding issues
var _frames_per_tile:int
var _start_frame:int
var _end_frame:int
var _position_per_frame:Array=[]

var _frames_since_creation:int = 0
var _real_velocity:float = 1

func _init(source_actor:BaseActor, missile_data:Dictionary, source_tag_chain:SourceTagChain, 
			start_pos:MapPos, target_pos:MapPos, load_path:String) -> void:
	_source_actor_id = source_actor.Id
	_load_path = load_path
	_missle_data = missile_data
	_lob_path = missile_data.get("UseLobPath", false)
	
	_frames_per_tile = missile_data.get('FramesPerTile', 1)
	_start_frame = CombatRootControl.Instance.QueController.sub_action_index
	
	CombatRootControl.Instance.QueController.end_of_frame.connect(_on_frame_end)
	# Use potition if given, otherwise start at actor position
	StartSpot = start_pos.to_vector2i()
	TargetSpot = target_pos.to_vector2i()
	_calc_positions()
	_source_target_chain = source_tag_chain.append_source(SourceTagChain.SourceTypes.Missile, self)

func get_source_actor()->BaseActor:
	return ActorLibrary.get_actor(_source_actor_id)

func get_missile_vfx_data()->Dictionary:
	var vfx_key = _missle_data.get("MissileVfxKey", '')
	var vfx_data = _missle_data.get("MissileVfxData", {})
	var data = VfxLibrary.get_vfx_def(vfx_key, vfx_data, null, _load_path)
	return data

func has_impact_vfx()->bool:
	if _missle_data.get("ImpactVfxKey", "") != "":
		return  true
	if _missle_data.get("ImpactVfxData", {}).size() > 0:
		return true
	return false
	
func get_impact_vfx_data()->Dictionary:
	var vfx_key = _missle_data.get("ImpactVfxKey", '')
	var vfx_data = _missle_data.get("ImpactVfxData", {})
	var data = VfxLibrary.get_vfx_def(vfx_key, vfx_data, null, _load_path)
	return data


func _on_frame_end():
	_frames_since_creation += 1

func get_position_for_frame(frame:int):
	var index = frame - _start_frame
	if index < 0 or index >= _position_per_frame.size():
		return null
	return _position_per_frame[index]

func get_current_moveto_position():
	var cur_frame = min(_position_per_frame.size()-1, _frames_since_creation-1)
	return _position_per_frame[cur_frame]
	

func get_final_position():
	if _position_per_frame.size() == 0:
		return Vector2i.ZERO
	return _position_per_frame[_position_per_frame.size()-1]

func has_reached_target()->bool:
	return _end_frame == CombatRootControl.Instance.QueController.sub_action_index

func execute_on_reach_target(game_state:GameStateData):
	_do_missile_thing(game_state)
	node.on_missile_reach_target()

func _do_missile_thing(_game_state:GameStateData):
	pass

func _calc_positions():
	# Get distance in pixels between start and end point
	var start_pos = CombatRootControl.Instance.MapController.actor_tile_map.map_to_local(StartSpot)
	var end_pos = CombatRootControl.Instance.MapController.actor_tile_map.map_to_local(TargetSpot)
	var pixel_distance = start_pos.distance_to(end_pos)
	
	# Get distance in tiles between start and end 
	# diagnal movement counts as 1, so we only need greatest side
	var tile_distance = maxi(abs(TargetSpot.x - StartSpot.x), abs(TargetSpot.y - StartSpot.y))
	
	# Convert from frames_per_tile to pixels_per_frame
	var pixels_per_tile = pixel_distance / tile_distance
	var pixels_per_frame = pixels_per_tile / _frames_per_tile
	var frames_till_hit = tile_distance * _frames_per_tile
	_end_frame = _start_frame + frames_till_hit
	
	# Check if the missile will take more frames to reach the target then there are frames left in turn
	# If so, log an error and clap the end frame.
	if  _end_frame >= PageItemAction.SUB_ACTIONS_PER_ACTION:
		_end_frame = PageItemAction.SUB_ACTIONS_PER_ACTION - 1
		frames_till_hit = _end_frame - _start_frame
		pixels_per_frame = pixel_distance / frames_till_hit
	
	_real_velocity = pixel_distance / float(frames_till_hit * CombatRootControl.Instance.QueController.scaled_sub_action_frame_time)
	
	# Calculate position per frame upfront
	_position_per_frame.clear()
	for n in range(_start_frame, _end_frame + 1):
		var delta = n - _start_frame
		var dist = delta * pixels_per_frame
		var new_pos = start_pos.move_toward(end_pos, dist)
		if _lob_path:
			var relative_dist = (n - _start_frame) * pixels_per_frame
			var lob_y_offset = relative_dist - ((relative_dist*relative_dist)/ pixel_distance)
			new_pos.y -= lob_y_offset
		_position_per_frame.append(new_pos)
		
	pass
