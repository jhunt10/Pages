class_name CampTutorialBlocks
extends BaseCustomDialogBlock

## Returns true if block should be waitied on
func handle_block(dialog_control:DialogController, block_data:Dictionary)->bool:
	if block_data.has("AddItemIfNone"):
		var item_key = block_data.get("AddItemIfNone")
		var item_id = ""
		for check_id:String in PlayerInventory.list_all_held_item_ids():
			if check_id.begins_with(item_key):
				item_id = check_id
				break
		if item_id == "":
			var item = ItemLibrary.create_item(item_key, {})
			PlayerInventory.add_item(item)
	
	if block_data.has("SwitchToPlayer"):
		var player_index = block_data.get("SwitchToPlayer")
		CombatRootControl.Instance.set_player_index(player_index)
	
	if block_data.has("EnableMenu"):
		var menu = block_data.get("EnableMenu")
		if menu == "Scribe":
			CampMenu.Instance.system_button.disabled = false
		if menu == "Quest":
			CampMenu.Instance.quest_button.disabled = false
		if menu == "Shop":
			CampMenu.Instance.shop_button.disabled = false
	if block_data.has("OpenMenu"):
		var menu = block_data.get("OpenMenu")
		if menu == "Scribe":
			CampMenu.Instance._sub_menu_open("System")
		elif menu == "Save":
			MainRootNode.Instance.open_save_menu()
		elif menu == "CampMain":
			CampMenu.Instance._sub_menu_open("")
		else:
			if not CharacterMenuControl.Instance:
				var actor = StoryState.get_player_actor()
				if actor:
					var camp_menu = dialog_control.get_parent()
					camp_menu.remove_child(dialog_control)
					MainRootNode.Instance.open_character_sheet(actor, camp_menu)
					camp_menu.add_child(dialog_control)
			CharacterMenuControl.Instance.on_tab_pressed(menu)
	
	if block_data.has("CloseMenu"):
		var menu = block_data.get("CloseMenu")
		if menu == "Equipment":
			CharacterMenuControl.Instance.close_menu()
		if menu == "ItemDetails":
			CharacterMenuControl.Instance._current_details_card.start_hide()
		
	if block_data.has("EquipmentItem"):
		var item_key = block_data.get("EquipmentItem")
		var item = PlayerInventory.split_item_off_stack(item_key)
		if item:
			var actor = StoryState.get_player_actor()
			actor.equipment.add_item_to_first_valid_slot(item)
		CharacterMenuControl.Instance._current_details_card.start_hide()
		
	if block_data.has("EquipPage"):
		var item_key = block_data.get("EquipPage")
		var slot_index = block_data.get("EquipPageSlot")
		var item = PlayerInventory.split_item_off_stack(item_key)
		if item:
			var actor = StoryState.get_player_actor()
			var current_item = actor.pages.get_item_in_slot(slot_index)
			actor.pages.try_set_item_in_slot(item, slot_index, true)
			PlayerInventory.add_item(current_item)
			if CharacterMenuControl.Instance and CharacterMenuControl.Instance._current_details_card:
				CharacterMenuControl.Instance._current_details_card.start_hide()
	
	if block_data.has("RemoveEquipment"):
		var index = block_data.get("RemoveEquipment")
		var actor = StoryState.get_player_actor()
		var item = actor.equipment.get_item_in_slot(index)
		if item:
			actor.equipment.remove_item(item)
			PlayerInventory.add_item(item)
	
	if block_data.has("OpenItem"):
		var item_key = block_data.get("OpenItem")
		var item_id = ""
		for check_id:String in PlayerInventory.list_all_held_item_ids():
			if check_id.begins_with(item_key):
				item_id = check_id
				break
		if item_id == "":
			for check_id:String in CharacterMenuControl.Instance._actor.pages.list_item_ids():
				if check_id.begins_with(item_key):
					item_id = check_id
					break
		var item = ItemLibrary.get_item(item_id, false)
		if item:
			CharacterMenuControl.Instance.create_details_card(item)
			#var page_control = context_to_page_control(context)
			#if page_control:
				#page_control.highlight_slot(index)
	return false
	
