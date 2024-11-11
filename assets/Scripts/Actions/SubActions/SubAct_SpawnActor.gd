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

func do_thing(parent_action:BaseAction, subaction_data:Dictionary, que_exe_data:QueExecutionData,
				game_state:GameStateData, actor:BaseActor)->bool:
	var turn_data = que_exe_data.get_current_turn_data()
	var target_key = subaction_data['TargetKey']
	var target = turn_data.get_target(target_key)
	if not target is MapPos:
		printerr("SubAct_SpawnActor: Invalid Target")
		return BaseSubAction.Failed
	var actor_key = subaction_data['ActorKey']
	var new_actor = ActorLibrary.Instance.create_object(actor_key)
	CombatRootControl.Instance.add_actor(
		new_actor,
		actor.FactionIndex,
		target)
	return BaseSubAction.Success
