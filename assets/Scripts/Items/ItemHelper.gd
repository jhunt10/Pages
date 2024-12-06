class_name ItemHelper

static func spawn_item(item_key:String, item_data:Dictionary, pos:MapPos):
	var item = ItemLibrary.create_item(item_key, item_data)
	CombatRootControl.Instance.add_item(item, pos)

static func try_pickup_item(actor:BaseActor, item:BaseItem)->bool:
	actor.items.add_item_to_first_valid_slot(item)
	if actor.items.has_item(item.Id):
		CombatRootControl.Instance.remove_item(item)
		return true
	return false

static func try_transfer_item_from_inventory_to_holder(item:BaseItem, holder:BaseItemHolder, slot_index:int, allow_replace:bool = true)->String:
	print("Transer item to holder: %s " % [item.Id])
	var inv_item = PlayerInventory.get_item_or_top_stack(item)
	if !inv_item:
		return "Item not found"
	var old_item = holder.get_item_in_slot(slot_index)
	if old_item and not allow_replace:
		return "Slot is occupied"
	if not holder.can_set_item_in_slot(inv_item, slot_index, allow_replace):
		return "Invalid Item Slot"
	if not holder.try_set_item_in_slot(inv_item, slot_index, allow_replace):
		return "Set item failed"
	
	if inv_item.can_stack:
		PlayerInventory.remove_item(inv_item)
	if old_item:
		PlayerInventory.add_item(old_item)
	return ""

static func try_transfer_item_from_holder_to_inventory(item:BaseItem, holder:BaseItemHolder)->String:
	if !holder.has_item(item.Id):
		return "Item not found"
	holder.remove_item(item.Id)
	if not PlayerInventory.has_item_id(item.Id):
		PlayerInventory.add_item(item)
	return ""

static func swap_item_holder_slots(holder:BaseItemHolder, slot_a:int, slot_b:int, return_b_to_inventory:bool=true):
	var item_a = holder.get_item_in_slot(slot_a)
	var item_b = holder.get_item_in_slot(slot_b)
	if !item_a:
		return
	holder.remove_item(item_a.Id)
	var a_can_go_in_b = holder.can_set_item_in_slot(item_a, slot_b, true)
	if not a_can_go_in_b:
		holder.try_set_item_in_slot(item_a, slot_a)
		return
	if !item_b:
		if not holder.try_set_item_in_slot(item_a, slot_b):
			holder.try_set_item_in_slot(item_a, slot_a)
		return
			
	var b_can_go_in_a = holder.can_set_item_in_slot(item_b, slot_a, true)
	if not b_can_go_in_a and not return_b_to_inventory:
		holder.try_set_item_in_slot(item_a, slot_a)
		return
		
	if b_can_go_in_a:
		holder.remove_item(item_b.Id)
		holder.try_set_item_in_slot(item_b, slot_a)
	else:
		try_transfer_item_from_holder_to_inventory(item_b, holder)
	holder.try_set_item_in_slot(item_a, slot_b)
		
		
