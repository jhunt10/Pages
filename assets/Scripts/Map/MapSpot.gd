class_name MapSpot

const LOGGING=false

var parent_map:MapStateData = null
var X:int = 0
var Y:int = 0
var terrain_index:int = 0

var _layer_to_actor_ids:Dictionary = {}

#var _actor_ids:Array=[]
var _zone_ids:Array = []
var item_ids:Array = []

func duplicate(new_parent:MapStateData)->MapSpot:
	var new_spot = MapSpot.new(X, Y, terrain_index, new_parent)
	new_spot._zone_ids = _zone_ids.duplicate()
	new_spot.item_ids = item_ids.duplicate()
	new_spot._layer_to_actor_ids = _layer_to_actor_ids.duplicate(true)
	return new_spot

func _init(x:int, y:int, terrain_index:int, parent:MapStateData) -> void:
	parent_map = parent
	X = x
	Y = y
	self.terrain_index = terrain_index
	
func add_actor(actor:BaseActor, layer=MapStateData.DEFAULT_ACTOR_LAYER):
	if LOGGING: print("Adding actor '%s' (%s, %s) %s" % [actor.ActorKey, X, Y, layer])
	if not _layer_to_actor_ids.keys().has(layer):
		_layer_to_actor_ids[layer] = []
	if _layer_to_actor_ids[layer].has(actor.Id):
		printerr("Actor " + actor.Id + " is already set for spot (" + str(X) + "," + str(Y) + ")")
	else:
		_layer_to_actor_ids[layer].append(actor.Id)

func remove_actor(actor:BaseActor):
	for layer in _layer_to_actor_ids.keys():
		if _layer_to_actor_ids[layer].has(actor.Id):
			_layer_to_actor_ids[layer].erase(actor.Id)
		
func get_actors(layer=null, include_dead:bool=false)->Array:
	var out_list = []
	if layer:
		for id in _layer_to_actor_ids.get(layer, []):
			var actor:BaseActor = parent_map._game_state.get_actor(id)
			if include_dead or not actor.is_dead:
				out_list.append(actor)
	else:
		for l in _layer_to_actor_ids.keys():
			for id in _layer_to_actor_ids.get(l, []):
				var actor:BaseActor = parent_map._game_state.get_actor(id, true)
				if include_dead or not actor.is_dead:
					out_list.append(actor)
	return out_list

func get_actor_layer(actor:BaseActor)->MapStateData.MapLayers:
	for layer in _layer_to_actor_ids.keys():
		if _layer_to_actor_ids[layer].has(actor.Id):
			return layer
	printerr("MapSpot.get_actor_layer: Failed to find actor '%s'." % [actor.Id])
	return MapStateData.DEFAULT_ACTOR_LAYER

func add_item(item:BaseItem):
	if item_ids.has(item.Id):
		return
	item_ids.append(item.Id)

func get_items()->Array:
	var out_list = []
	for item_id in item_ids:
		var item = ItemLibrary.get_item(item_id)
		if !item:
			item_ids.erase(item_id)
		else:
			out_list.append(item)
	return out_list

func remove_item(item:BaseItem):
	if item_ids.has(item.Id):
		item_ids.erase(item.Id)

func add_zone(zone:BaseZone):
	if _zone_ids.has(zone.Id):
		return
	_zone_ids.append(zone.Id)

func remove_zone(zone:BaseZone):
	if _zone_ids.has(zone.Id):
		_zone_ids.erase(zone.Id)

func get_zones()->Array:
	var out_list = []
	for z in _zone_ids:
		out_list.append(parent_map._game_state.Zones[z])
	return out_list
		
