class_name MapStateData

const LOGGING = false

enum MapLayers {Default, Corpse, Totem}

var _game_state
# Actor.Id to MapPos
var _actor_pos_cache:Dictionary = {}
# Item.Id to MapPos
var _item_pos_cache:Dictionary = {}
# Zone.Id to Array<MapPos>
var _zone_poses_cache:Dictionary = {}
# Array of MapSpot index by coor
var _position_data:Array = []
var terrain_data:Array
var max_width = 0
var max_hight = 0

func duplicate(new_game_state)->MapStateData:
	var map_data = {
		'Width': max_width,
		'Hight': max_hight,
		'Terrain': terrain_data.duplicate(true)
	}
	var new_map = MapStateData.new(new_game_state, map_data, true)
	for spot:MapSpot in _position_data:
		if spot.X == 7 and spot.Y == 7:
			print("Had 77 Had: %s" % [spot])
		var new_spot = spot.duplicate(new_map)
		if new_spot.X == 7 and new_spot.Y == 7:
			print("Dupped 77 SPot: %s to %s" % [spot, new_spot])
		new_map._position_data.append(spot.duplicate(new_map))
	new_map._actor_pos_cache = _actor_pos_cache.duplicate(true)
	new_map._item_pos_cache = _item_pos_cache.duplicate(true)
	print("Dupped MapState %s to %s" %[self, new_map])
	return new_map


func _init(game_state, map_data:Dictionary, wait_for_pos_data:bool=false) -> void:
	_game_state = game_state
	max_width = map_data['Width']
	max_hight = map_data['Hight']
	_position_data = []
	terrain_data = map_data['Terrain']
	if not wait_for_pos_data:
		for y in range(max_hight):
			for x in range(max_width):
				_position_data.append(MapSpot.new(x,y,terrain_data[y][x], self))
			
func get_map_spot(pos)->MapSpot:
	if pos.x < 0 or pos.x >= max_width or pos.y < 0 or pos.y >= max_hight:
		#printerr("MapState.get_map_spot Invalid Position: " + str(pos))
		return null
	var spot = _position_data[pos.x + (pos.y * max_width)]
	if spot.X != pos.x and spot.Y != pos.y:
		printerr("Miss-Ordered Map Spots")
	return spot

func list_map_spots()->Array:
	return _position_data

func spot_blocks_los(pos)->bool:
	var spot = get_map_spot(pos)
	if not spot:
		return false
	for actor:BaseActor in spot.get_actors():
		if actor.stats.get_stat("BlocksLOS", 0) > 0:
			return true
	return spot.terrain_index == 0

func get_terrain_at_pos(pos):
	var spot = get_map_spot(pos)
	if not spot:
		return -1
	return spot.terrain_index 
	
func is_spot_traversable(pos, actor)->bool:
	var spot = get_map_spot(pos)
	if not spot:
		print("Failed to find spot at pos: %s" % [pos])
		return false
	if spot.terrain_index == 0:
		return false
	if spot.terrain_index == 1:
		return false
	return true
	

func is_spot_open(pos, ignore_actor_ids:Array=[])->bool:
	if not is_spot_traversable(pos, null):
		return false
	var actors = get_actors_at_pos(pos)
	for actor in actors:
		if not ignore_actor_ids.has(actor.Id):
			print("Actors found on spot")
			return false
	return true

# ----------------------------- Actors -----------------------------

func get_actors_at_pos(pos, layer=null, include_dead:bool=false)->Array:
	var spot:MapSpot = get_map_spot(pos)
	if layer == MapLayers.Corpse and include_dead == false:
		include_dead = true
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
	set_actor_map_pos(actor, current_pos, true, layer)


