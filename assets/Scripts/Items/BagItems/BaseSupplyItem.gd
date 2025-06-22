class_name BaseSupplyItem
extends BaseItem

func get_item_tags()->Array:
	var tags = super()
	tags.append("Consumable")
	return tags

func use_in_combat(actor:BaseActor, target, gamee_state:GameStateData):
	print("Used Item: %s" % [self.Id])
	pass
