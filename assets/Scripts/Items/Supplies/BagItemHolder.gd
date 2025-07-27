class_name BagItemHolder
extends BaseItemHolder

var _queed_items_list:Array = []
var cached_bag_item_id

func _init(actor) -> void:
	super(actor)

func get_holder_name()->String:
	return "Suppies"

func _load_slots_sets_data()->Array:
	cached_bag_item_id = null
	var bag_item = _actor.equipment.get_bag_equipment()
	if bag_item:
		if bag_item and bag_item is BaseBagEquipment:
			cached_bag_item_id = bag_item.Id
			return bag_item.get_item_slot_data()
	var defaults = _actor.actor_data.get("DefaultBagItemSlotSet", [])
	if defaults:
		return defaults
	return []

func consume_item(item_id:String):
	if !_raw_item_slots.has(item_id):
		return
	remove_item(item_id, false)
	var item = ItemLibrary.get_item(item_id, false)
	if item:
		ItemLibrary.delete_item(item)
