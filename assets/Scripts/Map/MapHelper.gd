class_name MapHelper

static func rotate_relative_pos(point : Vector2i, direction) -> Vector2i:
	match direction:
		0: # North
			return Vector2i(point.x, point.y)
		1: # East
			return Vector2i(-point.y, -point.x)
		2: # South
			return Vector2i(-point.x, -point.y)
		3: # West
			return Vector2i(point.y, point.x)
	return Vector2i(point.x, point.y)
