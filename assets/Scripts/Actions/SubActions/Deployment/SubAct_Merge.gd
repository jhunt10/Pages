class_name SubAct_Merge
extends BaseSubAction


func get_required_props()->Dictionary:
	return {
	}

## Returns Tags that are automatically added to the parent Action's Tags
func get_action_tags(parent_action:PageItemAction, subaction_data:Dictionary)->Array:
	return super(parent_action, subaction_data)

func do_thing(parent_action:PageItemAction, subaction_data:Dictionary, metadata,
				game_state:GameStateData, actor:BaseActor)->bool:
	var turn_data:TurnExecutionData = metadata.get_current_turn_data()
	var carrier_actor_id = turn_data.on_que_data.get("MergeWithActorId", "")
	#if !carrier_actor_id:
		#printerr("SubAct_Merge: No MergeWithActorId")
		#return Failed
	
	# Get Target info
	var target_key = subaction_data.get('TargetKey')
	if !target_key:
		printerr("SubAct_Merge: No 'TargetKey' on subaction in %s." % [parent_action.ItemKey])
		return BaseSubAction.Failed
	if not turn_data.has_target(target_key):
		if subaction_data.get("FailOnNoTarget", true):
			return BaseSubAction.Failed
		else:
			return BaseSubAction.Success
	
	# Get Target Params
	var target_params = _get_target_parameters_for_target_key(target_key, parent_action, actor, turn_data)
	if !target_params:
		return BaseSubAction.Failed
	
	var targets_selected = turn_data.get_targets(target_key)
	var ignore_aoe = subaction_data.get("PrimaryTargetOnly", false)
	var targets = TargetingHelper.get_targeted_actors(
			target_params, 
			targets_selected, 
			actor, 
			game_state, 
			ignore_aoe
		)
	
	var carrier_actor:CarrierActor = null #ActorLibrary.get_actor(carrier_actor_id)
	for target in targets:
		if target is CarrierActor:
			carrier_actor = target
	
	if not carrier_actor:
		printerr("SubAct_Merge: No carrier actor found.")
		return BaseSubAction.Failed
	
	DeploymentHelper.recall_actor(actor, carrier_actor)
	return BaseSubAction.Success


### Return a of OnQueOptionsData to select the parent action is qued. 
#func get_on_que_options(_parent_action:PageItemAction, _subaction_data:Dictionary, _actor:BaseActor, _game_state:GameStateData)->Array:
	#var options = OnQueOptionsData.new("MergeWithActorId", "Select Carrier:")
	#
	#for player:BaseActor in CombatRootControl.Instance.list_player_actors(false):
		#if player is CarrierActor:
			#options.append_option(player.Id, player.get_display_name(), player.get_small_icon())
	#return [options]
	
