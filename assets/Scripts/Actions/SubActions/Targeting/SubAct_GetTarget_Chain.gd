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
func get_action_tags(_parent_action:PageItemAction, _subaction_data:Dictionary)->Array:
	return []

func do_thing(parent_action:PageItemAction, subaction_data:Dictionary, metadata,
				game_state:GameStateData, actor:BaseActor)->bool:
	
	var setting_target_key = subaction_data['SetTargetKey']
	var turn_data:TurnExecutionData = metadata.get_current_turn_data()
	
	var max_chain_count = subaction_data.get("MaxChainCount", 1)
	var fork_count = subaction_data.get("ForkCount", 1)
	# These are handled through Action Mods
	#max_chain_count += actor.stats.get_stat("ChainLengthBonus", 0)
	#fork_count += actor.stats.get_stat("ChainForkBonus", 0)
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
	var target_params = _get_target_parameters(target_param_key, parent_action, actor, turn_data)
	if !target_params:
		return BaseSubAction.Failed
		
	# fail if not targeting a single actor
	if (target_params.target_type != TargetParameters.TargetTypes.Actor
	and target_params.target_type != TargetParameters.TargetTypes.Enemy
	and target_params.target_type != TargetParameters.TargetTypes.Ally):
		printerr("Invalid TargetType for SubAct_GetTarget_Chain: %s | %s" % [parent_action.ItemKey, target_params.target_type])
		return BaseSubAction.Failed
		
	var actor_pos = game_state.get_actor_pos(actor)
	var allow_dups = subaction_data.get("AllowAlreadyTargeted", false)
	var allow_auto = subaction_data.get("AllowAutoTarget", false)
	var allow_select_chain = subaction_data.get("AllowSelectingChain", false)
	
	var exclude_targets = []
	if not allow_dups:
		exclude_targets = targets
		
	var selection_data = TargetSelectionData.new(
		target_params, 
		setting_target_key, 
		actor, 
		game_state, 
		exclude_targets, 
		actor_pos
	)
	var potential_target_count = selection_data.get_potential_target_count()
	# No valid targets
	if potential_target_count == 0:
		if current_target_count == 0:
			VfxHelper.create_flash_text(actor, "No Target", BaseFlashTextVfxNode.FlashTextType.NoTarget)
			return BaseSubAction.Failed
		else:
			return Success
	# Randomly select next target
	if not allow_select_chain:
		if current_target_count > 0:
			if not turn_data.data_cache.keys().has("TargetChainMaping"):
				turn_data.data_cache['TargetChainMaping'] = {}
			var first_actor = game_state.get_actor(targets[0])
			var target_chain = {first_actor.Id: actor.Id}
			get_target_chain(
				[first_actor.Id], game_state, max_chain_count-1, fork_count, target_chain
			)
			print("Target Chain: %s" %[target_chain])
			#_get_target_chain(
				#parent_action, 
				#actor, 
				#targets[0], 
				#target_param_key, 
				#setting_target_key, 
				#max_chain_count, 
				#fork_count, 
				#game_state
			#)
			for targeted_actor in target_chain.keys():
				var from_other_target = target_chain[targeted_actor]
				if targeted_actor == targets[0]:
					continue
				turn_data.add_target_for_key(setting_target_key, target_params, targeted_actor)
				turn_data.data_cache["TargetChainMaping"][targeted_actor] = from_other_target
			return BaseSubAction.Success
			## No-one to chain to
			#if potential_target_count == 0:
				#return BaseSubAction.Success
			## Reached max chain length
			#elif current_target_count >= max_chain_count:
				#return BaseSubAction.Success
			#else:
				#var possible_targets = Roll.random_targets(parent_action, actor, selection_data, fork_count)
				#if not possible_targets.size() == 0:
					#printerr("SubAct_GetTarget_Chain: Failed to select random target")
					#return BaseSubAction.Failed
				#turn_data.add_target_for_key(setting_target_key, target_param_key, target)
				## Call recursive
				#return do_thing(parent_action, subaction_data, metadata, game_state, actor)
					
	
	# Handle Ai
	if not actor.is_player:
		if AiHandler.try_handle_get_target_sub_action(actor, selection_data, parent_action, game_state):
			return BaseSubAction.Success
		else:
			return BaseSubAction.Failed 
	
	# Handle Auto Target
	if allow_auto and potential_target_count == 1:
		turn_data.add_target_for_key(setting_target_key, target_params, selection_data.list_potential_targets()[0])
		return BaseSubAction.Success
	
	CombatRootControl.pause_combat()
	CombatUiControl.ui_state_controller.set_ui_state_from_path(
		"res://assets/Scripts/Actions/Targeting/UiState_Targeting.gd",
	{
		"TargetSelectionData": selection_data,
		"AllowLockon": true
	})
	return BaseSubAction.Success

# Returns Dictionary with To:From Actors
static func get_target_chain(source_actor_ids:Array, game_state:GameStateData, remaining_chain_count:int, fork_count:int, chain_dic:Dictionary):
	if chain_dic.size() == 1:
		printerr("\n\nBuilding Chain| Size: %s" % [remaining_chain_count])
	# Get Adj Actors
	var possible_targets = {} # Target ActorId mapped to array of From Actor Id
	for from_actor_id in source_actor_ids:
		var adj_actors = MapHelper.get_adjacent_actors(game_state, from_actor_id)
		for adj_actor in adj_actors:
			if chain_dic.keys().has(adj_actor.Id):
				continue
			if chain_dic.values().has(adj_actor.Id):
				continue
			if source_actor_ids.has(adj_actor.Id):
				continue
			if not possible_targets.keys().has(adj_actor.Id):
				possible_targets[adj_actor.Id] = []
			possible_targets[adj_actor.Id].append(from_actor_id)
	if possible_targets.size() == 0:
		return
	print("Possible Targets: %s" %[possible_targets] )
	# Randomly select targets up to Fork count
	var selected_targets = {}
	var possible_target_keys = possible_targets.keys()
	while ( selected_targets.size() < fork_count 
			and possible_target_keys.size() > 0
			and selected_targets.size() < remaining_chain_count):
		var target_roll = randi() % possible_targets.size()
		var target_id = possible_target_keys[target_roll]
		var parent_roll = randi() % possible_targets[target_id].size() # Select random parent
		selected_targets[target_id] = possible_targets[target_id][parent_roll]
		possible_targets.erase(target_id)
		possible_target_keys = possible_targets.keys()
	
	for selected_target_id in selected_targets.keys():
		chain_dic[selected_target_id] = selected_targets[selected_target_id]
	if remaining_chain_count - selected_targets.size() >= 1:
		get_target_chain(selected_targets.keys(), game_state, remaining_chain_count - selected_targets.size(), fork_count, chain_dic)
		
