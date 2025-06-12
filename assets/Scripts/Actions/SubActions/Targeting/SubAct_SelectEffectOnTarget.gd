class_name SubAct_SelectEffectOnTarget
extends BaseSubAction

func get_required_props()->Dictionary:
	return {
		"TargetKey": BaseSubAction.SubActionPropTypes.TargetKey,
		"SelectionKey": BaseSubAction.SubActionPropTypes.StringVal,
		"EffectTagFilters": BaseSubAction.SubActionPropTypes.ArrayVal,
	}
## Returns Tags that are automatically added to the parent Action's Tags
func get_action_tags(_subaction_data:Dictionary)->Array:
	return []

func do_thing(parent_action:PageItemAction, subaction_data:Dictionary, que_exe_data:QueExecutionData,
				game_state:GameStateData, actor:BaseActor)->bool:
	
	var selection_key = subaction_data.get("SelectionKey", "SelectEffect")
	var effect_filters = subaction_data.get("EffectFilters", [])
	var turn_data = que_exe_data.get_current_turn_data()
	if turn_data.on_que_data.has(selection_key):
		return Success
	
	var target_key = subaction_data.get('TargetKey', "Self")
	var target_actor = null
	if target_key == "Self":
		target_actor = actor
	else:
		var targets:Array = _find_target_effected_actors(parent_action, subaction_data, target_key, que_exe_data, game_state, actor)
		if targets.size() > 1:
			printerr("SubAct_SelectEffectOnTarget: Multiple Targets not supported")
			return Failed
		elif targets.size() == 0:
			return Failed
		target_actor = targets[0]
	
	
	var options = _get_effect_que_options(target_actor, selection_key, effect_filters)
	CombatUiControl.Instance.ui_state_controller.open_options_menu(actor, selection_key, options)
	return BaseSubAction.Success


## Return a of OnQueOptionsData to select the parent action is qued. 
func _get_effect_que_options(actor:BaseActor, selection_key:String, effect_filters:Array)->OnQueOptionsData:
	var options = OnQueOptionsData.new(selection_key, "Select Effect:", [], [], [])
	for effect:BaseEffect in actor.effects.list_effects():
		var is_valid = true
		var effect_tags = effect.get_tags()
		for filter in effect_filters:
			if not SourceTagChain.filters_accept_tags(filter, effect_tags):
				is_valid = false
				break
		options.options_vals.append(effect.Id)
		options.option_texts.append(effect.get_display_name())
		options.option_icons.append(effect.get_small_icon())
		options.disable_options.append(not is_valid)
	return options
