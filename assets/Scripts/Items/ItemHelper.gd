class_name ItemHelper

const LOGGING = true

static func spawn_item(item_key:String, item_data:Dictionary, pos:MapPos)->BaseItem:
	var item = ItemLibrary.create_item(item_key, item_data)
	if !item:
		printerr("ItemHelper: Failed to spawn item with key '%s'." % [item_key])
		return null
	else:
		CombatRootControl.Instance.add_item(item, pos)
	return item

static func get_money_small_icon():
	# Force items to load
	ItemLibrary.get_item_def("MoneyItem")
	return ItemLibrary.Instance.get_small_icon_of_def("MoneyItem")

static func get_rarity_background_for_item_key(item_key):
	var item_def = ItemLibrary.get_item_def(item_key)
	var rarity = item_def.get("ItemData", {}).get("Rarity", BaseItem.ItemRarity.Mundane)
	var taxonimy = item_def.get("#ObjDetails", {}).get("Taxonomy", [])
	var clipped = taxonimy.has("Page") and taxonimy.has("Passive")
	return get_rarity_background(rarity, clipped)


static func get_rarity_background(rarity, is_clipped:bool=false)->Texture2D:
	if rarity is BaseItem.ItemRarity:
		pass
	elif rarity is String:
		rarity = BaseItem.ItemRarity.get(rarity)
	else:
		return null
	if is_clipped:
		if rarity == BaseItem.ItemRarity.Mundane:
			return SpriteCache.get_sprite("res://assets/Sprites/Paper/Mundane_Clipped_Background.png")
		elif rarity == BaseItem.ItemRarity.Common:
			return SpriteCache.get_sprite("res://assets/Sprites/Paper/Common_Clipped_Background.png")
		elif rarity == BaseItem.ItemRarity.Rare:
			return SpriteCache.get_sprite("res://assets/Sprites/Paper/Rare_Clipped_Background.png")
		elif rarity == BaseItem.ItemRarity.Legendary:
			return SpriteCache.get_sprite("res://assets/Sprites/Paper/Legend_Clipped_Background.png")
		elif rarity == BaseItem.ItemRarity.Unique:
			return SpriteCache.get_sprite("res://assets/Sprites/Paper/Unique_Background.png")
		else:
			return SpriteCache.get_sprite("res://assets/Sprites/Paper/Mundane_Clipped_Background.png")
	else:
		if rarity == BaseItem.ItemRarity.Mundane:
			return SpriteCache.get_sprite("res://assets/Sprites/Paper/Mundane_Background.png")
		elif rarity == BaseItem.ItemRarity.Common:
			return SpriteCache.get_sprite("res://assets/Sprites/Paper/Common_Background.png")
		elif rarity == BaseItem.ItemRarity.Rare:
			return SpriteCache.get_sprite("res://assets/Sprites/Paper/Rare_Background.png")
		elif rarity == BaseItem.ItemRarity.Legendary:
			return SpriteCache.get_sprite("res://assets/Sprites/Paper/Legend_Background.png")
		elif rarity == BaseItem.ItemRarity.Unique:
			return SpriteCache.get_sprite("res://assets/Sprites/Paper/Unique_Background.png")
		else:
			return SpriteCache.get_sprite("res://assets/Sprites/Paper/Mundane_Background.png")
	

## Returns a dictionary for popup message
static func try_pickup_item(actor:BaseActor, item:BaseItem)->Dictionary:
	print("PickingUpItem: " + item.Id)
	var popup_data = {
		"Image": item.get_large_icon(),
		"Background": item.get_rarity_background(),
		"Message": item.get_display_name()
	}
	if item.get_item_type() == BaseItem.ItemTypes.Money:
		var value = item.get_item_value()
		StoryState.add_money(value)
		popup_data['Message'] = "$" + str(value)
		CombatRootControl.Instance.remove_item(item)
		ItemLibrary.delete_item(item)
		return popup_data
	var item_id = item.Id
	actor.items.add_item_to_first_valid_slot(item)
	if actor.items.has_item(item.Id):
		popup_data['Message'] += " to Bag"
	else:
		PlayerInventory.add_item(item)
		popup_data['Message'] += " to Inv"
	CombatRootControl.Instance.remove_item(item_id)
	return popup_data

static var transering_items = []
static func get_first_valid_slot_for_item(item:BaseItem, actor:BaseActor, allow_replace:bool = true)->int:
	var holder:BaseItemHolder = null
	#var index = -1
	if item is BaseEquipmentItem:
		holder = actor.equipment
	elif item is BasePageItem:
		holder = actor.pages
	elif item is BaseSupplyItem:
		holder = actor.items
	if !holder:
		return -1
	
	var index = holder.get_first_valid_slot_for_item(item, allow_replace)
	return index

static func try_transfer_item_from_inventory_to_actor(item:BaseItem, actor:BaseActor, allow_replace:bool = true)->String:
	var holder:BaseItemHolder = null
	#var index = -1
	if item is BaseEquipmentItem:
		holder = actor.equipment
	elif item is BasePageItem:
		holder = actor.pages
	elif item is BaseSupplyItem:
		holder = actor.items
	if !holder:
		return "Unknown ItemType"
	
	var index = holder.get_first_valid_slot_for_item(item, allow_replace)
	if index < 0:
		return "No Open Slot"
	if LOGGING: print("ItemHlp: Transfer %s from INV to %s" % [item.ItemKey, holder._actor.Id])
	return try_transfer_item_from_inventory_to_holder(item, holder, index, allow_replace)

