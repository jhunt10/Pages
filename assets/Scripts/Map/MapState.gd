class_name MapStateData

const LOGGING = false

const DEFAULT_ACTOR_LAYER = MapLayers.Default

enum MapLayers {Default, Corpse, Totem}

var _game_state:GameStateData
var _actor_pos_cache:Dictionary = {}
var _item_pos_cache:Dictionary = {}
var _position_data:Array = []
var max_width = 0
var max_hight = 0

func _init(game_state:GameStateData, map_data:Dictionary) -> void:
	_game_state = game_state
	max_width = map_data['Width']
	max_hight = map_data['Hight']
	_position_data = []
	var terrain_data = map_data['Terrain']
	for y in range(max_hight):
		for x in range(max_width):
			_position_data.append(MapSpot.new(x,y,terrain_data[y][x], self))
			
func get_map_spot(pos)->MapSpot:
	if pos.x < 0 or pos.x >= max_width or pos.y < 0 or pos.y >= max_hight:
		#printerr("MapState.get_map_spot Invalid Position: " + str(pos))
		return null
	return _position_data[pos.x + (pos.y * max_width)]

func list_map_spots()->Array:
	return _position_data

func spot_blocks_los(pos)->bool:
	var spot = get_map_spot(pos)
	if not spot:
		return false
	return spot.terrain_index == 0

func is_spot_open(pos)->bool:
	var spot = get_map_spot(pos)
	if not spot:
		print("Failed to find spot at pos: %s" % [pos])
		return false
	if spot.terrain_index == 0:
		#print("Pos: %s | Terrain > 0" % [pos])
		#for y in range(max_hight):
			#var line = ""
			#for x in range(max_width):
				#var val = self.get_map_spot(Vector2i(x, y))
				#line += "(" + str(val.X) + "," + str(val.Y) + ")," 
			#print(line.trim_suffix(","))
				
		return false
	var actors = get_actors_at_pos(pos)
	if actors.size() > 0:
		print("Actors found on spot")
		return false
	return true

# ----------------------------- Actors -----------------------------

func get_actors_at_pos(pos, layer=null, include_dead:bool=false)->Array:
	var spot:MapSpot = get_map_spot(pos)
	if spot:
		return spot.get_actors(layer, include_dead)
	return []
		
func get_actor_pos(actor:BaseActor)->MapPos:
	return _actor_pos_cache.get(actor.Id, null)

func get_actor_layer(actor:BaseActor)->MapLayers:
	var pos = get_actor_pos(actor)
	if not pos:
		printerr("MapStateData.get_actor_layer: Failed to MapPos for actor '%s'." % [actor.Id])
		return MapLayers.Default
	var spot = get_map_spot(pos)
	if not pos:
		printerr("MapStateData.get_actor_layer: Failed to MapSpot for pos %s." % [pos])
		return MapLayers.Default
	return spot.get_actor_layer(actor)
	
func set_actor_layer(actor:BaseActor, layer:MapLayers):
	var current_pos = get_actor_pos(actor)
	if not current_pos:
		printerr("MapStateData.set_actor_layer: Failed to MapPos for actor '%s'." % [actor.Id])
		return
	set_actor_pos(actor, current_pos, layer)

func set_actor_pos(actor:BaseActor, pos:MapPos, layer=DEFAULT_ACTOR_LAYER):
	if LOGGING: print("Set Actor Pos")
	if pos.x < 0 or pos.x >= max_width or pos.y < 0 or pos.y >= max_hight:
		printerr("MapState.set_actor_pos: Invalid Actor Position: " + str(pos))
		return
	
	var old_pos = null
	# Check if already has position
	if _actor_pos_cache.has(actor.Id):
		# Bail if no change
		if _actor_pos_cache[actor.Id] == pos:
			var cur_layer = get_actor_layer(actor)
			if cur_layer == layer:
				return
		# Delete old position data and cached position
		old_pos = _actor_pos_cache[actor.Id]
		var old_spot = get_map_spot(old_pos)
		on_actor_exit_spot(actor, old_pos, old_spot, pos)
		old_spot.remove_actor(actor)
		_actor_pos_cache.erase(actor.Id)
		
	# Set new position (Actor.DisplayPos is updated after frame)
	var new_spot = get_map_spot(pos)
	new_spot.add_actor(actor, layer)
	_actor_pos_cache[actor.Id] = pos
	
	if LOGGING: printerr("Emit Move: " + str(old_pos) + " | " + str(pos))
	actor.on_move.emit(old_pos, pos, {"MoveType": "Test", "MovedBy":null})
	on_actor_enter_spot(actor, pos, new_spot)

func remove_actor(actor:BaseActor):
	if _actor_pos_cache.has(actor.Id):
		var old_pos = _actor_pos_cache[actor.Id]
		var old_spot = get_map_spot(old_pos)
		old_spot.remove_actor(actor)
		_actor_pos_cache.erase(actor.Id)

## Holds all logic that triggers when an actor enters a map spot
func on_actor_enter_spot(actor:BaseActor, map_pos:MapPos, map_spot:MapSpot):
	if actor.is_player:
		var items = map_spot.get_items()
		for item in items:
			if ItemHelper.try_pickup_item(actor, item):
				printerr("\nPicked Up Item: %s\n" % [item.Id])

## Holds all logic that triggers when an actor enters a map spot
func on_actor_exit_spot(actor:BaseActor, map_pos:MapPos, map_spot:MapSpot, moving_to_pos:MapPos):
	pass
	

# ----------------------------- Items -----------------------------

func set_item_pos(item:BaseItem, pos):
	remove_item(item)
	var map_spot = get_map_spot(pos)
	if !map_spot:
		return
	map_spot.add_item(item)
	var safe_pos = MapPos.new(pos.x, pos.y, 0, 0)
	_item_pos_cache[item.Id] = safe_pos

func remove_item(item:BaseItem):
	var old_pos = _item_pos_cache.get(item.Id, null)
	if old_pos:
		var old_spot = get_map_spot(old_pos)
		old_spot.remove_item(item)
		_item_pos_cache.erase(item.Id)

func get_items_at_pos(pos):
	var map_spot = get_map_spot(pos)
	return map_spot.item_ids.duplicate()

func get_item_pos(item:BaseItem):
	return _item_pos_cache.get(item.Id, null)

# ----------------------------- Zones -----------------------------
func _handle_enter_exit_zone(actor:BaseActor, old_pos:MapPos, new_pos:MapPos):
	var old_zones = get_map_spot(old_pos).get_zones()
	var new_zones = get_map_spot(new_pos).get_zones()
	
	var exiting_zones = []
	var entering_zones = []
	for z in old_zones:
		if !new_zones.has(z):
			exiting_zones.append(z)
	for z in new_zones:
		if !old_zones.has(z):
			entering_zones.append(z)
	for z:BaseZone in exiting_zones:
		z.on_actor_exit(actor)
	for z:BaseZone in entering_zones:
		z.on_actor_enter(actor)
	
func add_zone(zone:BaseZone):
	for p in zone.get_area():
		var spot = get_map_spot(p)
		spot.add_zone(zone)
	zone.on_create(self)
