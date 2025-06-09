class_name SubAct_ReloadPage
extends BaseSubAction


func get_required_props()->Dictionary:
	return {
	}

## Return a of OnQueOptionsData to select the parent action is qued. 
func get_on_que_options(parent_action:BaseAction, _subaction_data:Dictionary, _actor:BaseActor, _game_state:GameStateData)->Array:
	var items = _actor.items.list_items()
	var already_qued_items = _actor.Que.QueExecData.get_on_que_values("SelectedItemId")
	var options = OnQueOptionsData.new("SelectedItemId", "Select Ammo:", [], [], [])
	for item:BaseItem in items:
		options.options_vals.append(item.Id)
		options.option_texts.append(item.get_display_name())
		options.option_icons.append(item.get_small_icon())
		if item is AmmoItem:
			options.disable_options.append(already_qued_items.has(item.Id))
		else:
			options.disable_options.append(true)
		
	return [options]

func do_thing(parent_action:BaseAction, subaction_data:Dictionary, metadata:QueExecutionData,
				game_state:GameStateData, actor:BaseActor)->bool:
	var turn_data = metadata.get_data_for_turn(game_state.current_turn_index)
	if turn_data.data_cache.has("ReloadDone"):
		return Success
	var item_id = turn_data.on_que_data.get("SelectedItemId")
	if not item_id:
		printerr("SubAct_ReloadPage: No Selected Item Found.")
		return Failed
		
	var ammo_item = ItemLibrary.get_item(item_id)
	if not ammo_item:
		printerr("SubAct_ReloadPage: Failed to find ammo item with id '%s'." % [item_id])
		return Failed
	if not (ammo_item is AmmoItem):
		printerr("SubAct_ReloadPage: Ammo '%s' is not AmmoItem." % [item_id])
		return Failed
	var ammo_type = (ammo_item as AmmoItem).get_ammo_type()
	var page_that_use_ammo = []
	for action:BaseAction in actor.pages.list_actions():
		if action.has_ammo() and ammo_item.can_reload_page(actor, action):
			page_that_use_ammo.append(action.ActionKey)
	if page_that_use_ammo.size() == 0:
		printerr("SubAct_ReloadPage: No pages could use Ammo '%s'" % [item_id])
		return Failed
	actor.items.remove_item(item_id)
	ItemLibrary.delete_item(ammo_item)
	CombatRootControl.Instance.QueController.pause_execution()
	CombatUiControl.ui_state_controller.set_ui_state_from_path(
		"res://assets/Scripts/Ui/UiStates/UiState_SelectPage.gd",
	{
		"SelectablePages": page_that_use_ammo,
		"PlayerActorIndex": StoryState.get_player_index_of_actor(actor)
	})
	turn_data.data_cache['ReloadDone'] = true
	return BaseSubAction.Success
