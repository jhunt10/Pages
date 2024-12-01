class_name PageHolder

signal pages_changed

var _page_tag_slot_counts:Dictionary={}
var _page_tagged_slots:Dictionary={}

var actor:BaseActor

func _init(actor:BaseActor) -> void:
	self.actor = actor
	actor.equipment_changed.connect(_count_page_tag_slots)
	_page_tagged_slots = actor.get_load_val("Pages", {})
	_count_page_tag_slots()
	

func get_max_page_count()->int:
	var count = 0
	for val in _page_tag_slot_counts.values():
		count += val
	return count

func list_action_keys()->Array:
	var out_list = []
	for val in _page_tagged_slots.values():
		out_list.append_array(val)
	return out_list

func list_pages()->Array:
	var keys = list_action_keys()
	var out_list=[]
	for key in keys:
		if key == null: continue
		var page = ActionLibrary.get_action(key)
		if page:
			out_list.append(page)
	return out_list

func has_page(action_key:String):
	var action_keys = list_action_keys()
	return action_keys.has(action_key)

func remove_page(action_key:String):
	var changed = false
	for page_tags in _page_tagged_slots.keys():
		var index = _page_tagged_slots[page_tags].find(action_key)
		if index < 0:
			continue
		_page_tagged_slots[page_tags][index] = null
		changed = true
	if changed:
		pages_changed.emit()

func try_add_page(page:BaseAction)->bool:
	if has_page(page.ActionKey):
		return true
	for page_tags in _page_tagged_slots.keys():
		if _does_page_match_tags(page_tags, page):
			var open_slot = _page_tagged_slots[page_tags].find(null)
			if open_slot >= 0:
				_page_tagged_slots[page_tags][open_slot] = page.ActionKey
				pages_changed.emit()
				return true
			else:
				print("No Open Slot found in '%s'" %[page_tags])
		else:
			print("%s Not match tags '%s'" %[page.ActionKey, page_tags])
	print("No Valid PageTags Slot Found")
	return false

func _does_page_match_tags(page_tags:String, page:BaseAction)->bool:
	var tags = page_tags.split("|")
	for tag in tags:
		if tag == "Any":
			continue
		if not page.details.tags.has(tag):
			return false
	return true

func set_page_for_slot(slot_page_tags:String, index:int, page:BaseAction):
	if !_page_tag_slot_counts.keys().has(slot_page_tags):
		return
	if page and _page_tagged_slots[slot_page_tags].has(page.ActionKey):
		return
	if index < 0 or index >= _page_tagged_slots[slot_page_tags].size():
		return
	if page:
		_page_tagged_slots[slot_page_tags][index] = page.ActionKey
	else:
		_page_tagged_slots[slot_page_tags][index] = null
	pages_changed.emit()

func get_pages_per_page_tags()->Dictionary:
	return _page_tagged_slots.duplicate()

func _count_page_tag_slots():
	_page_tag_slot_counts.clear()
	var total_max_count = 0
	for equipment:BaseEquipmentItem in actor.equipment.list_equipment():
		var page_tags_dict:Dictionary = equipment.get_load_val("PageTagSlots", {})
		for page_tags in page_tags_dict.keys():
			if !_page_tag_slot_counts.keys().has(page_tags):
				_page_tag_slot_counts[page_tags] = 0
			_page_tag_slot_counts[page_tags] += page_tags_dict[page_tags]
			total_max_count += page_tags_dict[page_tags]
	
	var found_change = false
	
	# Remove lost Page Tags
	for page_tags in _page_tagged_slots.keys():
		if not _page_tag_slot_counts.keys().has(page_tags):
			found_change = true
			_page_tagged_slots.erase(page_tags)
	
	# Correct slots size
	for page_tags in _page_tag_slot_counts.keys():
		# Page Tags did not exist
		if !_page_tagged_slots.keys().has(page_tags):
			_page_tagged_slots[page_tags] = []
			found_change = true
		# Correct for size change
		var max_count = _page_tag_slot_counts[page_tags]
		if max_count != _page_tagged_slots[page_tags].size():
			found_change = true
			if _page_tagged_slots[page_tags].size() < max_count:
				for index in range(max_count - _page_tagged_slots[page_tags].size()):
					_page_tagged_slots[page_tags].append(null)
			else:
				for index in range(_page_tagged_slots[page_tags].size() - max_count):
					_page_tagged_slots[page_tags].remove_at(max_count)
	
