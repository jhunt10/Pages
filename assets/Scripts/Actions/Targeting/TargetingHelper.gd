class_name TargetingHelper

enum LOS_VALUE {Invalid, Blocked, Cover, Open}


## Returns list of reasonable targets for auto targeting
static func get_auto_targets_for_page(selection_data:TargetSelectionData, parent_action:PageItemAction, source_actor:BaseActor)->Array:
	# TODO: Spot target type
	if not selection_data.target_params.is_actor_target_type():
		return selection_data.list_potential_targets()
	
	var all_actors = []
	for actor_id in selection_data.list_potential_targets():
		var actor = ActorLibrary.get_actor(actor_id)
		if actor:
			all_actors.append(actor)
	
	# For Attacks, consider Preview Damage
	if parent_action.get_tags().has("Attack"):
		var damage_datas = parent_action.get_preview_damage_datas(source_actor)
		if damage_datas.size() == 0:
			printerr("TargetHelper.get_auto_targets_for_page: No Preview DamageData found on Attack Page '%s'." %[parent_action.ActionKey])
		else:
			# Enemies who will be hurt OR Allies who will be healed
			var reasonable_targets = []
			for other_actor:BaseActor in all_actors:
				# TODO: Does not account for attack mods like "Harming Light"
				var will_hurt = false
				for damage_data in damage_datas.values():
					var damage_type = damage_data.get("DamageType")
					if other_actor.stats.get_damage_resistance(damage_type) < 100:
						will_hurt = true
				var is_ally = other_actor.TeamIndex == source_actor.TeamIndex
				#if (will_hurt and not is_ally) or (not will_hurt and is_ally):
				if will_hurt != is_ally:
					reasonable_targets.append(other_actor)
			return reasonable_targets
	
	var allies = []
	var enemies = []
	for other_actor:BaseActor in all_actors:
		if other_actor.TeamIndex == source_actor.TeamIndex:
			allies.append(other_actor)
		else:
			enemies.append(other_actor)
	
	# Assume actor's don't want to be targeted
	var is_bad = true
	# TODO: Logic?
	
	if is_bad:
		return enemies
	else:
		return allies
	

## Returns all actors effected by selected target
static func get_targeted_actors(target_params:TargetParameters, targets:Array, source_actor:BaseActor, game_state:GameStateData, ignore_aoe:bool=false)->Array:
	
	var area_of_effect = null
	var out_list = []
	for target in targets:
		if not (target is String or target is MapPos):
			printerr("TargetingHelper.get_targeted_actors: Provided target '%s' is neither String nor MapPos." % [target])
			continue
		
		
		# Targeting an actor
		if target_params.is_actor_target_type():
			if target is not String:
				printerr("TargetingHelper.get_targeted_actors: TargetParams exspect Actor but provided target '%s' is not String." % [target])
				continue
			var target_actor:BaseActor = game_state.get_actor(target, target_params.target_type == TargetParameters.TargetTypes.Corpse)
			if not target_actor:
				printerr("TargetingHelper.get_targeted_actors: Failed to find target Actor with id '%s'." % [target])
				continue
			if target_params.is_valid_target_actor(source_actor, target_actor, game_state):
				if target_params.has_area_of_effect() and not ignore_aoe:
					area_of_effect = target_params.get_area_of_effect(game_state.get_actor_pos(target_actor))
				else:
					out_list.append(target_actor)
		
		# Targeting a spot
		if target_params.is_spot_target_type():
			if target is not MapPos:
				printerr("TargetingHelper.get_targeted_actors: TargetParams exspect Actor but provided target '%s' is not MapPos." % [target])
				continue
			if target_params.has_area_of_effect() and not ignore_aoe:
				area_of_effect = target_params.get_area_of_effect(target)
			else:
				for target_actor in game_state.get_actors_at_pos(target):
					if target_params.is_valid_target_actor(source_actor, target_actor, game_state) and not out_list.has(target_actor):
						out_list.append(target_actor)
		
		if target_params.target_type == TargetParameters.TargetTypes.FullArea:
			area_of_effect = target_params.target_area.to_map_spots(game_state.get_actor_pos(source_actor))
		
	
	# Area of effect
	if area_of_effect:
		for spot in area_of_effect:
			for target_actor:BaseActor in game_state.get_actors_at_pos(spot):
				if out_list.has(target_actor):
					continue
				if target_params.is_actor_effected_by_aoe(source_actor, target_actor, game_state):
					out_list.append(target_actor)
	return out_list
#
#static func get_selectable_target_spots(target_params:TargetParameters, actor:BaseActor, game_state:GameStateData, exclude_targets:Array=[])->Array:
	#var potentials = get_potential_coor_to_targets(target_params, actor, game_state, exclude_targets)
	#return potentials.keys()
	#


static func get_potential_target_actor_ids(target_params:TargetParameters, actor:BaseActor, game_state:GameStateData, exclude_targets:Array=[], pos_override:MapPos=null)->Array:
	var potentials = get_potential_coor_to_targets(target_params, actor, game_state, exclude_targets, pos_override)
	var targets = dicarry_to_values(potentials)
	if target_params.is_actor_target_type():
		return targets
	var actor_ids_list = []
	for target_spot in potentials.keys():
		var actors = game_state.get_actors_at_pos(target_spot)
		for act in actors:
			if not actor_ids_list.has(act.Id):
				actor_ids_list.append(act.Id)
	return actor_ids_list
	
#static func is_actor_targetable(target_params:TargetParameters, source_actor:BaseActor, target_actor:BaseActor, game_state:GameStateData, pos_override:MapPos=null)->bool:
	#var source_pos = pos_override
	#if !source_pos:
		#source_pos = game_state.get_actor_pos(source_actor)
	#var target_pos = game_state.get_actor_pos(target_actor)
	#return target_params.is_point_in_area(source_pos, target_pos)

