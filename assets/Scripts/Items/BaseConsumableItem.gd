class_name BaseConsumableItem
extends BaseItem

func get_item_tags()->Array:
	var tags = super()
	tags.append("Consumable")
	return tags
