class_name TargetParameters

static var SelfTargetParams:TargetParameters = TargetParameters.new(
	'Self',
	{
		"TargetType": "Self",
		"LineOfSight": false,
	}
)

enum TargetTypes {Self, FullArea, Spot, OpenSpot, Actor, Ally, Enemy, Corpse}

var target_param_key:String
var target_type:TargetTypes
var line_of_sight:bool
var target_area:AreaMatrix
var effect_area:AreaMatrix
var include_self_in_aoe:bool
var include_allies_in_aoe:bool
var include_enemies_in_aoe:bool

var _cached_canter_pos:MapPos
var _cached_target_area:Dictionary

func _init(target_param_key:String, args:Dictionary) -> void:
	# Assign Target Key
	self.target_param_key = target_param_key
	
	# Get Target Type
	var target_type_val = args.get('TargetType', null)
	if target_type_val is int:
		target_type = args['TargetType']
	elif target_type_val is String:
		var temp_type = TargetTypes.get(target_type_val)
		if temp_type >= 0:
			target_type = temp_type
	else: 
		printerr("Unknown Target Type: " + args.get("TargetType", "NULL"))
		target_type = TargetTypes.Self
	
	# Requires Line of Sight
	line_of_sight = args.get('LineOfSight', true)
	
	# Get Targeting Area
	target_area = AreaMatrix.new(args.get("TargetArea", [[0,0]]))
	
	if args.has('EffectArea'):
		effect_area = AreaMatrix.new(args['EffectArea'])
	else:
		effect_area = null
	
	include_self_in_aoe = args.get("IncludeSelfInAoe", false)
	include_allies_in_aoe = args.get("IncludeAlliesInAoe", false)
	include_enemies_in_aoe = args.get("IncludeEnemiesInAoe", false)

func has_area_of_effect()->bool:
	if effect_area:
		return true
	return false

func get_area_of_effect(center:MapPos):
	return effect_area.to_map_spots(center)

func is_spot_target_type()->bool:
	return (self.target_type == TargetTypes.Spot or 
			self.target_type == TargetTypes.OpenSpot)

func is_actor_target_type()->bool:
	return (self.target_type == TargetTypes.Actor or 
			self.target_type == TargetTypes.Ally or 
			self.target_type == TargetTypes.Enemy or 
			self.target_type == TargetTypes.Corpse)

func is_point_in_area(center:MapPos, point)->bool:
	if point is Vector2i:
		return target_area.to_map_spots(center).has(point)
	return target_area.to_map_spots(center).has(Vector2i(point.x, point.y))

## Returns true if target actor is valid as a selected target
func is_valid_target_actor(actor:BaseActor, target:BaseActor, game_state:GameStateData)->bool:
	if target_type == TargetTypes.Actor:
		return true
	if target_type == TargetTypes.Enemy:
		return actor.FactionIndex != target.FactionIndex
	if target_type == TargetTypes.Ally:
		return actor.FactionIndex == target.FactionIndex
	return false

func is_actor_effected_by_aoe(actor:BaseActor, target:BaseActor, game_state:GameStateData)->bool:
	if target.Id == actor.Id:
		return include_self_in_aoe
	if actor.FactionIndex == target.FactionIndex:
		return include_allies_in_aoe
	if actor.FactionIndex != target.FactionIndex:
		return include_enemies_in_aoe 
	return false

## Returns Dictionary of Coor mapped to LOS_VAL
func get_valid_target_area(center:MapPos)->Dictionary:
	if _cached_canter_pos == center:
		return _cached_target_area
		
	var spots =  target_area.to_map_spots(center)
	var los_dict = {}
	for spot in spots:
		if line_of_sight:
			TargetingHelper.get_line_of_sight_for_spots(center, spot, CombatRootControl.Instance.GameState, los_dict)
		else:
			los_dict[spot] = TargetingHelper.LOS_VALUE.Open
	_cached_canter_pos = center
	_cached_target_area = los_dict
	return los_dict
	
