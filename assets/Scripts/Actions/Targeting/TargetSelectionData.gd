class_name TargetSelectionData

var target_params:TargetParameters
var setting_target_key:String
var focused_actor:BaseActor
var actor_pos:MapPos
var exclude_targets:Array
var _los_mapping:Dictionary
## Dictionary of potenial coors to actors in that spot
var _potential_target_dictray:Dictionary
var _potential_target_count:int

func _init(params:TargetParameters, target_key:String, actor:BaseActor, game_state:GameStateData, exclude:Array, center_override:MapPos=null) -> void:
	target_params = params
	setting_target_key = target_key
	focused_actor = actor
	if center_override:
		actor_pos = center_override
	else:
		actor_pos = game_state.get_actor_pos(focused_actor)
	exclude_targets = exclude
	_los_mapping = params.get_valid_target_area(actor_pos)
	printerr("ActorPoswe: %s" % [actor_pos.dir])
	_potential_target_dictray = TargetingHelper.get_potential_coor_to_targets(target_params, focused_actor, game_state, exclude_targets, center_override)
	_potential_target_count = TargetingHelper.dicarry_to_values(_potential_target_dictray).size()
	
func get_targeting_area_coords()->Array:
	return _los_mapping.keys()

func get_coords_los(coor:Vector2i)->TargetingHelper.LOS_VALUE:
	return _los_mapping.get(coor, TargetingHelper.LOS_VALUE.Blocked)

func is_point_in_targeting_area(coor:Vector2i):
	return target_params.is_point_in_area(actor_pos, coor)

func get_potential_target_count()->int:
	return _potential_target_count

func get_selectable_coords()->Array:
	return _potential_target_dictray.keys()

func is_coor_selectable(coor:Vector2i)->bool:
	return _potential_target_dictray.keys().has(coor)

## Returns list of Actors or MapSpots depending on Targeting Type
func list_potential_targets()->Array:
	return TargetingHelper.dicarry_to_values(_potential_target_dictray)

func get_center_of_area()->MapPos:
	return target_params.get_center_of_area(actor_pos)
