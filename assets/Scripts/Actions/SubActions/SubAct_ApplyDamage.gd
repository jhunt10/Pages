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
	var target_param_key = turn_data.get_param_key_for_target(target_key)
	var target_params = parent_action.get_targeting_params(target_param_key, actor)
	
	var tag_chain = SourceTagChain.new()\
			.append_source(SourceTagChain.SourceTypes.Actor, actor)\
			.append_source(SourceTagChain.SourceTypes.Action, parent_action)
	var attack_details = parent_action.get_load_val("AttackDetails", {})
	var override_source_pos = null
	if attack_details.get("UseTargetAsOrigin", false):
		var main_target = _get_primary_target(parent_action, subaction_data, target_key, que_exe_data, game_state, actor)
		if main_target is String:
			var main_target_actor = game_state.get_actor(main_target)
			override_source_pos = game_state.get_actor_pos(main_target_actor)
		elif main_target is MapPos:
			override_source_pos = main_target
		else:
			printerr("Unknown Primary Target")
	
	#TODO: Handle attack or just handle damage?
	for target:BaseActor in targets:
		DamageHelper.handle_attack(
			actor, 
			target, 
			attack_details, 
			damage_data, 
			parent_action.get_load_val("EffectDatas", []), 
			tag_chain, 
			game_state, 
			target_params,
			override_source_pos
		)
	
	return BaseSubAction.Success
