class_name SubAct_SustainLastAction
extends BaseSubAction

func get_required_props()->Dictionary:
	return {
		"TargetKey": BaseSubAction.SubActionPropTypes.TargetKey,
		"DamageKey": BaseSubAction.SubActionPropTypes.DamageKey
	}
## Returns Tags that are automatically added to the parent Action's Tags
func get_action_tags(_subaction_data:Dictionary)->Array:
	return ["Sustain"]

func do_thing(parent_action:BaseAction, subaction_data:Dictionary, que_exe_data:QueExecutionData,
				game_state:GameStateData, actor:BaseActor)->bool:
	var last_turn_index = game_state.current_turn_index - 1
	if last_turn_index < 0:
		printerr("SubAct_SustainLastAction: Used on first Turn of Round.")
		return BaseSubAction.Failed
	var last_turn_data = que_exe_data.get_data_for_turn(last_turn_index)
	var last_turn_action = actor.Que.get_action_for_turn(last_turn_index)
	if not last_turn_action:
		printerr("SubAct_SustainLastAction: Failed to find LastTurn Action for Turn Index: %s." % [last_turn_index])
		return BaseSubAction.Failed
	
	var sustain_data = last_turn_action.get_sustain_data()
	if sustain_data.size() == 0:
		printerr("SubAct_SustainLastAction: LastTurn Action sustain_data is empty." % [last_turn_index])
		return BaseSubAction.Failed
	
	var sustain_effect_data_key = sustain_data.get("SustainEffectDataKey", "")
	var sustain_effect_data = last_turn_action.get_effect_data(sustain_effect_data_key)
	var sustain_effect_key = sustain_effect_data.get("EffectKey", "")
	
	var sustain_target_key = sustain_data.get("SustainTargetKey", "")
	
	var last_targeted_actors = last_turn_data.get_targets(sustain_target_key)
	for last_actor_id in last_targeted_actors:
		var last_actor = game_state.get_actor(last_actor_id)
		if not last_actor:
			continue
		EffectHelper.create_effect(last_actor, actor, sustain_effect_key, sustain_effect_data, game_state)
	
	var turn_data = que_exe_data.get_current_turn_data()
	return BaseSubAction.Success