## Returns a Dictionary<Vector21, Array> of spots within target_area mapped to potential targets in that spot.
static func get_potential_coor_to_targets(target_params:TargetParameters, actor:BaseActor, game_state:GameStateData, exclude_targets:Array=[], pos_override:MapPos=null)->Dictionary:
	var actor_pos = game_state.get_actor_pos(actor)
	if pos_override:
		actor_pos = pos_override
	var target_area = target_params.get_valid_target_area(actor_pos)
	var potential_targets:Dictionary = {}
	
	if target_params.target_type == TargetParameters.TargetTypes.Self:
		return {actor_pos: [actor]}
	
	if target_params.target_type == TargetParameters.TargetTypes.FullArea:
		return {actor_pos: [actor]}
	
	#if target_params.target_type == TargetParameters.TargetTypes.Corpse:
		
		
	
	for spot:Vector2i in target_area.keys():
		var spot_los:LOS_VALUE = target_area[spot]
		
		if spot_los == LOS_VALUE.Blocked:
			continue
		
		var include_dead_actors = target_params.target_type == TargetParameters.TargetTypes.Corpse
		if target_params.is_actor_target_type():
			var actors_in_spot:Array = game_state.get_actors_at_pos(spot, include_dead_actors)
			for target:BaseActor in actors_in_spot:
				#if (target_params.target_type == TargetParameters.TargetTypes.Enemy and
						#actor.TeamIndex == target.TeamIndex):
							#continue
				#if (target_params.target_type == TargetParameters.TargetTypes.Ally and
						#actor.TeamIndex != target.TeamIndex):
							#continue
				#if target.is_dead and not (target_params.target_type == TargetParameters.TargetTypes.Corpse):
							#continue
				#if (target_params.target_type == TargetParameters.TargetTypes.Corpse 
					## Cprse Target must dead and in open spot 
					#and not (target.is_dead or actors_in_spot.size() >= 1)):
							#continue
				if target_params.is_valid_target_actor(actor, target, game_state):
					if not potential_targets.has(target.Id) and not exclude_targets.has(target.Id):
						_add_to_dicarry(potential_targets, spot, target.Id)
		
		if target_params.is_spot_target_type():
			var target = MapPos.new(spot.x, spot.y, actor_pos.z, actor_pos.dir)
			if target_params.target_type == TargetParameters.TargetTypes.Spot:
				if not potential_targets.has(target) and not exclude_targets.has(target):
					_add_to_dicarry(potential_targets, spot, target)
			if target_params.target_type == TargetParameters.TargetTypes.OpenSpot:
				if game_state.is_spot_open(target):
					if not potential_targets.has(target) and not exclude_targets.has(target):
						_add_to_dicarry(potential_targets, spot, target)
	return potential_targets

static func _add_to_dicarry(dict, key, value):
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

static func get_line_of_sight_for_spots(from_point, to_point, game_state:GameStateData, check_cache:Dictionary = {}, logging=false)->LOS_VALUE:
	var in_line_is_unbroken = true
	var out_line_is_unbroken = true
	if logging: print("#### LOS CHECK")
	if logging: print("# From: %s | To: %s" % [from_point, to_point])
	
	if game_state.spot_blocks_los(to_point):
		check_cache[to_point] = LOS_VALUE.Invalid
		return check_cache[to_point]
	
	var path = safe_calc_line(from_point, to_point, false, true, false)
	if logging: print("# Path: %s" % [path])
	for p in path:
		if in_line_is_unbroken and game_state.spot_blocks_los(p):# _spot_blocks_los(p, check_cache, map):
			in_line_is_unbroken = false
	
	path = safe_calc_line(from_point, to_point, true, false, true)
	if logging: print("# Path: %s" % [path])
	for p in path:
		if out_line_is_unbroken and game_state.spot_blocks_los(p):#  _spot_blocks_los(p, check_cache, map):
			out_line_is_unbroken = false
	
	if in_line_is_unbroken:
		check_cache[to_point] = LOS_VALUE.Open
	elif out_line_is_unbroken:
		check_cache[to_point] = LOS_VALUE.Cover
	else:
		check_cache[to_point] = LOS_VALUE.Blocked
	#if logging: print("# OutLine %s: %s" % [p, out_line_is_unbroken])
	return check_cache[to_point]
	
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
	var _last_x = min_point.x
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
	var floor_val:int = floori(val)
	if val - float(floor_val) > 0.5:
		return floor_val + 1
	return floor_val

static func rotate_target_area(area, direction)->Array:
	if area is String:
		area = JSON.parse_string(area)
	
	if MapPos.Directions.has(direction):
		direction = MapPos.Directions.keys().find(direction)
	
	if not area is Array:
		printerr("TargetHelper.rotate_target_area: Invalid area '%s'." %[area])
		return [[0,0]]
	var out_arr = []
	for spot in area:
		if not spot is Array:
			printerr("TargetHelper.rotate_target_area: Invalid spot '%s' in area '%s'." %[spot, area])
			return [[0,0]]
		var new_pos = [spot[0], spot[1]]
		match direction:
			0: # North
				new_pos = [spot[0], spot[1]]
			1: # East
				new_pos = [-spot[1], spot[0]]
			2: # South
				new_pos = [-spot[0], -spot[1]]
			3: # West
				new_pos = [spot[1], -spot[0]]
		if not out_arr.has(new_pos):
			out_arr.append(new_pos)
	return out_arr
		
	
