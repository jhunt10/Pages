class_name PageHolder
extends BaseItemHolder

signal class_page_changed

var page_que_item_id
var item_id_to_effect_id:Dictionary = {}


func _debug_name()->String:
	return "PageHolder"

func _init(actor) -> void:
	super(actor)
	self._actor.effacts_changed.connect(_build_slots_list)

func _load_slots_sets_data()->Array:
	
	if LOGGING: print("--Page Slots Loading" )
	var out_list = []
	if page_que_item_id:
		if LOGGING: print("--PageItemQue: %s" % [page_que_item_id])
		var page_que = ItemLibrary.get_item(page_que_item_id)
		if page_que:
			var page_que_slots = page_que.get_load_val("ItemSlotsData", [])
			out_list.append_array(page_que_slots)
		else:
			if LOGGING: print("--PageItemQue not found")
	for effect:BaseEffect in _actor.effects.list_effects():
		if LOGGING: print("Checking Effect: %s" % [effect.details.display_name] )
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

func _load_saved_items()->Array:
	return _actor.get_load_val("Pages", [])

func _on_item_loaded(item:BaseItem):
	var page = item as BasePageItem
	if not page:
		return
	var effect_def = page.get_effect_def()
	if effect_def:
		var new_effect = _actor.effects.add_effect(page, page.get_load_val("EffectKey"), effect_def, '', true)
		item_id_to_effect_id[item.Id] = new_effect.Id

func set_page_que_item(page_que:BaseQueEquipment):
	if page_que:
		page_que_item_id = page_que.Id
	else:
		page_que_item_id = null
	_build_slots_list()

func list_action_keys()->Array:
	var out_list = []
	for item in list_items():
		var key = item.get_action_key()
		if key:
			out_list.append(key)
	return out_list

func list_actions()->Array:
	var out_list = []
	for item in list_items():
		var action_key = item.get_action_key()
		if not action_key:
			continue
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
	if item == null:
		return
	var page = item as BasePageItem
	if not page:
		printerr("PageHolder._on_item_added_to_slot: Item '%s' is not of type BasePageItem." % [item.Id])
		return
	var effect_def = page.get_effect_def()
	if effect_def:
		var new_effect = _actor.effects.add_effect(page, page.get_load_val("EffectKey"), effect_def)
		item_id_to_effect_id[item.Id] = new_effect.Id
		class_page_changed.emit()
