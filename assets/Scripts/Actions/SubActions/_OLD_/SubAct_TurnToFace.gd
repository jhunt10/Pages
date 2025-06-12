class_name SubAct_TurnToFace
extends BaseSubAction

func get_required_props()->Dictionary:
	return {
		"TargetKey": BaseSubAction.SubActionPropTypes.TargetKey
	}
## Returns Tags that are automatically added to the parent Action's Tags
func get_action_tags(_subaction_data:Dictionary)->Array:
	return ["Attack"]

func do_thing(parent_action:PageItemAction, subaction_data:Dictionary, que_exe_data:QueExecutionData,
				game_state:GameStateData, actor:BaseActor)->bool:
	
	var turn_data = que_exe_data.get_current_turn_data()
	var target_key = subaction_data['TargetKey']
	var targets:Array = _find_target_effected_actors(parent_action, subaction_data, target_key, que_exe_data, game_state, actor)
	var target_spots = _find_target_effected_spots(target_key, que_exe_data, game_state, actor)
	if target_spots.size() <= 0:
		return BaseSubAction.Failed
	var target_pos:MapPos = target_spots[0]
	var actor_pos = game_state.get_actor_pos(actor)
	
	var x_diff = target_pos.x - actor_pos.x
	var y_diff = target_pos.y - actor_pos.y
	var new_dir = actor_pos.dir
	if abs(x_diff) < abs(y_diff):
		if y_diff < 0:
			new_dir = 0 #North
		else:
			new_dir = 2 # South
	elif abs(x_diff) > abs(y_diff):
		if x_diff < 0:
			new_dir = 3 #West
		else:
			new_dir = 1 # East
	else: # X == Y
		if x_diff < 0 and y_diff < 0: # North West
			if actor_pos.dir == 1:
				new_dir = 0
			elif actor_pos.dir == 2:
				new_dir = 3
		elif x_diff > 0 and y_diff < 0: # North East
			if actor_pos.dir == 3:
				new_dir = 0
			elif actor_pos.dir == 2:
				new_dir = 1
		elif x_diff > 0 and y_diff > 0: # South East
			if actor_pos.dir == 0:
				new_dir = 1
			elif actor_pos.dir == 3:
				new_dir = 2
		elif x_diff < 0 and y_diff > 0: # South West
			if actor_pos.dir == 0:
				new_dir = 3
			elif actor_pos.dir == 1:
				new_dir = 2
	var new_pos = MapPos.new(actor_pos.x, actor_pos.y, actor_pos.z, new_dir)
	game_state.set_actor_pos(actor, new_pos)
	return BaseSubAction.Success
