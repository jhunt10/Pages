class_name SubAct_ApplyDamage
extends BaseSubAction

func get_required_props()->Dictionary:
	return {
		"TargetKey": BaseSubAction.SubActionPropTypes.TargetKey,
		"DamageKey": BaseSubAction.SubActionPropTypes.DamageKey
	}
## Returns Tags that are automatically added to the parent Action's Tags
func get_action_tags(_subaction_data:Dictionary)->Array:
	return ["Attack"]

func do_thing(parent_action:BaseAction, subaction_data:Dictionary, que_exe_data:QueExecutionData,
				game_state:GameStateData, actor:BaseActor)->bool:
	
	var turn_data = que_exe_data.get_current_turn_data()
	var target_key = subaction_data['TargetKey']
	var targets:Array = _find_target_effected_actors(parent_action, subaction_data, target_key, que_exe_data, game_state, actor)
	var damage_data = parent_action.get_damage_data(actor, subaction_data)
	
	var tag_chain = SourceTagChain.new()\
			.append_source(SourceTagChain.SourceTypes.Actor, actor)\
			.append_source(SourceTagChain.SourceTypes.Action, parent_action)
	
	for target:BaseActor in targets:
		DamageHelper.handle_attack(actor, target, damage_data, tag_chain, game_state)
	
	return BaseSubAction.Success
