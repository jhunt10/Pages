class_name TargetParameters

static var SelfTargetParams:TargetParameters = TargetParameters.new(
	'Self',
	{
		"TargetType": "Self",
		"LineOfSight": false,
	}
)

enum TargetTypes {Self, FullArea, Spot, OpenSpot, Actor, Ally, Enemy, Corpse}

static var ActorTargetTypes = [TargetTypes.Actor, TargetTypes.Ally, TargetTypes.Enemy]
static var SpotTargetTypes = [TargetTypes.Spot, TargetTypes.OpenSpot]

var _target_param_key
var target_param_key:String:
	get:
		return _target_param_key
	set(val):
		_target_param_key = val
var raw_args:Dictionary
var target_type:TargetTypes
var line_of_sight:bool
var target_area:AreaMatrix
var effect_area:AreaMatrix
var include_self_in_aoe:bool
var include_allies_in_aoe:bool
var include_enemies_in_aoe:bool
var _conditions:Dictionary

var _cached_canter_pos:MapPos
var _cached_target_area:Dictionary

func apply_target_mod(mod_data:Dictionary)->TargetParameters:
	var new_args = raw_args.duplicate()
	var override_props = mod_data.get("OverrideProps", {})
	for prop_name in override_props.keys():
		new_args[prop_name] = override_props[prop_name]
	if mod_data.get("MakeOmniDirrectional"):
		var raw_area_string = new_args.get("TargetArea")
		var raw_area = JSON.parse_string(raw_area_string)
		var new_area = []
		for dir in MapPos.Directions:
			var rotated = TargetingHelper.rotate_target_area(raw_area, dir)
			for spot in rotated:
				if not new_area.has(spot):
					new_area.append(spot)
		new_args['TargetArea'] = new_area
			
	return TargetParameters.new(self.target_param_key, new_args)

func _init(target_param_key:String, args:Dictionary) -> void:
	# Assign Target Key
	self.target_param_key = target_param_key
	self.raw_args = args
	# Get Target Type
	var target_type_val = args.get('TargetType', null)
	if target_type_val is int:
		target_type = args['TargetType']
	elif target_type_val is String:
		var temp_type = TargetTypes.get(target_type_val)
		if temp_type >= 0:
			target_type = temp_type
	else: 
		printerr("TargetParameters.new: '%s' Unknown Target Type: '%s'." % [target_param_key, args.get("TargetType", "NULL")])
		target_type = TargetTypes.Self
	
	# Requires Line of Sight
	line_of_sight = args.get('LineOfSight', true)
	
	# Get Targeting Area
	target_area = AreaMatrix.new(args.get("TargetArea", [[0,0]]))
	
	if args.has('EffectArea'):
		effect_area = AreaMatrix.new(args['EffectArea'])
	else:
		effect_area = null
	
	include_self_in_aoe = args.get("IncludeSelfInAoe", true)
	include_allies_in_aoe = args.get("IncludeAlliesInAoe", true)
	include_enemies_in_aoe = args.get("IncludeEnemiesInAoe", true)
	_conditions = args.get("TargetConditions", {})

func has_area_of_effect()->bool:
	if effect_area:
		return true
	return false
	
# Returns Array of Vector2i points for Area of Effect
func get_area_of_effect(center:MapPos)->Array:
	return effect_area.to_map_spots(center)

func is_spot_target_type()->bool:
	return SpotTargetTypes.has(self.target_type)

func is_actor_target_type()->bool:
	return ActorTargetTypes.has(self.target_type)
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
	if _conditions.size() > 0:
		if _conditions.has("TagFilers"):
			if not TagHelper.check_tag_filters("TagFilters", _conditions, target):
				return false
		if _conditions.has("HealthPercentBelow"):
			var targ_cur_hp = target.stats.current_health
			var targ_max_hp = target.stats.max_health
			var targ_percent = float(targ_cur_hp) / float(targ_max_hp)
			var hp_threashold = _conditions.get("HealthPercentBelow")
			if hp_threashold < targ_percent:
				return false
	
	if target_type == TargetTypes.Actor:
		return true
	if target_type == TargetTypes.Corpse:
		return target.is_dead
	if target_type == TargetTypes.Enemy:
		return actor.FactionIndex != target.FactionIndex
	if target_type == TargetTypes.Ally:
		return actor.FactionIndex == target.FactionIndex
	if target_type == TargetTypes.Spot or target_type == TargetTypes.FullArea:
		return true
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

func get_center_of_area(actor_pos:MapPos, include_user_spot:bool=false)->MapPos:
	var spots =  target_area.to_map_spots(actor_pos)
	if include_user_spot:
		spots.append(Vector2i(actor_pos.x, actor_pos.y))
	var min_x = spots[0].x
	var max_x = spots[0].x
	var min_y = spots[0].y
	var max_y = spots[0].y
	var los_dict = {}
	for spot in spots:
		if spot.x > max_x: max_x = spot.x
		if spot.x < min_x: min_x = spot.x
		if spot.y > max_y: max_y = spot.y
		if spot.y < min_y: min_y = spot.y
	# Correct for even width area (0.5 center)
	if include_user_spot:
		var area_hight = max_y - min_y+1
		if area_hight > 2 and (area_hight)%2 == 0 :
			if actor_pos.dir == MapPos.Directions.North:
				max_y += 1
			elif actor_pos.dir == MapPos.Directions.South:
				max_y += 1
		
	return MapPos.new((max_x + min_x) / 2, (max_y + min_y) / 2, actor_pos.z, actor_pos.dir)
