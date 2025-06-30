class_name AiHandler

const LOGGING:bool = true

static var astar:CustAStar
## Dictionary ActorKey to action_options_data
static var cached_move_sets:Dictionary={}

static func build_action_ques(clear_existing_ques:bool=false):
	var init_game_state = CombatRootControl.Instance.GameState.duplicate()
	var turn_states = []
	var actors = CombatRootControl.Instance.QueController.list_actors_by_order()
	var turn_count = CombatRootControl.Instance.QueController.max_que_size
	
	if not astar:
		astar = build_path_finder(init_game_state)
	astar.enable_all_points()
	
	# Pre-Pass on Actors
	for actor:BaseActor in actors:
		# Clear Ques
		if clear_existing_ques and not actor.is_player:
			actor.Que.clear_que()
		
		if actor.ai_def.has("PrebuiltQueArr"):
			var action_keys_que = actor.ai_def['PrebuiltQueArr']
			for action_key in action_keys_que:
				var action = ItemLibrary.get_item(action_key)
				actor.Que.que_action(action)
		
		# Disable positions
		var pos = init_game_state.get_actor_pos(actor)
		if pos:
			astar.set_pos_disabled(pos, true)
	
	for turn in range(turn_count):
		var turn_state = init_game_state
		turn_states.append(turn_state)
		turn_state.current_turn_index = turn
		for actor:BaseActor in actors:
			if actor.Que.is_turn_gap(turn):
				continue
			
			var current_pos = turn_state.get_actor_pos(actor)
			# Enable current Actor's Position for Pathing
			astar.set_pos_disabled(current_pos, false)
			
			var action = _choose_page_for_actor(actor, turn_state)
			if action == null:
				printerr("AiHandler: No Action found for '%s' on turn %s." % [actor.Id, turn])
				continue
			actor.Que.que_action(action)
			
			# Re-Disnable current Actor's Position for Pathing
			astar.set_pos_disabled(current_pos, true)
			
			if action.has_preview_move_offset():
				MoveHandler.handle_movement(turn_state, actor, action.get_preview_move_offset(), "", true)
				var new_pos = turn_state.get_actor_pos(actor)
				if new_pos != current_pos:
					astar.set_pos_disabled(current_pos, false)
					astar.set_pos_disabled(new_pos, true)
		#last_turn_state = turn_state
		#if LOGGING: print("Turn: %s" % [turn])
		#for actor in actors:
			#if LOGGING: print("\t\t %s | %s" % [actor.Id, turn_state.get_actor_pos(actor)] )
	pass

static func _choose_page_for_actor(actor:BaseActor, game_state:GameStateData)->PageItemAction:
	var current_action = actor.Que.get_action_for_turn(game_state.current_turn_index)
	if current_action:
		return current_action
	
	var aggroed_actor_id = actor.aggro.get_current_aggroed_actor_id()
	var current_pos = game_state.get_actor_pos(actor)
	var options = _get_actor_action_options_data(actor)
	var attack_actions = []
	for attack_key in options['Attacks']:
		var attack_action = ActionLibrary.get_action(attack_key)
		# Get potential targets for attack Action
		var attack_params =  attack_action.get_preview_target_params(actor)
		var potential_targets = TargetingHelper.get_potential_target_actor_ids(attack_params, actor, game_state, [], current_pos) 
		if potential_targets.size() == 0:
			continue
		var attack_has_enemy_target = false
		var aggroed_actor_in_target = false
		# Validate that targets are not allies
		for pot_targ in potential_targets:
			if pot_targ == aggroed_actor_id:
				aggroed_actor_in_target = true
			var pot_actor = game_state.get_actor(pot_targ)
			if pot_actor.FactionIndex != actor.FactionIndex:
				attack_has_enemy_target = true
		if not attack_has_enemy_target:
			continue
		if aggroed_actor_id != '' and not aggroed_actor_in_target:
			continue
		#TODO: Attack Weights
		return attack_action
	if actor.Id.begins_with("Player"):
		var temp = true
	# Get target
	var target_enemy = null
	if aggroed_actor_id == '' or actor.aggro.get_threat_from_actor(aggroed_actor_id) == 0:
		target_enemy = get_closest_enemy(actor, game_state)
		if target_enemy:
			actor.aggro.add_threat_from_actor(target_enemy, 0)
	else:
		target_enemy = game_state.get_actor(aggroed_actor_id)
	
	if not target_enemy:
		printerr("No enemies found for actor: %s" % [actor.Id])
		return null
	# Path to target
	var target_pos = game_state.get_actor_pos(target_enemy)
	var start_pos = game_state.get_actor_pos(actor)
	var path = path_to_target(actor, start_pos, target_pos, game_state)
	var path_moves = path.get('Moves', [])
	if path_moves.size() > 0:
		var move_action = ActionLibrary.get_action(path_moves[0])
		if move_action:
			return move_action
	else:
		printerr("No Path found for actor: %s" % [actor.Id])
	
	var wait_action = ItemLibrary.get_item("Wait")
	return wait_action
	
	pass

