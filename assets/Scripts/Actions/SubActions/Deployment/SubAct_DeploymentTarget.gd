class_name SubAct_DeploymentTarget
extends BaseSubAction


func get_required_props()->Dictionary:
	return {
	}

## Returns Tags that are automatically added to the parent Action's Tags
func get_action_tags(parent_action:PageItemAction, subaction_data:Dictionary)->Array:
	return super(parent_action, subaction_data)

func do_thing(parent_action:PageItemAction, subaction_data:Dictionary, metadata,
				game_state:GameStateData, actor:BaseActor)->bool:
	
	CombatRootControl.pause_combat()
	
	
	var ui_state_data = {
		"DeployingActor" = actor.Id
	}
	CombatRootControl.Instance.ui_control.ui_state_controller.set_ui_state(UiStateController.UiStates.DeployActor, ui_state_data)
	return BaseSubAction.Success


## Return a of OnQueOptionsData to select the parent action is qued. 
func get_on_que_options(_parent_action:PageItemAction, _subaction_data:Dictionary, _actor:BaseActor, _game_state:GameStateData)->Array:
	# Check actors that have already been qued
	
	# TODO: Translation
	var selection_description = "Please select the actor to deploy."
	var options = OnQueOptionsData.new("DeployActor", selection_description)
	
	return [options]
	
