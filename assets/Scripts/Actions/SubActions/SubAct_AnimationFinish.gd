class_name SubAct_AnimationFinish
extends BaseSubAction

func do_thing(parent_action:BaseAction, subaction_data:Dictionary, metadata:QueExecutionData,
				game_state:GameStateData, actor:BaseActor)->bool:
	
	printerr("DEORECIATED: SubAct_AnimationFinish called for page '%s'" % [parent_action.ActionKey])
	return BaseSubAction.Success
	var actor_node = CombatRootControl.Instance.MapController.actor_nodes.get(actor.Id)
	if actor_node:
		if subaction_data.get("Reset", false):
			actor_node.clear_any_animations()
		else:
			actor_node.execute_animation_motion()
	return BaseSubAction.Success
