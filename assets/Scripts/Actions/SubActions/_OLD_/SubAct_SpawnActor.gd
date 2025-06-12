class_name SubAct_SpawnActor
extends BaseSubAction

func get_required_props()->Dictionary:
	return {
		"TargetKey": BaseSubAction.SubActionPropTypes.TargetKey,
		"ActorKey": BaseSubAction.SubActionPropTypes.StringVal
	}
## Returns Tags that are automatically added to the parent Action's Tags
func get_action_tags(_subaction_data:Dictionary)->Array:
	return ["SpawnActor"]

func do_thing(parent_action:PageItemAction, subaction_data:Dictionary, que_exe_data:QueExecutionData,
				game_state:GameStateData, actor:BaseActor)->bool:
	var turn_data = que_exe_data.get_current_turn_data()
	var target_key = subaction_data['TargetKey']
	var targets = turn_data.get_targets(target_key)
	if not targets or targets.size() == 0 or not targets[0] is MapPos:
		printerr("SubAct_SpawnActor: Invalid Target")
		return BaseSubAction.Failed
	var actor_key = subaction_data['ActorKey']
	var new_actor = ActorLibrary.Instance.create_object(actor_key)
	new_actor.FactionIndex = actor.FactionIndex
	CombatRootControl.Instance.add_actor(
		new_actor,
		targets[0])
	return BaseSubAction.Success
