class_name GameStateData
# This class holds a state of the game. This involes all information about the map,
# actors, effects, and thier statues.

# Dictionary of Actor.Id to Actor
var _actors:Dictionary = {}
#var _actor_poses:Dictionary = {}
var _items:Dictionary = {}
var Missiles:Dictionary = {}
var Zones:Dictionary = {}

var current_turn_index:int = 0

# Current state of the map
var map_data:MapStateData
var map_width:int
var map_hight:int

func duplicate()->GameStateData:
	var new_state = GameStateData.new()
	new_state._actors = _actors.duplicate()
	new_state._items = _items.duplicate()
	new_state.Missiles = Missiles.duplicate()
	new_state.Zones = Zones.duplicate()
	var new_map = map_data.duplicate(new_state)
	new_state.set_map_data(new_map)
	return new_state

func set_map_data(data:Dictionary):
	map_data = MapStateData.new(self, data)
	map_width = map_data.max_width
	map_hight = map_data.max_hight



func add_actor(actor:BaseActor):
	_actors[actor.Id] = actor

func get_actor(actor_id:String, allow_dead:bool=false, error_if_null:bool=true)->BaseActor:
	var actor = _actors.get(actor_id, null)
	if !actor:
		if error_if_null: printerr("GameStateData.get_actor: Failed to Actor with Id '%s'." % [actor_id])
		return null
	if !allow_dead and actor.is_dead:
		printerr("GameStateData.get_actor: Found dead Actor with Id '%s'." % [actor_id])
		return null
	return actor

func delete_actor(actor:BaseActor):
	if _actors.keys().has(actor.Id):
		_actors.erase(actor.Id)
		map_data.remove_actor(actor)
		#_actor_poses.erase(actor.Id)

func list_actors(include_dead:bool=false):
	var out_list = []
	for actor:BaseActor in _actors.values():
		if include_dead or not actor.is_dead:
			out_list.append(actor)
	return out_list


func set_actor_pos(actor:BaseActor, pos:MapPos):
	map_data.set_actor_pos(actor, pos)
	#_actor_poses[actor.Id] = pos
	
func get_actor_pos(actor:BaseActor)->MapPos:
	#return _actor_poses.get(actor.Id)
	return map_data.get_actor_pos(actor)

func get_actors_at_pos(pos)->Array:
	#var out_list = []
	#for actor_id in _actor_poses.keys():
		#var actor_pos = _actor_poses[actor_id]
		#if actor_pos.x == pos.x and actor_pos.y == pos.y:
			#out_list.append(_actors[actor_id])
	#return out_list
	return map_data.get_actors_at_pos(pos)




func is_spot_open(pos, ignore_actor_ids:Array=[])->bool:
	return map_data.is_spot_open(pos, ignore_actor_ids)

func is_spot_traversable(pos, actor)->bool:
	return map_data.is_spot_traversable(pos, actor)

func spot_blocks_los(pos)->bool:
	return map_data.spot_blocks_los(pos)



func add_item(item:BaseItem, pos:MapPos):
	map_data.set_item_pos(item, pos)
	_items[item.Id] = item
	
func get_item(item_id:String):
	return _items.get(item_id)
	
func list_items()->Array:
	return _items.values()

func delete_item(item:BaseItem):
	_items.erase(item.Id)




func add_missile(missile:BaseMissile):
	Missiles[missile.Id] = missile

func delete_missile(missile:BaseMissile):
	Missiles.erase(missile.Id)

func add_zone(zone:BaseZone):
	Zones[zone.Id] = zone
	map_data.add_zone(zone)
