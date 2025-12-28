class_name GameStateData
# This class holds a state of the game. This involes all information about the map,
# actors, effects, and thier statues.

signal actor_entered_item_spot(actor:BaseActor, item_ids:Array)

# Dictionary of Actor.Id to Actor
var _actors:Dictionary = {}
# Dictionary of Item.Id to Item on map
var _items:Dictionary = {}
var Missiles:Dictionary = {}
var _zones:Dictionary = {}

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
	new_state._zones = _zones.duplicate()
	new_state.map_data = map_data.duplicate(new_state)
	new_state.map_width = new_state.map_data.max_width
	new_state.map_hight = new_state.map_data.max_hight
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

func remove_actor_from_map(actor:BaseActor):
	map_data.remove_actor(actor)

func move_actor_to_corpse_layer(actor:BaseActor):
	map_data.set_actor_layer(actor, MapStateData.MapLayers.Corpse)

func move_actor_to_default_layer(actor:BaseActor):
	map_data.set_actor_layer(actor, MapStateData.MapLayers.Default)

func delete_actor(actor:BaseActor):
	if _actors.keys().has(actor.Id):
		_actors.erase(actor.Id)
		remove_actor_from_map(actor)
		#_actor_poses.erase(actor.Id)

func list_actors(include_dead:bool=false):
	var out_list = []
	for actor:BaseActor in _actors.values():
		if include_dead or not actor.is_dead:
			out_list.append(actor)
	return out_list

# TODO: This class shouldn't really hold logic... 
#	but zone stuff needs map_data to know which actors to apply to
#	and I can't trust everything to go through MapHelper
func set_actor_pos(actor:BaseActor, pos:MapPos, suppress_signal:bool=false):
	var old_pos = map_data.get_actor_pos(actor)
	
	map_data.set_actor_map_pos(actor, pos, suppress_signal)
	
	if suppress_signal:
		return
	
	if actor.is_player:
		var items = map_data.get_items_at_pos(pos)
		if items.size() > 0:
			actor_entered_item_spot.emit(actor, items)
	
	var aura_effects = actor.effects.get_aura_effect()
	for effect:BaseEffect in aura_effects:
		var aura_zone = effect.get_aura_zone(self)
		update_zone_pos(aura_zone, pos, [actor.Id])
	
	var old_zones = []
	if old_pos:
		old_zones = map_data.get_zones_ids_at_pos(old_pos)
	var current_zones = map_data.get_zones_ids_at_pos(pos)
	for old_zone_id in old_zones:
		if not current_zones.has(old_zone_id):
			var zone:BaseZone = _zones[old_zone_id]
			zone.on_actor_exit(actor, self)
	for current_zone_id in current_zones:
		if not old_zones.has(current_zone_id):
			var zone:BaseZone = _zones[current_zone_id]
			zone.on_actor_enter(actor, self)
	
func get_actor_pos(actor)->MapPos:
	return map_data.get_actor_pos(actor)

func get_actors_at_pos(pos, include_dead:bool=false)->Array:
	return map_data.get_actors_at_pos(pos, null, include_dead)

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

func delete_item(item):
	if item is BaseItem:
		item = item.Id
	remove_item_from_map(item)
	_items.erase(item)

func remove_item_from_map(item):
	if item is BaseItem:
		item = item.Id
	map_data.remove_item(item)



func add_missile(missile:BaseMissile):
	Missiles[missile.Id] = missile

func delete_missile(missile:BaseMissile):
	Missiles.erase(missile.Id)

func add_zone(zone:BaseZone):
	if _zones.has(zone.Id):
		printerr("GameStateData.add_zone: Zone already exists: %s" % [zone.Id])
		return
	_zones[zone.Id] = zone
	map_data.add_zone(zone)
	# Call on_actor_enter for Actors already inside the Zone
	for actor in map_data.get_actors_in_zone(zone.Id):
		zone.on_actor_enter(actor, self)

func get_zone(zone_id:String)->BaseZone:
	return _zones.get(zone_id)

func delete_zone(zone_id:String):
	if _zones.has(zone_id):
		map_data.remove_zone(zone_id)
		_zones.erase(zone_id)

func update_zone_pos(zone:BaseZone, pos:MapPos, ignore_actor_ids:Array=[]):
	zone._center_pos = pos
	var old_actors = map_data.get_actors_in_zone(zone.Id)
	map_data.update_zone_pos(zone)
	var current_actors = map_data.get_actors_in_zone(zone.Id)
	for old in old_actors:
		if ignore_actor_ids.has(old.Id):
			continue
		if not current_actors.has(old):
			zone.on_actor_exit(old, self)
	for cur in current_actors:
		if ignore_actor_ids.has(cur.Id):
			continue
		if not old_actors.has(cur):
			zone.on_actor_enter(cur, self)
