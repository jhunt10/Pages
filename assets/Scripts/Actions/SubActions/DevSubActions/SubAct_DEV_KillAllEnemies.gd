class_name SubAct_DEV_KillAllEnemies
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
	var targets = []
	for check_actor:BaseActor in game_state.list_actors():
		if check_actor.FactionIndex != actor.FactionIndex:
			targets.append(check_actor)
	var tag_chain = SourceTagChain.new()\
			.append_source(SourceTagChain.SourceTypes.Actor, actor)\
			.append_source(SourceTagChain.SourceTypes.Action, parent_action)
	
	var damage_data = parent_action.get_damage_data(actor, subaction_data)
	var target_params = parent_action.get_targeting_params("Self", actor)
	
	for target:BaseActor in targets:
		DamageHelper.handle_attack(actor, target, {}, damage_data, [], tag_chain, game_state, target_params)
	
	#for target:BaseActor in targets:
		#DamageHelper.handle_attack(actor, target, damage_data, tag_chain, game_state)
	
	return BaseSubAction.Success
