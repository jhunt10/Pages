class_name PageHolder
extends BaseItemHolder

signal class_page_changed

var page_que_item_id
var item_id_to_effect_id:Dictionary = {}


func _debug_name()->String:
	return "PageHolder"

func _init(actor) -> void:
	super(actor)
	#self._actor.effacts_changed.connect(validate_items)

func _load_slots_sets_data()->Array:
	if LOGGING: print("--Page Slots Loading" )
	var out_list = [{
		"Key":"TitlePage",
		"DisplayName":"Title Page",
		"Count": 1,
		"FilterData":{
			"RequiredTags":"Title"
		}
	}]
	if page_que_item_id:
		if LOGGING: print("--PageItemQue: %s" % [page_que_item_id])
		var page_que = ItemLibrary.get_item(page_que_item_id)
		if page_que:
			out_list = page_que.get_page_slot_data()
		else:
			if LOGGING: print("--PageItemQue not found")
	for effect:BaseEffect in _actor.effects.list_effects():
		if LOGGING: print("Checking Effect: %s" % [effect.get_display_name()] )
		var extra_pages_data = effect.get_load_val("ExtraPageSlotsData", [])
		if extra_pages_data.size() > 0:
			out_list.append_array(extra_pages_data)
	if out_list.size() == 0:
		
		if LOGGING: print("--No Slots, Checking Actor Def Default")
		var defaults = _actor.get_load_val("DefaultPageSlotSet")
		if defaults:
			return defaults
	if LOGGING: print("-Loaded Page Slots: %s" % [JSON.stringify(out_list)])
	return out_list

func set_page_que_item(page_que:BaseQueEquipment, validate_items:bool=true):
	if page_que:
		page_que_item_id = page_que.Id
	else:
		page_que_item_id = null
	if validate_items:
		validate_items()

func validate_items():
	super()
	class_page_changed.emit()

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

func get_action_page(action_key:String)->PageItemAction:
	for item in list_items():
		if item is PageItemAction and item.ActionKey == action_key:
			return item
	return null


func _on_item_loaded(item:BaseItem):
	var page = item as BasePageItem
	if not page:
		return
	var effect_def = page.get_effect_def()
	if effect_def:
		var effect_key = effect_def.get("EffectKey")
		var new_effect = EffectHelper.create_effect(_actor, page, effect_key, effect_def)
		item_id_to_effect_id[item.Id] = new_effect.Id

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
	class_page_changed.emit()

func _on_item_removed_from_slot(item_id:String, index:int):
	if item_id_to_effect_id.keys().has(item_id):
		var effect = EffectLibrary.get_effect(item_id_to_effect_id[item_id])
		_actor.effects.remove_effect(effect)
		item_id_to_effect_id.erase(item_id)
	class_page_changed.emit()
