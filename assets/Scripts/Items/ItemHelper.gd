class_name ItemHelper

static func spawn_item(item_key:String, item_data:Dictionary, pos:MapPos)->BaseItem:
	var item = ItemLibrary.create_item(item_key, item_data)
	if !item:
		printerr("ItemHelper: Failed to spawn item with key '%s'." % [item_key])
		return null
	else:
		CombatRootControl.Instance.add_item(item, pos)
	return item


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
	
	actor.items.add_item_to_first_valid_slot(item)
	if actor.items.has_item(item.Id):
		popup_data['Message'] += " to Bag"
	else:
		PlayerInventory.add_item(item)
		popup_data['Message'] += " to Inv"
	CombatRootControl.Instance.remove_item(item)
	return popup_data

	

static func try_transfer_item_from_inventory_to_actor(item:BaseItem, actor:BaseActor, allow_replace:bool = true)->String:
	var holder:BaseItemHolder = null
	#var index = -1
	if item is BaseEquipmentItem:
		holder = actor.equipment
		#index = actor.equipment.get_first_valid_slot_for_item(item, allow_replace)
	elif item is BasePageItem:
		holder = actor.pages
	elif item is BaseConsumableItem:
		holder = actor.items
	if !holder:
		return "Unknown ItemType"
	var index = holder.get_first_valid_slot_for_item(item, true)
	return try_transfer_item_from_inventory_to_holder(item, holder, index, allow_replace)

static func try_transfer_item_from_inventory_to_holder(item:BaseItem, holder:BaseItemHolder, slot_index:int, allow_replace:bool = true)->String:
	print("Transer item to holder: %s to slot %s " % [item.Id, slot_index])
	
	var old_item = holder.get_item_in_slot(slot_index)
	if old_item and not allow_replace:
		print("Slot is occupied")
		return "Slot is occupied"
	var inv_item = PlayerInventory.split_item_off_stack(item.ItemKey)
	if !inv_item:
		print("Item not found")
		return "Item not found"
	if not holder.can_set_item_in_slot(inv_item, slot_index, allow_replace):
		PlayerInventory.add_item(inv_item)
		print("Invalid Item Slot")
		return "Invalid Item Slot"
	if not holder.try_set_item_in_slot(inv_item, slot_index, allow_replace):
		PlayerInventory.add_item(inv_item)
		print( "Set item failed")
		return "Set item failed"
	if old_item:
		# EquipmentHolder controls own logic for removing weapons
		if not (old_item is BaseWeaponEquipment and holder is EquipmentHolder): 
			PlayerInventory.add_item(old_item)
	holder._actor._on_equipment_holder_items_change()
	return ""

static func try_transfer_item_from_actor_to_inventory(item:BaseItem, actor:BaseActor)->String:
	var holder = null
	if item is BaseEquipmentItem:
		holder = actor.equipment
	elif item is BasePageItem:
		holder = actor.pages
	elif item is BaseConsumableItem:
		holder = actor.items
	if !holder:
		return "Unknown ItemType"
	return try_transfer_item_from_holder_to_inventory(item, holder)

static func try_transfer_item_from_holder_to_inventory(item:BaseItem, holder:BaseItemHolder)->String:
	if !holder.has_item(item.Id):
		return "Item not found"
	holder.remove_item(item.Id)
	if not holder is EquipmentHolder:
		PlayerInventory.add_item(item)
	holder._actor._on_equipment_holder_items_change()
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
	return missing_string.trim_suffix(", ")
