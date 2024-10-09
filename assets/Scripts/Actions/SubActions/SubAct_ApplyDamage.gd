class_name SubAct_ApplyDamage
extends BaseSubAction

func get_required_props()->Dictionary:
	return {
		"TargetKey": BaseSubAction.SubActionPropType.TargetKey,
		"DamageKey": BaseSubAction.SubActionPropType.DamageKey
	}

func do_thing(parent_action:BaseAction, subaction_data:Dictionary, que_exe_data:QueExecutionData,
				game_state:GameStateData, actor:BaseActor):
	print("Apply Damage SubAction")
	
	var turn_data = que_exe_data.get_current_turn_data()
	var target_key = subaction_data['TargetKey']
	var target:BaseActor = find_target_actor(target_key, que_exe_data, game_state, actor)
	var damage_data = parent_action.get_damage_data(subaction_data)
	if target:
		DamageHelper.handle_damage(actor, target, damage_data)
	

	
