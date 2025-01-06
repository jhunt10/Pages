class_name AiHandler

static var astar:AStar2D

static func build_action_que(actor:BaseActor, game_state:GameStateData)->Array:
	var enimes = get_enemy_actors(actor, game_state)
	if enimes.size() == 0:
		return []
		
	# TODO: Pick a target
	var target_enemy = enimes[0]
	
	# get possible attack ranges
	var attack_target_params = {}
	var attack_costs_data = {}
	for action:BaseAction in actor.pages.list_actions():
		if action.has_preview_target():
			attack_target_params[action.ActionKey] = action.get_preview_target_params(actor)
			attack_costs_data[action.ActionKey] = action.CostData
	
	# Find Path
	var target_pos = game_state.MapState.get_actor_pos(target_enemy)
	var start_pos = game_state.MapState.get_actor_pos(actor)
	var path = path_to_target(actor, start_pos, target_pos, game_state)
	
	
	var action_list = []
	var curr_pos = start_pos
	var path_index = 0
	var try_count = 0
	var running_costs = {}
	while try_count < 50 and action_list.size() < actor.Que.get_max_que_size():
		var attack_page = null
		for attack_name in attack_target_params.keys():
			# Remove attack as option if we can't pay it's cost
			if not can_actor_pay_cost(actor, attack_costs_data.get(attack_name, {}), running_costs):
				attack_target_params.erase(attack_name)
				continue
			var attack_params =  attack_target_params[attack_name]
			var potential_targets = TargetingHelper.get_potential_target_actor_ids(attack_params, actor, game_state, [], curr_pos) 
			if potential_targets.has(target_enemy.Id):
				attack_page = attack_name
		if attack_page:
			action_list.append(attack_page)
			# Record cost of action as payed
			for cost_key in attack_costs_data.get(attack_page, {}).keys():
				if not running_costs.has(cost_key):
					running_costs[cost_key] = 0
				running_costs[cost_key] += attack_costs_data[attack_page][cost_key]
		elif path.get("Moves", []).size() > path_index:
			action_list.append(path['Moves'][path_index])
			curr_pos = path['Poses'][path_index]
			path_index += 1
		try_count += 1
	if try_count >= action_list.size():
		printerr("Qued %s pages in %s tries" % [action_list.size(), try_count])
		
	return action_list

static func can_actor_pay_cost(actor:BaseActor, cost_data:Dictionary, running_cost:Dictionary)->bool:
	for cost_key in cost_data.keys():
		if cost_data[cost_key] + running_cost.get(cost_key, 0) > actor.stats.get_bar_stat(cost_key):
			return false
	return true

static func get_enemy_actors(actor:BaseActor, game_state:GameStateData)->Array:
	var out_list = []
	for act:BaseActor in game_state.list_actors():
		if act.FactionIndex != actor.FactionIndex:
			out_list.append(act)
	return out_list

static func try_handle_get_target_sub_action(actor:BaseActor, selection_data:TargetSelectionData, action:BaseAction, game_state:GameStateData)->bool:
	var turndata = selection_data.focused_actor.Que.QueExecData.get_current_turn_data()
	var potentail_actors = []
	var coor_to_actor = {}
	if selection_data.target_params.is_actor_target_type():
		potentail_actors = selection_data.list_potential_targets()
	else:
		var actor_pos = game_state.MapState.get_actor_pos(actor)
		for coor in selection_data.get_selectable_coords():
			var actors = game_state.MapState.get_actors_at_pos(coor)
			for act in actors:
				if not potentail_actors.has(act):
					potentail_actors.append(act)
					coor_to_actor[act.Id] = MapPos.new(coor.x, coor.y, actor_pos.z, actor_pos.dir)
	var enemy_actors = []
	for p_actor in potentail_actors:
		var pp_actor = p_actor
		if pp_actor is String:
			pp_actor = ActorLibrary.get_actor(p_actor)
		if pp_actor.FactionIndex != actor.FactionIndex:
			enemy_actors.append(pp_actor)
			
	var selected_target = null
	if enemy_actors.size() > 0:
		if selection_data.target_params.is_spot_target_type():
			turndata.add_target_for_key(selection_data.setting_target_key, 
					selection_data.target_params.target_param_key, coor_to_actor[enemy_actors[0].Id])
		elif selection_data.target_params.is_actor_target_type():
			turndata.add_target_for_key(selection_data.setting_target_key, selection_data.target_params.target_param_key, enemy_actors[0].Id)
		return true
	else:
		return false
	

static func path_to_target(actor:BaseActor, start_pos:MapPos, target_pos:MapPos, game_state:GameStateData)->Dictionary:
	#if !astar:
	var t_astar = build_path_finder(game_state)
	var start_index = _pos_to_index(start_pos, game_state)
	var end_index = _pos_to_index(target_pos, game_state)
	# Disable occupied spots 
	for actor_id in game_state.MapState._actor_pos_cache.keys():
		var check_actor = game_state.get_actor(actor_id)
		var check_pos:MapPos = game_state.MapState._actor_pos_cache[actor_id]
		if actor and actor_id == actor.Id:
			continue
		if check_pos.to_vector2i() == start_pos.to_vector2i():
			continue
		if check_pos.to_vector2i() == target_pos.to_vector2i():
			continue
		#print("Disabling Point: %s because %s " % [check_pos, check_actor.Id])
		var path_index = _pos_to_index(check_pos, game_state)
		if t_astar.has_point(path_index):
			t_astar.set_point_disabled(path_index, true)
	
	var point_path = t_astar.get_point_path(start_index, end_index, true)
	
	var move_list = []
	var pos_list = []
	var last_pos = start_pos
	for point:Vector2i in point_path:
		#print("\n------------------------------")
		#print("From %s to %s: " % [last_pos, point])
		var reses = _translate_next_point_to_movement(last_pos, point, [])
		for res in reses:
			move_list.append(res['Movement'])
			pos_list.append(res['NextPos'])
			last_pos = res['NextPos']
			#print("\t\tMovement: %s | Result: %s" % [res['Movement'], last_pos])
		
	return {"Moves": move_list, "Poses": pos_list, "Path": point_path}

