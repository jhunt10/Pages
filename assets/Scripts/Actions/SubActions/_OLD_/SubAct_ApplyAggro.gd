class_name SubAct_ApplyAggro
extends BaseSubAction

func get_required_props()->Dictionary:
	return {
		"TargetKey": BaseSubAction.SubActionPropTypes.TargetKey,
		"ChangeType": BaseSubAction.SubActionPropTypes.EnumVal
	}

func get_prop_enum_values(prop_key:String)->Array:
	if prop_key == 'ChangeType':
		return ['ToHighestThreat', 'ToLowestThreat']
	return []

## Returns Tags that are automatically added to the parent Action's Tags
func get_action_tags(_subaction_data:Dictionary)->Array:
	return []

func do_thing(parent_action:PageItemAction, subaction_data:Dictionary, que_exe_data:QueExecutionData,
				game_state:GameStateData, actor:BaseActor)->bool:
	
	var turn_data = que_exe_data.get_current_turn_data()
	var target_key = subaction_data['TargetKey']
	var targets:Array = _find_target_effected_actors(parent_action, subaction_data, target_key, que_exe_data, game_state, actor)
	var damage_data = parent_action.get_damage_data_for_subaction(actor, subaction_data)
	var target_param_key = turn_data.get_param_key_for_target(target_key)
	var target_params = parent_action.get_targeting_params(target_param_key, actor)
	
	var tag_chain = SourceTagChain.new()\
			.append_source(SourceTagChain.SourceTypes.Actor, actor)\
			.append_source(SourceTagChain.SourceTypes.Action, parent_action)
	
	var change_type = subaction_data.get("ChangeType", '')
	
	for target:BaseActor in targets:
		# Aggro never applies between allies
		if target.FactionIndex == actor.FactionIndex:
			continue
		var current_threat = target.aggro.get_threat_from_actor(actor.Id)
		if change_type == 'ToHighestThreat':
			var highest = target.aggro.get_highest_threat() * AggroHandler.THREAT_SWITCH_THRESHOLD
			var add = max(0, highest - current_threat) + 1
			target.aggro.add_threat_from_actor(actor, add)
			
		if change_type == 'ToLowestThreat':
			var lowest = target.aggro.get_lowest_threat()
			var add = max(0, lowest - current_threat - 1)
			target.aggro.add_threat_from_actor(actor, add)
			
		
	
	return BaseSubAction.Success