# Does not handle logic items or zones
func set_actor_map_pos(actor:BaseActor, pos:MapPos, supress_signal:bool=false, layer:MapLayers=MapLayers.Default):
	if LOGGING: print("Set Actor Pos")
	if pos.x < 0 or pos.x >= max_width or pos.y < 0 or pos.y >= max_hight:
		printerr("set_actor_pos: Invalid Actor Position: " + str(pos))
		return
	
	var old_pos = null
	# Check if already has position
	if _actor_pos_cache.has(actor.Id):
		# Bail if no change
		if _actor_pos_cache[actor.Id] == pos:
			#var cur_layer = get_actor_layer(actor)
			#if cur_layer == layer:
				return
		# Delete old position data and cached position
		old_pos = _actor_pos_cache[actor.Id]
		var old_spot = get_map_spot(old_pos)
		old_spot.remove_actor(actor)
		_actor_pos_cache.erase(actor.Id)
		
	# Set new position (Actor.DisplayPos is updated after frame)
	var new_spot = get_map_spot(pos)
	new_spot.add_actor(actor, layer)
	_actor_pos_cache[actor.Id] = pos
	
	if not supress_signal:
		if LOGGING: printerr("Emit Move: " + str(old_pos) + " | " + str(pos))
		actor.on_move.emit(old_pos, pos, {"MoveType": "Test", "MovedBy":null})

func remove_actor(actor:BaseActor):
	if _actor_pos_cache.has(actor.Id):
		var old_pos = _actor_pos_cache[actor.Id]
		var old_spot = get_map_spot(old_pos)
		old_spot.remove_actor(actor)
		_actor_pos_cache.erase(actor.Id)

# ----------------------------- Items -----------------------------

func list_items()->Array:
	var out_list = []
	for item_id in _item_pos_cache.keys():
		var item = ItemLibrary.get_item(item_id)
		if item:
			out_list.append(item)
	return out_list

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

func get_items_at_pos(pos)->Array:
	var map_spot = get_map_spot(pos)
	return map_spot.item_ids.duplicate()

func get_item_pos(item:BaseItem):
	return _item_pos_cache.get(item.Id, null)

# ----------------------------- Zones -----------------------------
func add_zone(zone:BaseZone):
	if _zone_poses_cache.has(zone.Id):
		printerr("MapState.add_zone: Zone already added: %s" % [zone.Id])
		return
	_zone_poses_cache[zone.Id] = []
	for p in zone.get_area():
		var spot = get_map_spot(p)
		spot.add_zone(zone)
		_zone_poses_cache[zone.Id].append(p)

# Updates spots and recaches poses to current zone.get_area().
# Does not handle logic for actors entering/exiting Zone 
func update_zone_pos(zone:BaseZone):
	if not _zone_poses_cache.has(zone.Id):
		printerr("MapState.update_zone_pos: Unknown Zone: %s" % [zone.Id])
		return
	var old_poses = _zone_poses_cache[zone.Id] 
	var new_poses = zone.get_area()
	
	for pos in old_poses:
		if not new_poses.has(pos):
			var spot = get_map_spot(pos)
			spot.remove_zone(zone.Id)
	_zone_poses_cache[zone.Id].clear()
	for pos in new_poses:
		if not old_poses.has(pos):
			var spot = get_map_spot(pos)
			spot.add_zone(zone)
			_zone_poses_cache[zone.Id].append(pos)

func remove_zone(zone_id):
	if not _zone_poses_cache.has(zone_id):
		printerr("MapState.delete_zone: Unknown Zone: %s" % [zone_id])
		return
	for p in _zone_poses_cache[zone_id]:
		var spot = get_map_spot(p)
		spot.remove_zone(zone_id)
	_zone_poses_cache[zone_id].clear()

func get_zones_ids_at_pos(pos)->Array:
	if not pos:
		return []
	var spot = get_map_spot(pos)
	return spot.get_zones()

func get_actors_in_zone(zone_id:String)->Array:
	if not _zone_poses_cache.has(zone_id):
		printerr("MapState.get_actor_ids_in_zone: Unknown Zone.Id: %s" % [zone_id])
		return []
	var zone_poses = _zone_poses_cache[zone_id]
	var out_list = []
	for pos in zone_poses:
		var actors = get_actors_at_pos(pos)
		out_list.append_array(actors)
	return out_list
		
