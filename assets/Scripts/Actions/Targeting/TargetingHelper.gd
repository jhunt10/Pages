class_name TargetingHelper

enum LOS_VALUE {Invalid, Blocked, Cover, Open}

## Returns all actors effected by selected target
static func get_targeted_actors(target_params:TargetParameters, targets:Array, source_actor:BaseActor, game_state:GameStateData)->Array:
	
	var area_of_effect = null
	var out_list = []
	for target in targets:
		if not (target is String or target is MapPos):
			printerr("TargetingHelper.get_targeted_actors: Provided target '%s' is neither String nor MapPos." % [target])
			return []
		
		
		# Targeting an actor
		if target_params.is_actor_target_type():
			if target is not String:
				printerr("TargetingHelper.get_targeted_actors: TargetParams exspect Actor but provided target '%s' is not String." % [target])
				return []
			var target_actor:BaseActor = game_state.get_actor(target)
			if not target_actor:
				printerr("TargetingHelper.get_targeted_actors: Failed to find target Actor with id '%s'." % [target])
				return []
			if target_params.is_valid_target_actor(source_actor, target_actor, game_state):
				if target_params.has_area_of_effect():
					area_of_effect = target_params.get_area_of_effect(game_state.MapState.get_actor_pos(target_actor))
				else:
					out_list.append(target_actor)
		
		# Targeting a spot
		if target_params.is_spot_target_type():
			if target is not MapPos:
				printerr("TargetingHelper.get_targeted_actors: TargetParams exspect Actor but provided target '%s' is not MapPos." % [target])
				return []
			if target_params.has_area_of_effect():
				area_of_effect = target_params.get_area_of_effect(target)
			else:
				for target_actor in game_state.MapState.get_actors_at_pos(target):
					if target_params.is_valid_target_actor(source_actor, target_actor, game_state) and not out_list.has(target_actor):
						out_list.append(target_actor)
		
		if target_params.target_type == TargetParameters.TargetTypes.FullArea:
			area_of_effect = target_params.target_area.to_map_spots(game_state.MapState.get_actor_pos(source_actor))
		
	
	# Area of effect
	if area_of_effect:
		for spot in area_of_effect:
			for target_actor:BaseActor in game_state.MapState.get_actors_at_pos(spot):
				if out_list.has(target_actor):
					continue
				if target_params.is_actor_effected_by_aoe(source_actor, target_actor, game_state):
					out_list.append(target_actor)
	return out_list

static func get_selectable_target_spots(target_params:TargetParameters, actor:BaseActor, game_state:GameStateData, exclude_targets:Array=[])->Array:
	var potentials = get_potential_coor_to_targets(target_params, actor, game_state, exclude_targets)
	return potentials.keys()
	
static func get_potential_target_actor_ids(target_params:TargetParameters, actor:BaseActor, game_state:GameStateData, exclude_targets:Array=[], pos_override:MapPos=null)->Array:
	var potentials = get_potential_coor_to_targets(target_params, actor, game_state, exclude_targets, pos_override)
	var targets = dicarry_to_values(potentials)
	if target_params.is_actor_target_type():
		return targets
	var actor_ids_list = []
	for target_spot in potentials.keys():
		var actors = game_state.MapState.get_actors_at_pos(target_spot)
		for act in actors:
			if not actor_ids_list.has(act.Id):
				actor_ids_list.append(act.Id)
	return actor_ids_list
	
static func is_actor_targetable(target_params:TargetParameters, source_actor:BaseActor, target_actor:BaseActor, game_state:GameStateData, pos_override:MapPos=null)->bool:
	var source_pos = pos_override
	if !source_pos:
		source_pos = game_state.MapState.get_actor_pos(source_actor)
	var target_pos = game_state.MapState.get_actor_pos(target_actor)
	return target_params.is_point_in_area(source_pos, target_pos)

## Returns a Dictionary<Vector21, Array> of spots within target_area mapped to potential targets in that spot.
static func get_potential_coor_to_targets(target_params:TargetParameters, actor:BaseActor, game_state:GameStateData, exclude_targets:Array=[], pos_override:MapPos=null)->Dictionary:
	var actor_pos = game_state.MapState.get_actor_pos(actor)
	if pos_override:
		actor_pos = pos_override
	var target_area = target_params.get_valid_target_area(actor_pos)
	var potential_targets:Dictionary = {}
	
	if target_params.target_type == TargetParameters.TargetTypes.Self:
		return {actor_pos: [actor]}
	
	if target_params.target_type == TargetParameters.TargetTypes.FullArea:
		return {actor_pos: [actor]}
	
	for spot:Vector2i in target_area.keys():
		var spot_los:LOS_VALUE = target_area[spot]
		
		if spot_los == LOS_VALUE.Blocked:
			continue
			
		if target_params.is_actor_target_type():
			for target:BaseActor in game_state.MapState.get_actors_at_pos(spot, null, true):
				if (target_params.target_type == TargetParameters.TargetTypes.Enemy and
						actor.FactionIndex == target.FactionIndex):
							continue
				if (target_params.target_type == TargetParameters.TargetTypes.Ally and
						actor.FactionIndex != target.FactionIndex):
							continue
				if target.is_dead and not (target_params.target_type == TargetParameters.TargetTypes.Corpse):
							continue
				if target_params.target_type == TargetParameters.TargetTypes.Corpse and not target.is_dead:
							continue
				if target_params.is_valid_target_actor(actor, target, game_state):
					if not potential_targets.has(target.Id) and not exclude_targets.has(target.Id):
						add_to_dicarry(potential_targets, spot, target.Id)
		
		if target_params.is_spot_target_type():
			var target = MapPos.new(spot.x, spot.y, actor_pos.z, actor_pos.dir)
			if target_params.target_type == TargetParameters.TargetTypes.Spot:
				if not potential_targets.has(target) and not exclude_targets.has(target):
					add_to_dicarry(potential_targets, spot, target)
			if target_params.target_type == TargetParameters.TargetTypes.OpenSpot:
				if game_state.MapState.is_spot_open(target):
					if not potential_targets.has(target) and not exclude_targets.has(target):
						add_to_dicarry(potential_targets, spot, target)
	return potential_targets

