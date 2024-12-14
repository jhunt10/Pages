class_name SubAct_TeleportSwap
extends BaseSubAction

func get_required_props()->Dictionary:
	return {
		"DestRelativePos": BaseSubAction.SubActionPropTypes.MoveValue,
		"TargetActorAKey": BaseSubAction.SubActionPropTypes.TargetKey,
		"TargetActorBKey": BaseSubAction.SubActionPropTypes.TargetKey,
	}
## Returns Tags that are automatically added to the parent Action's Tags
func get_action_tags(_subaction_data:Dictionary)->Array:
	return ["Move"]

func do_thing(parent_action:BaseAction, subaction_data:Dictionary, que_exe_data:QueExecutionData,
				game_state:GameStateData, actor:BaseActor)->bool:
	
	var turn_data = que_exe_data.get_current_turn_data()
	
	var target_actor_a_key = subaction_data['TargetActorAKey']
	var target_id_a = turn_data.get_targets(target_actor_a_key)[0]
	var target_a:BaseActor = game_state.get_actor(target_id_a)
	if !target_a:
		printerr("Invalid Target for teleporting: %s." % [target_actor_a_key])
		return BaseSubAction.Failed
		
	var target_actor_b_key = subaction_data['TargetActorBKey']
	var target_id_b = turn_data.get_targets(target_actor_b_key)[0]
	var target_b:BaseActor = game_state.get_actor(target_id_b)
	if !target_b:
		printerr("Invalid Target for teleporting: %s." % [target_actor_b_key])
		return BaseSubAction.Failed
	
	var pos_a = game_state.MapState.get_actor_pos(target_a)
	var pos_b = game_state.MapState.get_actor_pos(target_b)

	game_state.MapState.set_actor_pos(target_a, pos_b)
	game_state.MapState.set_actor_pos(target_b, pos_a)
	return BaseSubAction.Success
