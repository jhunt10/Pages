class_name SubAct_DEV_Win
extends BaseSubAction


## Returns Tags that are automatically added to the parent Action's Tags
func get_action_tags(_parent_action:PageItemAction, _subaction_data:Dictionary)->Array:
	return ["_Dev_Action"]

func do_thing(_parent_action:PageItemAction, _subaction_data:Dictionary, _que_exe_data,
				_game_state:GameStateData, _actor:BaseActor)->bool:
	var controller = CombatRootControl.Instance
	controller.QueController.pause_execution()
	controller.trigger_end_condition(true)
	return BaseSubAction.Success
