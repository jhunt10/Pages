class_name ItemHelper

static func spawn_item(item_key:String, item_data:Dictionary, pos:MapPos):
	var item = ItemLibrary.create_item(item_key, item_data)
	CombatRootControl.Instance.add_item(item, pos)

static func try_pickup_item(actor:BaseActor, item:BaseItem)->bool:
	actor.items.add_item_to_first_valid_slot(item)
	if actor.items.has_item(item.Id):
		CombatRootControl.Instance.remove_item(item)
		return true
	return false