static func _get_actor_action_options_data(actor:BaseActor)->Dictionary:
	var data = {
		"Moves":[],
		"Attacks":[]
	}
	#if cached_move_sets.has(actor.ActorKey):
		#return cached_move_sets[actor.ActorKey]
	var action_list = actor.get_action_key_list()
	for action_key in action_list:
		var action = ActionLibrary.get_action(action_key)
		if not action:
			continue
		if action.has_ammo(actor):
			if not actor.Que.can_pay_page_ammo(action_key):
				continue
		if action.has_preview_move_offset():
			data['Moves'].append(action_key)
		if action.is_attack(actor):
			data['Attacks'].append(action_key)
	cached_move_sets[actor.ActorKey] = data
	return data


static func get_closest_enemy(actor:BaseActor, game_state:GameStateData)->BaseActor:
	if actor.Id.begins_with("Player"):
		var temp = true
	var actor_pos = game_state.get_actor_pos(actor)
	var min_dist = 10000
	var closest_actor = null
	for enemy:BaseActor in game_state.list_actors():
		if enemy.FactionIndex == actor.FactionIndex:
			continue
		var enemy_pos = game_state.get_actor_pos(enemy)
		#var path = path_to_target(actor, actor_pos, enemy_pos, game_state)
		#var dist = path.get('Moves', []).size()
		var dist = abs(actor_pos.x - enemy_pos.x) + abs(actor_pos.y - enemy_pos.y)
		if dist < min_dist:
			min_dist = dist
			closest_actor = enemy
	return closest_actor

static func get_damage_data_of_action(action:PageItemAction, actor:BaseActor)->Dictionary:
	var damage_data = action.DamageDatas
	if damage_data.size() > 0:
		return damage_data
	var preview_damage_data_key = action.get_preview_damage_datas(actor)
	return {}
		

static func try_handle_get_target_sub_action(actor:BaseActor, selection_data:TargetSelectionData, action:PageItemAction, game_state:GameStateData)->bool:
	var turndata = selection_data.focused_actor.Que.QueExecData.get_current_turn_data()
	var potentail_actors = []
	var coor_to_actor = {}
	if selection_data.target_params.is_actor_target_type():
		potentail_actors = selection_data.list_potential_targets()
	else:
		var actor_pos = game_state.get_actor_pos(actor)
		for coor in selection_data.get_selectable_coords():
			var actors = game_state.get_actors_at_pos(coor)
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
	# TODO: Be smart about AOE
	var targeted_enemy_id = pick_between_enemies(actor, enemy_actors)
	if targeted_enemy_id == '':
		return false
	elif selection_data.target_params.is_spot_target_type():
		turndata.add_target_for_key(
			selection_data.setting_target_key, 
			selection_data.target_params.target_param_key, 
			coor_to_actor[targeted_enemy_id])
	elif selection_data.target_params.is_actor_target_type():
		turndata.add_target_for_key(
			selection_data.setting_target_key, 
			selection_data.target_params.target_param_key, 
			targeted_enemy_id)
	return true

# Take a list of enemy Actors and return Id of best choice to atttack
static func pick_between_enemies(actor:BaseActor, enemies:Array)->String:
	if enemies.size() == 0:
		return ''
	var aggroed_enemy_id = actor.aggro.get_current_aggroed_actor_id()
	var threat_weights = {}
	var total_threat = 0
	for enemy:BaseActor in enemies:
		if enemy.Id == aggroed_enemy_id:
			return enemy.Id
		var threat = actor.aggro.get_threat_from_actor(enemy.Id)
		threat_weights[enemy.Id] = threat
		total_threat += threat
	var roll = randf_range(0, total_threat-1)
	for key in threat_weights.keys():
		roll -= threat_weights[key]
		if roll < 0:
			return key
	printerr("AiHandler.pick_between_enemies: Roll did not return value")
	return ''

