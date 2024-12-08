class_name PageHolder
extends BaseItemHolder

signal class_page_changed

var page_que_item_id
var item_id_to_effect_id:Dictionary = {}

func _init(actor, page_que_item) -> void:
	if page_que_item:
		page_que_item_id = page_que_item.Id
	super(actor)

func _load_slots_sets_data()->Array:
	if page_que_item_id:
		var page_que = ItemLibrary.get_item(page_que_item_id)
		if page_que:
			return page_que.get_load_val("ItemSlotsData", [])
	var defaults = _actor.get_load_val("DefaultPageSlotSet")
	if defaults:
		return defaults
	return []

func _load_saved_items()->Array:
	return _actor.get_load_val("Pages", [])

func load_effects():
	for slot_index in range(_raw_item_slots.size()):
		var page_id = _raw_item_slots[slot_index]
		if not page_id:
			continue
		var page_item = ItemLibrary.get_item(page_id)
		_on_item_added_to_slot(page_item, slot_index)

func set_page_que_item(page_que:BaseQueEquipment):
	if page_que:
		page_que_item_id = page_que.Id
	else:
		page_que_item_id = null
	_build_slots_list()

func list_action_keys()->Array:
	var out_list = []
	for item in list_items():
		out_list.append(item.get_action_key())
	return out_list

func list_actions()->Array:
	var out_list = []
	for item in list_items():
		var action = ActionLibrary.get_action(item.get_action_key())
		if action:
			out_list.append(action)
	return out_list

func get_page_item_for_action_key(action_key:String)->BasePageItem:
	for page:BasePageItem in list_items():
		if page.get_action_key() == action_key:
			return page
	return null

func _on_item_removed_from_slot(item_id:String, index:int):
	if item_id_to_effect_id.keys().has(item_id):
		var effect = EffectLibrary.get_effect(item_id_to_effect_id[item_id])
		_actor.effects.remove_effect(effect)
		item_id_to_effect_id.erase(item_id)
		class_page_changed.emit()

func _on_item_added_to_slot(item:BaseItem, index:int):
	var page = item as BasePageItem
	if not page:
		printerr("PageHolder._on_item_added_to_slot: Item '%s' is not of type BasePageItem." % [item.Id])
		return
	var effect_def = page.get_effect_def()
	if effect_def:
		var new_effect = _actor.effects.add_effect(page, page.get_load_val("EffectKey"), effect_def)
		item_id_to_effect_id[item.Id] = new_effect.Id
		class_page_changed.emit()
#func set_page_for_slot(slot_page_tags:String, index:int, page:BasePageItem):
	#if !_page_tag_slot_counts.keys().has(slot_page_tags):
		#return
	#if page and _page_tagged_slots[slot_page_tags].has(page.Id):
		#return
	#if index < 0 or index >= _page_tagged_slots[slot_page_tags].size():
		#return
	#if page:
		#_page_tagged_slots[slot_page_tags][index] = page.Id
	#else:
		#_page_tagged_slots[slot_page_tags][index] = null
	#pages_changed.emit()
#
#func get_pages_per_page_tags()->Dictionary:
	#return _page_tagged_slots.duplicate()
#
#func _count_page_tag_slots():
	#_page_tag_slot_counts.clear()
	#var total_max_count = 0
	#for equipment:BaseEquipmentItem in actor.equipment.list_equipment():
		#var page_tags_dict:Dictionary = equipment.get_load_val("PageTagSlots", {})
		#for page_tags in page_tags_dict.keys():
			#if !_page_tag_slot_counts.keys().has(page_tags):
				#_page_tag_slot_counts[page_tags] = 0
			#_page_tag_slot_counts[page_tags] += page_tags_dict[page_tags]
			#total_max_count += page_tags_dict[page_tags]
	#
	#var found_change = false
	#
	## Remove lost Page Tags
	#for page_tags in _page_tagged_slots.keys():
		#if not _page_tag_slot_counts.keys().has(page_tags):
			#found_change = true
			#_page_tagged_slots.erase(page_tags)
	#
	## Correct slots size
	#for page_tags in _page_tag_slot_counts.keys():
		## Page Tags did not exist
		#if !_page_tagged_slots.keys().has(page_tags):
			#_page_tagged_slots[page_tags] = []
			#found_change = true
		## Correct for size change
		#var max_count = _page_tag_slot_counts[page_tags]
		#if max_count != _page_tagged_slots[page_tags].size():
			#found_change = true
			#if _page_tagged_slots[page_tags].size() < max_count:
				#for index in range(max_count - _page_tagged_slots[page_tags].size()):
					#_page_tagged_slots[page_tags].append(null)
			#else:
				#for index in range(_page_tagged_slots[page_tags].size() - max_count):
					#_page_tagged_slots[page_tags].remove_at(max_count)
	
