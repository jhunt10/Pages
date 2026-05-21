class_name BaseItemUsage_SubAct
extends BaseSubAction


## Return a of OnQueOptionsData to select the parent action is qued. 
func get_on_que_options(_parent_action:PageItemAction, _subaction_data:Dictionary, _actor:BaseActor, _game_state:GameStateData)->Array:
	return BaseItemUsage_SubAct._get_on_que_options(_parent_action, _subaction_data, _actor, _game_state)

# Made static so can be used by SubAct_SpawnThrowItemMissile
static func _get_on_que_options(_parent_action:PageItemAction, _subaction_data:Dictionary, _actor:BaseActor, _game_state:GameStateData)->Array:
	var items = _actor.items.list_items()
	var queued_items = []
	for turn_data in _actor.Que.QueExecData.TurnDataList:
		var queed_item = turn_data.on_que_data.get("SelectedItemId", "")
		if queed_item:
			queued_items.append(queed_item)
	# TODO: Translation
	var selection_description = _subaction_data.get("SelectionDesc", "Please select the Item you would like to use with this Page.")
	var options = OnQueOptionsData.new("SelectedItemId", selection_description, [], [], [])
	var item_tag_filter = _subaction_data.get("ItemTagFilter", {})
	for item:BaseItem in items:
		options.options_vals.append(item.Id)
		options.option_texts.append(item.get_display_name())
		options.option_icons.append(item.get_small_icon())
		if queued_items.has(item.Id) or not TagHelper.filters_accept_tags(item_tag_filter, item.get_tags()):
			options.disable_options.append(true)
		else:
			options.disable_options.append(false)
	return [options]
	
