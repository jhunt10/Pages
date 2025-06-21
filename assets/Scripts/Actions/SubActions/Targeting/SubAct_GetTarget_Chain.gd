class_name SubAct_GetTarget_Chain
extends BaseSubAction


func get_required_props()->Dictionary:
	return {
		"TargetParamKey": BaseSubAction.SubActionPropTypes.TargetParamKey,
		"SetTargetKey": BaseSubAction.SubActionPropTypes.SetTargetKey,
		"AllowAutoTarget": BaseSubAction.SubActionPropTypes.BoolVal,
		"AllowAlreadyTargeted": BaseSubAction.SubActionPropTypes.BoolVal,
		"AllowSelectingChain": BaseSubAction.SubActionPropTypes.BoolVal,
		"MaxChainCount": BaseSubAction.SubActionPropTypes.IntVal,
	}
## Returns Tags that are automatically added to the parent Action's Tags
func get_action_tags(_subaction_data:Dictionary)->Array:
	return ["Targeting"]

func do_thing(parent_action:PageItemAction, subaction_data:Dictionary, metadata:QueExecutionData,
				game_state:GameStateData, actor:BaseActor)->bool:
	
	var setting_target_key = subaction_data['SetTargetKey']
	var turn_data:TurnExecutionData = metadata.get_current_turn_data()
	
	var max_chain_count = subaction_data.get("MaxChainCount", 1)
	max_chain_count += actor.stats.get_stat("MaxChainBonus", 0)
	var current_target_count = 0
	
	# Check if Target is already set
	var targets = []
	if turn_data.has_target(setting_target_key):
		targets = turn_data.get_targets(setting_target_key)
		current_target_count = targets.size()
	
	if current_target_count >= max_chain_count:
		return BaseSubAction.Success
	
	
	# Get Targeting Params
	var target_param_key = subaction_data.get("TargetParamKey", "")
	var target_params = parent_action.get_targeting_params(target_param_key, actor)
	if !target_params:
		return BaseSubAction.Failed
		
	# fail if not targeting a single actor
	if (target_params.target_type != TargetParameters.TargetTypes.Actor 
	and target_params.target_type != TargetParameters.TargetTypes.Enemy
	and target_params.target_type != TargetParameters.TargetTypes.Ally):
		printerr("Invalid TargetType for SubAct_GetTarget_Chain: %s | %s" % [parent_action.ItemKey, target_params.target_type])
		return BaseSubAction.Failed
		
	var actor_pos = game_state.get_actor_pos(actor)
	# Override target params for chained targets
	if current_target_count > 0:
		target_params = TargetParameters.new(target_param_key, {
			"LineOfSight": true,
			"TargetArea": "[[-1,1],[0,1],[1,1],[-1,0],[1,0],[-1,-1],[0,-1],[1,-1]]",
			"TargetType": "Actor"
		})
		var last_target = targets[current_target_count-1]
		actor_pos = game_state.get_actor_pos(last_target)
	var allow_dups = subaction_data.get("AllowAlreadyTargeted", false)
	var allow_auto = subaction_data.get("AllowAutoTarget", false)
	var allow_select_chain = subaction_data.get("AllowSelectingChain", false)
	
	var exclude_targets = []
	if not allow_dups:
		exclude_targets = targets
		
	var selection_data = TargetSelectionData.new(target_params, setting_target_key, actor, game_state, exclude_targets, actor_pos)
	var potential_target_count = selection_data.get_potential_target_count()
	# No valid targets
	if potential_target_count == 0:
		if current_target_count == 0:
			VfxHelper.create_flash_text(actor, "No Target", VfxHelper.FlashTextType.NoTarget)
			return BaseSubAction.Failed
		else:
			return Success
	# Randomly select next target
	if not allow_select_chain:
		if current_target_count > 0:
			# No-one to chain to
			if potential_target_count == 0:
				return BaseSubAction.Success
			# Reached max chain length
			elif current_target_count >= max_chain_count:
				return BaseSubAction.Success
			else:
				var target = RandomHelper.select_random_target(parent_action, actor, selection_data)
				if not target:
					printerr("SubAct_GetTarget_Chain: Failed to select random target")
					return BaseSubAction.Failed
				turn_data.add_target_for_key(setting_target_key, target_param_key, target)
				# Call recursive
				return do_thing(parent_action, subaction_data, metadata, game_state, actor)
					
	
	# Handle Ai
	if not actor.is_player:
		if AiHandler.try_handle_get_target_sub_action(actor, selection_data, parent_action, game_state):
			return BaseSubAction.Success
		else:
			return BaseSubAction.Failed 
	
	# Handle Auto Target
	if allow_auto and potential_target_count == 1:
		turn_data.add_target_for_key(setting_target_key, target_param_key, selection_data.list_potential_targets()[0])
		return BaseSubAction.Success
	
	CombatRootControl.Instance.QueController.pause_execution()
	CombatUiControl.ui_state_controller.set_ui_state_from_path(
		"res://assets/Scripts/Actions/Targeting/UiState_Targeting.gd",
	{
		"TargetSelectionData": selection_data
	})
	return BaseSubAction.Success
