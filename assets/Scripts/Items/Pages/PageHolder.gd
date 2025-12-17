class_name PageHolder
extends BaseItemHolder

var item_id_to_effect_id:Dictionary = {}

var cached_page_book_item_id
var cached_action_mod_source_ids:Array = []

func get_holder_name()->String:
	return "Pages"

func _init(actor) -> void:
	super(actor)
	#self._actor.effacts_changed.connect(validate_items)

func _get_innate_slots_data()->Array:
	if LOGGING: print("--Page Slots Loading" )
	var out_list = [{
		"Key":"TitlePage",
		"DisplayName":"Title Page",
		"Count": 1,
		"NeverEmpty": true,
		"FilterData":{
			"RequiredTags":"Title"
		}
	}]
	var page_book_item:BaseQueEquipment = _actor.equipment.get_que_equipment()
	if page_book_item:
		cached_page_book_item_id = page_book_item.Id
		if LOGGING: print("--PageItemQue: %s" % [page_book_item.Id])
		out_list.append_array(page_book_item.get_page_slot_data())
	else:
		if LOGGING: print("--PageItemQue not found")
		cached_page_book_item_id = null
		#if LOGGING: print("--Page Book Slots, Checking Actor Def Default")
		#var defaults = _actor.get_load_val("DefaultPageSlotSet")
		#if defaults:
			#out_list.append(defaults)
	if LOGGING: print("-Loaded Page Slots: %s" % [JSON.stringify(out_list)])
	return out_list

func validate_items():
	super()
	_cache_action_mods()

func build_effects():
	for page_id in item_id_to_effect_id.keys():
		var effect_id = item_id_to_effect_id[page_id]
		if not _actor.effects.has_effect(effect_id):
			item_id_to_effect_id.erase(page_id)
	for page in list_items():
		if page is PageItemPassive:
			var effect_def = page.get_effect_def()
			if effect_def:
				var existing_id = item_id_to_effect_id.get(page.Id)
				if existing_id:
					continue
				var effect_key = effect_def.get("EffectKey")
				var new_effect = EffectHelper.create_effect(_actor, page, effect_key, effect_def, null, '', true)
				item_id_to_effect_id[page.Id] = new_effect.Id

func get_tags_added_to_actor()->Array:
	var out_list = []
	for page:BasePageItem in list_items():
		var added = page.get_tags_added_to_actor()
		out_list.append_array(added)
	return out_list

func get_title_page()->PageItemTitle:
	var first_page = get_item_in_slot(0)
	if first_page is PageItemTitle:
		return first_page
	for item in list_items():
		if item is PageItemTitle:
			return item
	return null

func list_page_keys()->Array:
	var out_list = []
	for item in list_items():
		out_list.append(item.ItemKey)
	return out_list

func list_action_keys()->Array:
	var out_list = []
	for item in list_items():
		if item is PageItemAction:
			out_list.append(item.ActionKey)
	return out_list

func list_actions()->Array:
	var out_list = []
	for item in list_items():
		if item is PageItemAction:
			out_list.append(item)
	return out_list

func has_action(action_key:String)->bool:
	for item_id in _raw_item_slots:
		if item_id and item_id.begins_with(action_key + ":"):
			return true
	return false

func list_passives()->Array:
	var out_list = []
	for item in list_items():
		if item is PageItemPassive:
			out_list.append(item)
	return out_list

func list_passives_keys()->Array:
	var out_list = []
	for item in list_items():
		if item is PageItemPassive:
			out_list.append(item.ItemKey)
	return out_list

func get_action_page(action_key:String)->PageItemAction:
	for item_id in _raw_item_slots:
		if item_id and item_id.begins_with(action_key):
			var item = ItemLibrary.get_item(item_id)
			if item is PageItemAction and item.ActionKey == action_key:
				return item
	return ItemLibrary.get_item(action_key)

func _cache_action_mods():
	var actions = list_actions()
	var passives = list_passives()
	# Loop through Passive Pages to clear old mods
	for action:PageItemAction in actions:
		action.clear_action_mods()
	cached_action_mod_source_ids.clear()
	# Loop through Passive Pages to look for mods
	for passive:PageItemPassive in passives:
		var action_mods = passive.get_action_mods()
		if action_mods.size() == 0:
			continue
		# Loop through mods
		for mod_key:String in action_mods.keys():
			var mod_data = action_mods[mod_key]
			var conditions = mod_data.get("Conditions", {})
			var item_keys = conditions.get("ItemKeys", [])
			var item_tag_filters = conditions.get("TagFilters", [])
			# Loop through actions to apply mods
			for action:PageItemAction in actions:
				var does_mod_apply = true
				if item_keys.size() > 0:
					does_mod_apply = item_keys.has(action.ItemKey)
				else:
					var action_tags = action.get_tags()
					for filter in item_tag_filters:
						if not SourceTagChain.filters_accept_tags(filter, action_tags):
							does_mod_apply = false
							break
				# Apply Mod
				if does_mod_apply:
					action.add_action_mod(mod_data)
					if not cached_action_mod_source_ids.has(passive.Id):
						cached_action_mod_source_ids.append(passive.Id)

func _on_item_added_to_slot(item:BaseItem, index:int):
	if item == null:
		return
	var page = item as BasePageItem
	if not page:
		printerr("PageHolder._on_item_added_to_slot: Item '%s' is not of type BasePageItem." % [item.Id])
		return
		
	if item is PageItemPassive:
		var effect_def = item.get_effect_def()
		if effect_def:
			var effect_key = effect_def.get("EffectKey")
			var new_effect = EffectHelper.create_effect(_actor, item, effect_key, effect_def)
			item_id_to_effect_id[item.Id] = new_effect.Id
	_cache_action_mods()

func _on_item_removed(item_id:String, supressing_signals:bool):
	if item_id_to_effect_id.keys().has(item_id):
		var effect = EffectLibrary.get_effect(item_id_to_effect_id[item_id])
		_actor.effects.remove_effect(effect)
		item_id_to_effect_id.erase(item_id)
	_cache_action_mods()
