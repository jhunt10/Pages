class_name SubAct_DEV_DamageTypes
extends BaseSubAction

func get_required_props()->Dictionary:
	return {
		"TargetKey": BaseSubAction.SubActionPropTypes.TargetKey,
	}
## Returns Tags that are automatically added to the parent Action's Tags
func get_action_tags(_subaction_data:Dictionary)->Array:
	return ["Dev"]

## Return a of OnQueOptionsData to select the parent action is qued. 
func get_on_que_options(parent_action:PageItemAction, _subaction_data:Dictionary, _actor:BaseActor, _game_state:GameStateData)->Array:
	var options = OnQueOptionsData.new("SelectedDamageKey", "Select Effect:", [], [], [])
	
	for damage_type in DamageEvent.DamageTypes.keys():
		options.options_vals.append(damage_type)
		options.option_texts.append(damage_type)
		options.option_icons.append(DamageHelper.get_damage_icon(damage_type))
	return [options]

func do_thing(parent_action:PageItemAction, subaction_data:Dictionary, que_exe_data:QueExecutionData,
				game_state:GameStateData, actor:BaseActor)->bool:
	
	var turn_data = que_exe_data.get_current_turn_data()
	var target_key = subaction_data['TargetKey']
	var target_param_key = turn_data.get_param_key_for_target(target_key)
	var target_params = parent_action.get_targeting_params(target_param_key, actor)
	var targets_selected = turn_data.get_targets(target_key)
	var targets = TargetingHelper.get_targeted_actors(
			target_params, 
			targets_selected, 
			actor, 
			game_state, 
			false
		)
	
	var tag_chain = SourceTagChain.new()\
			.append_source(SourceTagChain.SourceTypes.Actor, actor)\
			.append_source(SourceTagChain.SourceTypes.Action, parent_action)
			
	var damage_type_str = turn_data.on_que_data['SelectedDamageKey']
	var damage_type = DamageEvent.DamageTypes.get(damage_type_str)
	var damage_key =  subaction_data.get("DamageKey", '')
	var damage_data = parent_action.get_damage_data_single(actor, damage_key) 
	damage_data['DamageType'] = damage_type_str
	for target in targets:
		var damage_event = DamageHelper.roll_and_apply_damage(damage_data, actor, target, tag_chain, game_state)
		
		print("\n---------------------------")
		print(damage_event.dictialize_self())
		print("---------------------------\n")
	return BaseSubAction.Success
