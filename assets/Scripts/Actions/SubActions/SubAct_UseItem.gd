class_name SubAct_UseItem
extends BaseSubAction
## Returns Tags that are automatically added to the parent Action's Tags
func get_action_tags(_subaction_data:Dictionary)->Array:
	return ["UseItem"]


## Return a of OnQueOptionsData to select the parent action is qued. 
func get_on_que_options(parent_action:BaseAction, _subaction_data:Dictionary, _actor:BaseActor, _game_state:GameStateData)->Array:
	var items = _actor.items.list_items()
	var options = OnQueOptionsData.new("SelectedItemId", "Select Item to use:", [], [], [])
	for item:BaseItem in items:
		options.options_vals.append(item.Id)
		options.option_texts.append(item.details.display_name)
		options.option_icons.append(item.get_small_icon())
	return [options]

func do_thing(parent_action:BaseAction, subaction_data:Dictionary, que_exe_data:QueExecutionData,
				game_state:GameStateData, actor:BaseActor)->bool:
	
	var turn_data:TurnExecutionData = que_exe_data.get_current_turn_data()
	var item_id = turn_data.on_que_data['SelectedItemId']
	var item:BaseItem = ItemLibrary.get_item(item_id)
	if item is BaseConsumableItem:
		item.use_in_combat(actor, actor, game_state)
		actor.items.remove_item(item_id)
		return BaseSubAction.Success
	else:
		printerr('SubAct_UseItem.do_thing: Failed to find selected item with id: %s' % [item_id])
		return false
