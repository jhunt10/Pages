class_name SubAct_ReTargetRandomInAoe
extends BaseSubAction

func get_required_props()->Dictionary:
	return {
		"ModifyTargetKey": BaseSubAction.SubActionPropTypes.TargetKey,
		"ChanceToMod": BaseSubAction.SubActionPropTypes.FloatVal,
		"BeingTargetIsGood": BaseSubAction.SubActionPropTypes.BoolVal
	}
## Returns Tags that are automatically added to the parent Action's Tags
func get_action_tags(_subaction_data:Dictionary)->Array:
	return []

func do_thing(parent_action:PageItemAction, subaction_data:Dictionary, que_exe_data:QueExecutionData,
				game_state:GameStateData, actor:BaseActor)->bool:
	
	var modify_target_key = subaction_data.get("ModifyTargetKey", "")
	var turn_data = que_exe_data.get_current_turn_data()	
	var target_param_key = turn_data.get_param_key_for_target(modify_target_key)
	var target_params = parent_action.get_targeting_params(target_param_key, actor)
	var targets:Array = _find_target_effected_actors(parent_action, subaction_data, modify_target_key, que_exe_data, game_state, actor)
	if targets.size() > 1:
		printerr("SubAct_SelectEffectOnTarget: Multiple Targets not supported")
		return Failed
	elif targets.size() == 0:
		return Failed
	var target_actor = targets[0]
	var pos = game_state.get_actor_pos(target_actor)
	var area = target_params.get_area_of_effect(pos)
	var other_actors = {}
	for point in area:
		for other_act in game_state.get_actors_at_pos(point):
			other_actors[other_act.Id] = other_act
	if other_actors.size() == 0:
		return BaseSubAction.Success
	
	var mod_chance = 0.5#subaction_data.get("ChanceToMod", 1)
	var hit_another = RandomHelper.roll_for_chance(mod_chance)
	if hit_another:
		var is_good = subaction_data.get("BeingTargetIsGood", false)
		var new_target = RandomHelper.get_random_actor_from_list(other_actors.values(), is_good)
		turn_data.replace_target_for_key(modify_target_key, target_param_key, target_actor, new_target)
	
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
