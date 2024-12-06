class_name BagItemHolder
extends BaseItemHolder

func _init(actor) -> void:
	_actor = actor
	var slot_sets_data = _get_slots_sets_data()
	super(actor)

func _get_slots_sets_data()->Array:
	var bag_items = _actor.equipment.get_equipt_items_of_slot_type("Bag")
	if bag_items.size() > 0:
		return bag_items[0].get_load_val("ItemSlotsData", [])
	return []

func _get_saved_items()->Array:
	return _actor.get_load_val("BagItems", [])
