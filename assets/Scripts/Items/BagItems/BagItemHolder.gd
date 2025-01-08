class_name BagItemHolder
extends BaseItemHolder

var bag_item_id

func _init(actor) -> void:
	super(actor)

func _debug_name()->String:
	return "BagItemHolder"

func _load_slots_sets_data()->Array:
	if bag_item_id:
		var bag_item = ItemLibrary.get_item(bag_item_id)
		if bag_item:
			return bag_item.get_load_val("ItemSlotsData", [])
	var defaults = _actor.get_load_val("DefaultBagItemSlotSet")
	if defaults:
		return defaults
	return []

func set_bag_item(bag_item:BaseBagEquipment):
	if bag_item:
		bag_item_id = bag_item.Id
	else:
		bag_item_id = null
	_build_slots_list()


func _load_saved_items()->Array:
	return _actor.get_load_val("BagItems", [])
