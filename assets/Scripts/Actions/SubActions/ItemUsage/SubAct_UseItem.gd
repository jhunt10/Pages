class_name SubAct_UseItem
extends BaseItemUsage_SubAct

## Returns Tags that are automatically added to the parent Action's Tags
func get_action_tags(_parent_action:PageItemAction, _subaction_data:Dictionary)->Array:
	return []


func do_thing(_parent_action:PageItemAction, _subaction_data:Dictionary, que_exe_data:QueExecutionData,
				game_state:GameStateData, actor:BaseActor)->bool:
	
	var turn_data:TurnExecutionData = que_exe_data.get_current_turn_data()
	var item_id = turn_data.on_que_data['SelectedItemId']
	var item:BaseItem = ItemLibrary.get_item(item_id)
	
	if item is BaseSupplyItem:
		item.set_using_actor(actor)
		item.use_in_combat(actor, actor, game_state)
		actor.items.consume_item(item_id)
		return BaseSubAction.Success
	else:
		printerr('SubAct_UseItem.do_thing: Failed to find selected item with id: %s' % [item_id])
		return false
