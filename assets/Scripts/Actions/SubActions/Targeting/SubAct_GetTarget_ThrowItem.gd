class_name SubAct_GetTarget_ThrowItem
extends SubAct_GetTarget

func _get_target_params(
		parent_action:PageItemAction, 
		actor:BaseActor, 
		subaction_data:Dictionary, 
		metadata:QueExecutionData = null, 
		game_state:GameStateData = null
	)->TargetParameters:
		if metadata:
			var turn_data = metadata.get_current_turn_data()
			if turn_data and turn_data.on_que_data.has("SelectedItemId"):
				var item = ItemLibrary.get_item(turn_data.on_que_data['SelectedItemId'])
				if item and item is BaseAttackSupplyItem:
					var item_target_params = item.get_target_params()
					if item_target_params:
						return item_target_params
				
		var target_param_key = subaction_data.get("TargetParamKey", "")
		return parent_action.get_targeting_params(target_param_key, actor)