static func _translate_next_point_to_movement(current_pos:MapPos, move_to:Vector2i, move_options:Array)->Array:
	var move_diff = move_to - current_pos.to_vector2i() 
	if move_diff.x != 0 and move_diff.y != 0:
		printerr("Diagnal Movement not suported: %s to %s" % [current_pos, move_to])
		return []
	if move_diff.x == 0 and move_diff.y == 0:
		return []
	var rel_dir = 0
	if move_diff.y < 0: # Moving North
		rel_dir = 0
	if move_diff.x > 0: # Moving East
		rel_dir = 1
	if move_diff.y > 0: # Moving South
		rel_dir = 2
	if move_diff.x < 0: # Moving West
		rel_dir = 3
	
	var result = []
	var dir_diff = (rel_dir - current_pos.dir + 4 ) % 4
	if dir_diff == 0: # Target in front
		result.append({"Movement": "MoveForward", "NextPos": current_pos.apply_relative_pos(MapPos.new(0,-1,0,0))})
	
	elif dir_diff == 1: # Target To Right
		var new_pos = current_pos.apply_relative_pos(MapPos.new(0,0,0,1))
		result.append({"Movement": "TurnRight", "NextPos": new_pos})
		result.append({"Movement": "MoveForward", "NextPos": new_pos.apply_relative_pos(MapPos.new(0,-1,0,0))})
	
	elif dir_diff == 2: # Target Behind
		# TODO: Don't turn back to enimes
		if move_options.has("TurnAround"):
			var new_pos = current_pos.apply_relative_pos(MapPos.new(0,0,0,2))
			result.append({"Movement": "TurnAround", "NextPos": new_pos})
			result.append({"Movement": "MoveForward", "NextPos": new_pos.apply_relative_pos(MapPos.new(0,-1,0,0))})
		elif randi() % 2 == 0: # Turn Right Twice
			var new_pos = current_pos.apply_relative_pos(MapPos.new(0,0,0,1))
			result.append({"Movement": "TurnRight", "NextPos": new_pos})
			var new_pos2 = new_pos.apply_relative_pos(MapPos.new(0,0,0,1))
			result.append({"Movement": "TurnRight", "NextPos": new_pos2})
			result.append({"Movement": "MoveForward", "NextPos": new_pos2.apply_relative_pos(MapPos.new(0,-1,0,0))})
		else: # Turn Left Twice
			var new_pos = current_pos.apply_relative_pos(MapPos.new(0,0,0,3))
			result.append({"Movement": "TurnLeft", "NextPos": new_pos})
			var new_pos2 = new_pos.apply_relative_pos(MapPos.new(0,0,0,3))
			result.append({"Movement": "TurnLeft", "NextPos": new_pos2})
			result.append({"Movement": "MoveForward", "NextPos": new_pos2.apply_relative_pos(MapPos.new(0,-1,0,0))})
	
	else: # Target to Left
		var new_pos = current_pos.apply_relative_pos(MapPos.new(0,0,0,3))
		result.append({"Movement": "TurnLeft", "NextPos": new_pos})
		result.append({"Movement": "MoveForward", "NextPos": new_pos.apply_relative_pos(MapPos.new(0,-1,0,0))})
	
	return result

static func build_path_finder(game_state:GameStateData)->AStar2D:
	var star = AStar2D.new()
	star.reserve_space(game_state.MapState.max_hight * game_state.MapState.max_width)
	for y in range(game_state.MapState.max_hight):
		#var line = ''
		#var line2 = ''
		for x in range(game_state.MapState.max_width):
			var pos = Vector2i(x, y)
			var index = _pos_to_index(pos, game_state)
			#line2 += str(pos) + ", "
			if _is_terrain_traversable(pos, game_state):
				#print("Adding Point: %s" % [pos])
				star.add_point(index, pos, 1)
				#line += "0"
				if y > 0:
					var upper_pos = Vector2i(x, y-1)
					var upper_index = _pos_to_index(upper_pos, game_state)
					if star.has_point(upper_index):
						#print("Connecing Up Points: %s | %s" % [pos, upper_pos])
						star.connect_points(index, upper_index)
				if x > 0:
					var back_pos = Vector2i(x-1, y)
					var back_index = _pos_to_index(back_pos, game_state)
					if star.has_point(back_index):
						#print("Connecing Back Points: %s | %s" % [pos, back_pos])
						star.connect_points(index, back_index)
			#else:
				#line += "X"
		#print(line)
	return star
		


static func _pos_to_index(pos, game_state)->int:
	return pos.x + (pos.y * game_state.MapState.max_width)

static func _is_terrain_traversable(pos, game_state:GameStateData)->bool:
	var terrain = game_state.MapState.get_terrain_at_pos(pos)
	return terrain > 0
