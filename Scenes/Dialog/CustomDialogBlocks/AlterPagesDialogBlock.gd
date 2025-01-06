class_name AlterPagesDialogBlock
extends BaseCustomDialogBlock

## Returns true if block should be waitied on
func handle_block(block_data:Dictionary)->bool:
	var actor = StoryState.get_player_actor()
	var swap_pages = block_data.get("SwapPages", {})
	for page_key in swap_pages.keys():
		var other_key = swap_pages[page_key]
		var item = actor.pages.get_page_item_for_action_key(page_key)
		if not item: continue
		var slot = actor.pages.get_raw_slot_index_of_item(item)
		var new_item = ItemLibrary.create_item(other_key,{})
		if not new_item:
			return false
		actor.pages.try_set_item_in_slot(new_item, slot, true)
	return false
