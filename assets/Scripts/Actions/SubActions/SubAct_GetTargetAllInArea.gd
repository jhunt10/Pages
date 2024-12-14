class_name SubAct_GetTargetAllInArea
extends BaseSubAction


func get_required_props()->Dictionary:
	return {
		"TargetParamKey": BaseSubAction.SubActionPropTypes.TargetParamKey,
		"SetTargetKey": BaseSubAction.SubActionPropTypes.SetTargetKey,
		"AllowDeadTargets": BaseSubAction.SubActionPropTypes.BoolVal
	}
## Returns Tags that are automatically added to the parent Action's Tags
func get_action_tags(_subaction_data:Dictionary)->Array:
	return ["Targeting"]

func do_thing(parent_action:BaseAction, subaction_data:Dictionary, metadata:QueExecutionData,
				game_state:GameStateData, actor:BaseActor)->bool:
	# Check if Target is already set
	var setting_target_key = subaction_data['SetTargetKey']
	var turn_data:TurnExecutionData = metadata.get_current_turn_data()
	if turn_data.has_target(setting_target_key):
		return BaseSubAction.Success
	
	var target_params = _get_target_parameters(parent_action, actor, subaction_data)
	if !target_params:
		return BaseSubAction.Failed
	
	# Short cut Self and FullArea 
	if target_params.target_type == TargetParameters.TargetTypes.Self or target_params.target_type == TargetParameters.TargetTypes.FullArea:
		turn_data.add_target_for_key(setting_target_key, target_params.target_param_key, actor.Id,)
		return BaseSubAction.Success
	
	# Get Targeting Params
	var actor_pos = game_state.MapState.get_actor_pos(actor)
	var allow_dups = subaction_data.get("AllowAlreadyTargeted", false)
	
	var exclude_targets = []
	if not allow_dups:
		exclude_targets = turn_data.list_targets()
		
	var selection_data = TargetSelectionData.new(target_params, setting_target_key, actor, game_state, exclude_targets)
	var potential_targets = selection_data.list_potential_targets()
	for target in potential_targets:
		turn_data.add_target_for_key(setting_target_key, target_params.target_param_key, target)
	return BaseSubAction.Success