static func add_to_dicarry(dict, key, value):
	if !dict.keys().has(key):
		dict[key] = []
	if not dict[key].has(value):
		dict[key].append(value)
		
static func dicarry_to_values(dict:Dictionary)->Array:
	var out_list = []
	for arr in dict.values():
		for val in arr:
			if not out_list.has(val):
				out_list.append(val)
	return out_list

static func trace_los(from_point, to_point, _map_state):
	var los_dict = {}
	var line = safe_calc_line(from_point, to_point,  false, false, true)
	for point in line:
		los_dict[point] = LOS_VALUE.Open
	return los_dict

static func get_line_of_sight_for_spots(from_point, to_point, map:MapStateData, check_cache:Dictionary = {}, log=false)->LOS_VALUE:
	var in_line_is_unbroken = true
	var out_line_is_unbroken = true
	if log: print("#### LOS CHECK")
	if log: print("# From: %s | To: %s" % [from_point, to_point])
	
	if map.get_map_spot(to_point) == null or map.spot_blocks_los(to_point):
		check_cache[to_point] = LOS_VALUE.Invalid
		return check_cache[to_point]
	
	var path = safe_calc_line(from_point, to_point, false, true, false)
	if log: print("# Path: %s" % [path])
	for p in path:
		if in_line_is_unbroken and _spot_blocks_los(p, check_cache, map):
			in_line_is_unbroken = false
	
	path = safe_calc_line(from_point, to_point, true, false, true)
	if log: print("# Path: %s" % [path])
	for p in path:
		if out_line_is_unbroken and _spot_blocks_los(p, check_cache, map):
			out_line_is_unbroken = false
	
	if in_line_is_unbroken:
		check_cache[to_point] = LOS_VALUE.Open
	elif out_line_is_unbroken:
		check_cache[to_point] = LOS_VALUE.Cover
	else:
		check_cache[to_point] = LOS_VALUE.Blocked
	#if log: print("# OutLine %s: %s" % [p, out_line_is_unbroken])
	return check_cache[to_point]

static func _spot_blocks_los(spot:Vector2i, check_cache:Dictionary, map:MapStateData):
	return map.spot_blocks_los(MapPos.Vector2i(spot))
	
# Calculate path as if m is positive and < 1. Then rotate and mirror as needed
# Rounding down will give a more generious results "leaning out" on corners
static func safe_calc_line(start, end, round_down=false, fill_back:bool=false, fill_down:bool=false)->Array:
	var out_line = []
	
	# Vertical line case (m = inf)
	if start.x == end.x:
		for y in range(min(start.y, end.y), max(start.y, end.y) + 1):
			var check_vec = Vector2i(start.x, y)
			out_line.append(check_vec)
		return out_line
	
	var x_change = abs(start.x - end.x)
	var y_change = abs(start.y - end.y)
	
	var min_point = Vector2i(0, 0)
	var max_point = Vector2i(max(x_change, y_change), min(x_change, y_change))
	
	# Is line being mirrored over Y Axis
	var is_x_mirrored = start.x > end.x
	# Is line being mirrored over Y Axis
	var is_y_mirrored = start.y > end.y
	# Is line being flipped over itself
	var is_inverted = x_change < y_change
	if is_inverted:
		is_y_mirrored = start.x > end.x
		is_x_mirrored = start.y > end.y
		#var temp_fill = fill_back
		#fill_back = fill_down
		#fill_down = temp_fill
		
	
	var check_line = []
	var last_x = min_point.x
	var last_y = min_point.y
	var m:float = float(max_point.y - min_point.y) / float(max_point.x - min_point.x)
	for check_x in range(min_point.x, max_point.x+1):
		var check_y = 0
		if round_down: check_y = floori(m * float(check_x))
		else: check_y = round(m * float(check_x))
		if check_y != last_y:
			if fill_back:
				check_line.append(Vector2i(check_x-1, check_y))
			if fill_down:
				check_line.append(Vector2i(check_x, check_y-1))
		check_line.append(Vector2i(check_x, check_y))
		last_y = check_y
		
	for check_point in check_line:
		var base_x = start.x
		var base_y = start.y
		if is_inverted:
			base_x = start.y
			base_y = start.x
		var res_x = 0
		var res_y = 0
		if is_x_mirrored: 
			res_x = base_x - check_point.x
		else: 
			res_x = base_x + check_point.x
		if is_y_mirrored: 
			res_y = base_y - check_point.y
		else: 
			res_y = base_y + check_point.y
		if is_inverted:
			out_line.append(Vector2i(res_y, res_x))
		else:
			out_line.append(Vector2i(res_x, res_y))
	#print("Inverted: %s | Xmirror: %s | YMirror: %s" % [is_inverted, is_y_mirrored, is_x_mirrored])
	
	return out_line
	
static func round(val:float)->int:
	var floor:int = floori(val)
	if val - float(floor) > 0.5:
		return floor + 1
	return floor
