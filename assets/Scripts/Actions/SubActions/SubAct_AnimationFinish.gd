class_name SubAct_AnimationFinish
extends BaseSubAction

func do_thing(parent_action:BaseAction, subaction_data:Dictionary, metadata:QueExecutionData,
				game_state:GameStateData, actor:BaseActor)->bool:
	actor.node.execute_animation_motion()
	return BaseSubAction.Success
