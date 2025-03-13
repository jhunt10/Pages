class_name SubAct_CheckCondition
extends BaseSubAction

func get_required_props()->Dictionary:
	return {
		"ConditionFlag": BaseSubAction.SubActionPropTypes.StringVal,
		"ConditionType": BaseSubAction.SubActionPropTypes.EnumVal
	}

func get_prop_enum_values(prop_key:String)->Array:
	if prop_key == "ConditionType":
		return [
			"TargetHasTag"
		]
	return []

func do_thing(parent_action:BaseAction, subaction_data:Dictionary, que_exe_data:QueExecutionData,
				game_state:GameStateData, actor:BaseActor)->bool:
	
	var turn_data = que_exe_data.get_current_turn_data()
	var condition_flag = subaction_data.get("ConditionFlag")
	if not condition_flag:
		return Success
	
	var condition_type = subaction_data.get("ConditionType")
	if condition_type == "TargetHasTag":
		var required_tag = subaction_data['RequiredTag']
		var target_key = subaction_data['TargetKey']
		var targets:Array = _find_target_effected_actors(parent_action, subaction_data, target_key, que_exe_data, game_state, actor)
		var found_any = false
		var found_all = true
		for target:BaseActor in targets:
			if target.get_tags().has(required_tag):
				found_any = true
			else:
				found_all = false
		turn_data.condition_flags[condition_flag] = false
		if subaction_data.get("RequireAll", false):
			if found_all:
				turn_data.condition_flags[condition_flag] = true
		elif found_any:
				turn_data.condition_flags[condition_flag] = true
		return Success
	printerr("Unknown SubAction Condition: %s" % [condition_flag])
	return BaseSubAction.Success
