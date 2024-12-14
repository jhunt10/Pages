class_name GameStateData
# This class holds a state of the game. This involes all information about the map,
# actors, effects, and thier statues.

# Dictionary of Actor.Id to Actor
var _actors:Dictionary = {}
var _items:Dictionary = {}
var Missiles:Dictionary = {}
var Zones:Dictionary = {}

var current_turn_index:int = 0

# Current state of the map
var MapState:MapStateData

func add_actor(actor:BaseActor):
	_actors[actor.Id] = actor

func get_actor(actor_id:String, allow_dead:bool=false):
	var actor = _actors.get(actor_id, null)
	if !actor:
		printerr("GameStateData.get_actor: Failed to Actor with Id '%s'." % [actor_id])
		return null
	if !allow_dead and actor.is_dead:
		printerr("GameStateData.get_actor: Found dead Actor with Id '%s'." % [actor_id])
		return null
	return actor

func delete_actor(actor:BaseActor):
	if _actors.keys().has(actor.Id):
		_actors.erase(actor.Id)
		MapState.remove_actor(actor)

func list_actors(include_dead:bool=false):
	var out_list = []
	for actor:BaseActor in _actors.values():
		if include_dead or not actor.is_dead:
			out_list.append(actor)
	return out_list


func add_item(item:BaseItem):
	_items[item.Id] = item
	
func get_item(item_id:String):
	return _items.get(item_id)

func delete_item(item:BaseItem):
	_items.erase(item.Id)

func add_missile(missile:BaseMissile):
	Missiles[missile.Id] = missile

func delete_missile(missile:BaseMissile):
	Missiles.erase(missile.Id)

func add_zone(zone:BaseZone):
	Zones[zone.Id] = zone
	MapState.add_zone(zone)