static func try_transfer_item_from_inventory_to_holder(source_item:BaseItem, holder:BaseItemHolder, slot_index:int, allow_replace:bool = true)->String:
	if LOGGING: 
		print("ItemHlp: Transfer %s from INV to slot %s on %s" % [source_item.ItemKey, slot_index, holder._actor.Id])
	
	var transaction_data = {"AddedItemIds": [], "RemovedItemIds": []}
	
	## Tools require special logic since they can auto-switch hands
	if holder is EquipmentHolder and (holder as EquipmentHolder).list_all_hand_indexes().has(slot_index):
		slot_index = (holder as EquipmentHolder).get_auto_hand_index(source_item, slot_index, allow_replace)
	
	var old_items = holder._get_items_removed_if_new_item_added(slot_index, source_item)
	if old_items.size() > 0 and not allow_replace:
		print("Slot is occupied")
		return "Slot is occupied"
	var inv_item = PlayerInventory.split_item_off_stack(source_item.ItemKey)
	if !inv_item:
		print("Item not found")
		return "Item not found"
	transering_items.append(inv_item.Id)
	if not holder.can_set_item_in_slot(inv_item, slot_index, allow_replace):
		PlayerInventory.add_item(inv_item)
		print("Invalid Item Slot")
		return "Invalid Item Slot"
	
	# Dirrectly set the item into slot
	holder._direct_set_item_in_slot(slot_index, inv_item)
	transaction_data["AddedItemIds"].append(inv_item.Id)
	# This shouldn't be possible
	if not holder.has_item(inv_item.Id):
		PlayerInventory.add_item(inv_item)
		# Check if old item was lost, add to inv if so (very bad state)
		for old_item in old_items:
			if old_item and not holder.has_item(old_item.Id):
				PlayerInventory.add_item(old_item)
		print( "Set item failed")
		return "Set item failed"
	
	for old_item in old_items:
		if old_item and not holder.has_item(old_item.Id):
			holder._on_item_removed(old_item.Id, true)
			transaction_data["RemovedItemIds"].append(old_item.Id)
			PlayerInventory.add_item(old_item)
	
	holder._on_item_added_to_slot(inv_item, slot_index)
	holder._actor.on_held_items_change(holder.get_holder_name(), transaction_data)
	
	# Remove item from transfer list
	var transering_item_index = transering_items.find(inv_item.Id)
	if transering_item_index >= 0:
		transering_items.remove_at(transering_item_index)
	else:
		printerr("Lost Transfering Item?")
	return ""

static func try_transfer_item_from_actor_to_inventory(item:BaseItem, actor:BaseActor)->String:
	var holder = null
	if item is BaseEquipmentItem:
		holder = actor.equipment
	elif item is BasePageItem:
		holder = actor.pages
	elif item is BaseSupplyItem:
		holder = actor.items
	if !holder:
		return "Unknown ItemType"
	
	return try_transfer_item_from_holder_to_inventory(item, holder)

static func try_transfer_item_from_holder_to_inventory(item:BaseItem, holder:BaseItemHolder)->String:
	if LOGGING: print("ItemHlp: Transfer %s from %s to INV" % [item.ItemKey, holder._actor.Id])
	var item_id = item.Id
	if !holder.has_item(item_id):
		return "Item not found"
	transering_items.append(item_id)
	holder.remove_item(item_id)
	PlayerInventory.add_item(item)
	var transaction_data = {"AddedItemIds": [], "RemovedItemIds": [item_id]}
	holder._actor.on_held_items_change(holder.get_holder_name(), transaction_data)
	transering_items.remove_at(transering_items.find(item_id))
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
		
static func cant_equip_reasons_to_string(reasons_data:Dictionary)->String:
	var missing_string = 'Req: '
	if reasons_data.has("Tags"):
		var missing_tags = reasons_data['Tags']
		for tag in missing_tags:
			missing_string += tag + ", "
	if reasons_data.has("Stats"):
		var missing_stats = reasons_data['Stats']
		for stat_name in missing_stats.keys():
			var stat_val = missing_stats[stat_name]
			missing_string += StatHelper.get_stat_abbr(stat_name) + ":" + str(stat_val) + ", "
	if reasons_data.has("Equipment"):
		var missing_equipment = reasons_data['Equipment']
		for tag in missing_equipment:
			missing_string += tag + ", "
	if reasons_data.has("Title"):
		var missing_titles = reasons_data['Title']
		for tit in missing_titles:
			tit = tit.split(":")[1]
			missing_string += tit
	if reasons_data.has("Conflict"):
		var conflicts = reasons_data['Conflict']
		missing_string = "Conflicts with "
		for key in conflicts:
			missing_string += key
	if missing_string == '' and reasons_data.has("Apparel"):
		var apparel = reasons_data['Apparel']
		missing_string = "Invalid Apparel:  " + ", ".join(apparel)
		
	return missing_string.trim_suffix(", ")
