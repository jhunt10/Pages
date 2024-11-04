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
