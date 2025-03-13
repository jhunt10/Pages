class_name SubAct_RemoveEffect
extends BaseSubAction

func get_required_props()->Dictionary:
	return {
		"TargetKey": BaseSubAction.SubActionPropTypes.TargetKey,
		"EffectKey": BaseSubAction.SubActionPropTypes.EffectKey
	}
## Returns Tags that are automatically added to the parent Action's Tags
func get_action_tags(_subaction_data:Dictionary)->Array:
	return ["Apply"]

func do_thing(parent_action:BaseAction, subaction_data:Dictionary, que_exe_data:QueExecutionData,
				game_state:GameStateData, actor:BaseActor)->bool:
	
	var turn_data = que_exe_data.get_current_turn_data()
	var target_key = subaction_data['TargetKey']
	var targets:Array = _find_target_effected_actors(parent_action, subaction_data, target_key, que_exe_data, game_state, actor)
	
	var effect_key = subaction_data.get('EffectKey')
	
	for target:BaseActor in targets:
		var effects = target.effects.get_effects_with_key(effect_key)
		if effects.size() > 0:
			for effect in effects:
				target.effects.remove_effect(effect)
	return BaseSubAction.Success
