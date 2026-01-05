class_name BaseSupplyItem
extends BaseItem

var using_actor_id:String

var supply_item_data:Dictionary:
	get:
		return get_load_val("SuppliesData", {})

func get_tags()->Array:
	var tags = super()
	tags.append("Consumable")
	return tags

func use_in_combat(_actor:BaseActor, _target, _game_state:GameStateData):
	print("Used Item: %s" % [self.Id])
	pass

func set_using_actor(actor:BaseActor):
	if actor:
		using_actor_id = actor.Id
	else:
		using_actor_id = ''

func get_using_actor()->BaseActor:
	if using_actor_id != '':
		return ActorLibrary.get_actor(using_actor_id)
	return null
