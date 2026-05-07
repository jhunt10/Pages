class_name SubAct_GetTarget_ThrowItem
extends SubAct_GetTarget

## Returns TargetParameter from TurnExecution cache or Parent Action
func _get_target_parameters(target_param_key, parent_action:PageItemAction, actor:BaseActor, turn_data:TurnExecutionData)->TargetParameters:
		if turn_data and turn_data.on_que_data.has("SelectedItemId"):
			var item = ItemLibrary.get_item(turn_data.on_que_data['SelectedItemId'])
			if item and item is BaseAttackSupplyItem:
				var item_target_params = item.get_target_params()
				if item_target_params:
					return item_target_params
		return super(target_param_key, parent_action, actor, turn_data)
