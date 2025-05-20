class_name MapHelper

static func rotate_relative_pos(pos, direction) -> Vector2i:
	match direction:
		0: # North
			printerr("fhdfhsne: (%s,%s) x %s => %s" % [pos.x, pos.y, direction, Vector2i(pos.x, pos.y)])
			return Vector2i(pos.x, pos.y)
		1: # East
			printerr("fhdfhsne: (%s,%s) x %s => %s" % [pos.x, pos.y, direction, Vector2i(-pos.y, pos.x)])
			return Vector2i(-pos.y, pos.x)
		2: # South
			printerr("fhdfhsne: (%s,%s) x %s => %s" % [pos.x, pos.y, direction, Vector2i(-pos.x, -pos.y)])
			return Vector2i(-pos.x, -pos.y)
		3: # West
			printerr("fhdfhsne: (%s,%s) x %s => %s" % [pos.x, pos.y, direction, Vector2i(pos.y, -pos.x)])
			return Vector2i(pos.y, -pos.x)
	return Vector2i(pos.x, pos.y)

static func get_map_pos_global_position(map_pos:MapPos)->Vector2:
	var map_control = CombatRootControl.Instance.MapController
	var global_pos = map_control.position + map_control.actor_tile_map.map_to_local(Vector2i(map_pos.x, map_pos.y))
	return global_pos

static func get_actor_global_position(actor:BaseActor)->Vector2:
	var map_pos = CombatRootControl.Instance.GameState.get_actor_pos(actor)
	if !map_pos:
		printerr("MapHelper.get_actor_local_position: Failed to find actor's MapPos")
		return Vector2.ZERO
	var map_control = CombatRootControl.Instance.MapController
	var global_pos = map_control.position + map_control.actor_tile_map.map_to_local(Vector2i(map_pos.x, map_pos.y))
	return global_pos

static func get_adjacent_actors(game_state:GameStateData, actor:BaseActor)->Array:
	var out_arr = []
	var center_pos = game_state.get_actor_pos(actor)
	if not center_pos:
		return out_arr
	for adj_pos in get_adjacent_poses(center_pos):
		for adj_actor in game_state.get_actors_at_pos(adj_pos):
			if not out_arr.has(adj_actor):
				out_arr.append(adj_actor)
	return out_arr

static func get_adjacent_poses(pos:MapPos)->Array:
	var out_arr = []
	for y in range(-1,1+1):
		for x in range(-1,1+1):
			if x == 0 and y == 0:
				continue
			var new_pos = MapPos.new(pos.x + x, pos.y + y, pos.z, pos.dir)
			out_arr.append(new_pos)
	return out_arr

static func get_center_of_points(array:Array)->Vector2i:
	if !array or array.size() == 0:
		return Vector2i.ZERO
	var min_x = array[0].x
	var max_x = array[0].x
	var min_y = array[0].y
	var max_y = array[0].y
	for spot in array:
		if spot.x > max_x: max_x = spot.x
		if spot.x < min_x: min_x = spot.x
		if spot.y > max_y: max_y = spot.y
		if spot.y < min_y: min_y = spot.y
	return Vector2i((max_x + min_x) / 2, (max_y + min_y) / 2)
