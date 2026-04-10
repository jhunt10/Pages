class_name BaseSupplyItem
extends BaseItem

enum SuppliesTypes {Ammo, Drinkable, Throwable, Placeable}
var using_actor_id:String

var supply_item_data:Dictionary:
	get:
		return get_load_val("SuppliesData", {})
		
func get_tagable_id(): return Id

func get_item_type()->ItemTypes:
	return ItemTypes.Supplies

func _get_object_specific_tags()->Array:
	var tags = ["Supplies"]
	TagHelper.merge_lists(tags, super())
	return tags

func get_supply_usage_types()->Array:
	var usage_strings = supply_item_data.get("UsageTypes")
	var usage_types = []
	for val in usage_strings:
		if SuppliesTypes.keys().has(val):
			usage_types.append(SuppliesTypes.get(val))
	return usage_types
			
	

func use_in_combat(_actor:BaseActor, _target, _game_state:GameStateData):
	print("Used Item: %s | Target: %s" % [self.Id, _target])
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