static func path_to_target(actor:BaseActor, start_pos:MapPos, target_pos:MapPos, game_state:GameStateData)->Dictionary:
	if !astar:
		printerr("AStart not built")
		return {}
	#var t_astar = build_path_finder(game_state)
	var start_index = _pos_to_index(start_pos)
	var end_index = _pos_to_index(target_pos)
	if not astar.has_point(start_index):
		printerr("Path Map does not have Starting Point: %s | %s" % [start_index, start_pos])
		return {}
	if not astar.has_point(end_index):
		printerr("Path Map does not have End Point: %s | %s" % [end_index, start_pos])
		return {}
	## Disable occupied spots 
	#for check_actor in game_state.list_actors(false):
		#if not check_actor or check_actor.is_dead:
			#continue
		#var check_pos:MapPos = game_state.get_actor_pos(check_actor)
		#if actor and check_actor.Id == actor.Id:
			#continue
		#if check_pos.to_vector2i() == start_pos.to_vector2i():
			#continue
		#if check_pos.to_vector2i() == target_pos.to_vector2i():
			#continue
		##if LOGGING: print("Disabling Point: %s because %s " % [check_pos, check_actor.Id])
		#var path_index = _pos_to_index(check_pos, game_state)
		#if astar.has_point(path_index):
			#astar.set_point_disabled(path_index, true)
	var start_was_disabled = false
	if astar.is_point_disabled(start_index):
		start_was_disabled = true
		astar.set_pos_disabled(start_pos, false)
	var end_was_disabled = false
	if astar.is_point_disabled(end_index):
		end_was_disabled = true
		astar.set_pos_disabled(target_pos, false)
	
	var point_path = astar.get_point_path(start_index, end_index, true)
	if point_path.size() == 0:
		printerr("No path found from %s to %s" % [start_index, end_index])
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
	
	if start_was_disabled:
		astar.set_pos_disabled(start_pos, true)
	if end_was_disabled:
		astar.set_pos_disabled(target_pos, true)
	
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
	var can_slide = true
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
	var star = CustAStar.new()
	star.reserve_space(game_state.map_hight * game_state.map_width)
	for y in range(game_state.map_hight):
		#var line = ''
		#var line2 = ''
		for x in range(game_state.map_width):
			var coor = Vector2i(x, y)
			if game_state.is_spot_traversable(coor, null):
				var same_pos_indexes = []
				for dir in MapPos.Directions.values():
					var map_pos = MapPos.new(x, y, 0, dir)
					var index = _pos_to_index(map_pos)
					star.add_point(index, coor, 1)
					for same_pos in same_pos_indexes:
						star.connect_points(index, same_pos)
					same_pos_indexes.append(index)
					#print("AddedPoint: %s | %s" % [index, map_pos])
					
					if y > 0:
						var upper_pos = Vector2i(x, y-1)
						var upper_indexes = _list_pos_indexes(upper_pos, game_state)
						for up_index in upper_indexes:
							if star.has_point(up_index):
								#print("Connecing Up Points: %s | %s" % [pos, upper_pos])
								star.connect_points(index, up_index)
					if x > 0:
						var back_pos = Vector2i(x-1, y)
						var back_indexes = _list_pos_indexes(back_pos, game_state)
						for back_index in back_indexes:
							if star.has_point(back_index):
								#print("Connecing Back Points: %s | %s" % [pos, back_pos])
								star.connect_points(index, back_index)
				
			#else:
				#line += "X"
		#print(line)
	return star


static func _pos_to_index(pos:MapPos)->int:
	var pos_index = pos.x
	pos_index = pos_index << 8
	pos_index += pos.y
	pos_index = pos_index << 2
	pos_index += pos.dir
	return pos_index
	#return (pos.x + (pos.y * game_state.map_width)) * 10 + pos.dir

static func _list_pos_indexes(pos, game_state)->Array:
	var temp_pos = MapPos.new(pos.x, pos.y, 0, 0)
	var out_list = []
	for dir in MapPos.Directions.values():
		temp_pos.dir = dir
		out_list.append(_pos_to_index(temp_pos))
	return out_list
