class_name SubAct_AnimationFinish
extends BaseSubAction

func do_thing(parent_action:BaseAction, subaction_data:Dictionary, metadata:QueExecutionData,
				game_state:GameStateData, actor:BaseActor)->bool:
	var actor_node = CombatRootControl.Instance.MapController.actor_nodes.get(actor.Id)
	if actor_node:
		actor_node.execute_animation_motion()
	return BaseSubAction.Success
