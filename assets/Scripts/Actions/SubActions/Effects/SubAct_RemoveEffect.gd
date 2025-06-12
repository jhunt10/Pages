class_name SubAct_RemoveEffect
extends BaseSubAction

func get_required_props()->Dictionary:
	return {
		"TargetKey": BaseSubAction.SubActionPropTypes.TargetKey,
		"EffectKey": BaseSubAction.SubActionPropTypes.EffectKey,
		"EffectKeys": BaseSubAction.SubActionPropTypes.ArrayVal,
		"EffectTagFilters": BaseSubAction.SubActionPropTypes.ArrayVal,
		"RemoveCount": BaseSubAction.SubActionPropTypes.IntVal,
		"RemoveSelectionKey": BaseSubAction.SubActionPropTypes.StringVal
	}
## Returns Tags that are automatically added to the parent Action's Tags
func get_action_tags(_subaction_data:Dictionary)->Array:
	return ["Apply"]

func do_thing(parent_action:PageItemAction, subaction_data:Dictionary, que_exe_data:QueExecutionData,
				game_state:GameStateData, actor:BaseActor)->bool:
	
	var turn_data = que_exe_data.get_current_turn_data()
	var target_key = subaction_data['TargetKey']
	var targets:Array = _find_target_effected_actors(parent_action, subaction_data, target_key, que_exe_data, game_state, actor)
	
	var remove_count_limit = subaction_data.get("RemoveCount", -1)
	var effect_tag_filters = subaction_data.get("EffectTagFilters", [])
	
	var selected_effect_id = null
	if subaction_data.has("RemoveSelectionKey"):
		var selection_key = subaction_data.get("RemoveSelectionKey")
		selected_effect_id = turn_data.on_que_data.get(selection_key, '')
		
	var effect_keys = subaction_data.get("EffectKeys", [])
	if subaction_data.has("EffectKey"):
		effect_keys.append(subaction_data.get('EffectKey', ''))
	
	
	for target:BaseActor in targets:
		if selected_effect_id:
			var effect = target.effects.get_effect(selected_effect_id)
			if effect:
				target.effects.remove_effect(effect)
		
		# Remove all effects with key
		elif effect_keys.size() > 0:
			for effect_key in effect_keys:
				var effects = target.effects.get_effects_with_key(effect_key)
				if effects.size() > 0:
					for effect in effects:
						target.effects.remove_effect(effect)
		elif effect_tag_filters.size() > 0:
			var removed_effect_count = 0
			for effect:BaseEffect in target.effects.list_effects():
				var remove_effect = false
				for filter in effect_tag_filters:
					if SourceTagChain.filters_accept_tags(filter, effect.get_tags()):
						remove_effect = true
						break
				if remove_effect:
					removed_effect_count += 1
					target.effects.remove_effect(effect)
					if remove_count_limit > 0 and removed_effect_count >= remove_count_limit:
						break
	return BaseSubAction.Success
