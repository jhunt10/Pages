class_name SubAct_DEV_Win
extends BaseSubAction

func do_thing(parent_action:PageItemAction, subaction_data:Dictionary, que_exe_data:QueExecutionData,
				game_state:GameStateData, actor:BaseActor)->bool:
	var controller = CombatRootControl.Instance
	controller.QueController.pause_execution()
	controller.trigger_end_condition(true)
	return BaseSubAction.Success
