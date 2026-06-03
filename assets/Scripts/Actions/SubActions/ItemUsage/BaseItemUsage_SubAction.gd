class_name BaseItemUsage_SubAct
extends BaseSubAction


## Return a of OnQueOptionsData to select the parent action is qued. 
func get_on_que_options(_parent_action:PageItemAction, _subaction_data:Dictionary, _actor:BaseActor, _game_state:GameStateData)->Array:
	return BaseItemUsage_SubAct._get_on_que_options(_parent_action, _subaction_data, _actor, _game_state)

# Made static so can be used by SubAct_SpawnThrowItemMissile
static func _get_on_que_options(_parent_action:PageItemAction, _subaction_data:Dictionary, _actor:BaseActor, _game_state:GameStateData)->Array:
	var queued_items = []
	for turn_data in _actor.Que.QueExecData.TurnDataList:
		var queed_item = turn_data.on_que_data.get("SelectedItemId", "")
		if queed_item:
			queued_items.append(queed_item)
	# TODO: Translation
	var selection_description = _subaction_data.get("SelectionDesc", "Please select the Item you would like to use with this Page.")
	var options = OnQueOptionsData.new("SelectedItemId", selection_description)
	var item_tag_filter = _subaction_data.get("ItemTagFilter", {})
	
	var items = _actor.items.list_items()
	if _actor is CarrierActor:
		var all_actors = [_actor]
		all_actors.append_array(_actor.list_held_actors())
		for sub_actor:BaseActor in all_actors:
			options.append_divider(sub_actor.get_display_name())
			for item in sub_actor.items.list_items():
				var is_invalid = queued_items.has(item.Id) or not TagHelper.filters_accept_tags(item_tag_filter, item.get_tags())
				options.append_option(item.Id, item.get_display_name(), item.get_small_icon(), is_invalid)
	else:
		for item:BaseItem in items:
			var is_invalid = queued_items.has(item.Id) or not TagHelper.filters_accept_tags(item_tag_filter, item.get_tags())
			options.append_option(item.Id, item.get_display_name(), item.get_small_icon(), is_invalid)
	return [options]
	
