class_name MapHelper

static func rotate_relative_pos(pos, direction) -> Vector2i:
	match direction:
		0: # North
			return Vector2i(pos.x, pos.y)
		1: # East
			return Vector2i(-pos.y, -pos.x)
		2: # South
			return Vector2i(-pos.x, -pos.y)
		3: # West
			return Vector2i(pos.y, pos.x)
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
