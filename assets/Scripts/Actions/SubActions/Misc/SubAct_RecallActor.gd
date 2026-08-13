class_name SubAct_RecallActor
extends BaseSubAction

func get_required_props()->Dictionary:
	return {
		"TargetKey": BaseSubAction.SubActionPropTypes.TargetKey
	}
## Returns Tags that are automatically added to the parent Action's Tags
func get_action_tags(_parent_action:PageItemAction, _subaction_data:Dictionary)->Array:
	return ["Recall"]

func do_thing(parent_action:PageItemAction, subaction_data:Dictionary, que_exe_data,
				game_state:GameStateData, actor:BaseActor)->bool:
	var target_key = subaction_data['TargetKey']
	var targets:Array = _find_target_effected_actors(parent_action, subaction_data, target_key, que_exe_data, game_state, actor)
	for target:BaseActor in targets:
		if target.is_player and actor is CarrierActor:
			CombatRootControl.Instance.recall_actor(target, actor)
	return BaseSubAction.Success
	
