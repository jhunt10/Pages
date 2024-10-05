class_name SubAct_GetTarget
extends BaseSubAction


func get_required_props()->Dictionary:
	return {
		"TargetKey": BaseSubAction.SubActionPropType.TargetKey
	}

func do_thing(parent_action:BaseAction, subaction_data:Dictionary, metadata:QueExecutionData,
				game_state:GameStateData, actor:BaseActor):
	print("Get Target SubAction")
	
	# Check if Target is already set
	var target_key = subaction_data['TargetKey']
	var turndata = metadata.get_current_turn_data()
	if turndata.targets.has(target_key):
		print("Has Target: ", turndata.targets[target_key])
		return
	
	var target_parms:TargetParameters = parent_action.TargetParams[target_key]
	if target_parms.target_type == TargetParameters.TargetTypes.Self:
		turndata.targets[target_key] = actor.Id
		return
	
	# Get Targeting Params
	var actor_pos = game_state.MapState.get_actor_pos(actor)
	
	if TargetParameters.is_actor_target(target_parms):
		var potentials = _get_potential_actor_targets(game_state, actor, target_parms)
		if potentials.size() == 0:
			print("No valid Targets")
			return
			
		if potentials.size() == 1:
			turndata.targets[target_key] = potentials[0].Id
			return
	
	CombatRootControl.Instance.QueController.pause_execution()
	CombatRootControl.Instance.ui_controller.set_ui_state_from_path(
		"res://assets/Scripts/Targeting/UiState_Targeting.gd",
	{
		"Position": actor_pos,
		"TargetParameters": target_parms,
		"SourceAction": parent_action,
		"MetaData": metadata,
	})
	pass

func _get_potential_actor_targets(game_state:GameStateData, actor:BaseActor, targeting:TargetParameters):
	var actor_pos = game_state.MapState.get_actor_pos(actor)
	var target_area = targeting.target_area.to_map_spots(actor_pos)
	var potential_targets = []
	for spot in target_area:
		for target in game_state.MapState.get_actors_at_pos(spot):
			if targeting.is_valid_target(actor, target):
				potential_targets.append(target)
	return potential_targets
	
