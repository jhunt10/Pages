class_name AreaMatrix

# List of Vec2i points relative to center
var relative_points:Array = []

func _init(points : Array):
	for p in points:
		relative_points.append(Vector2i(p[0], -p[1]))

func to_map_spots(pos:MapPos)->Array:
	var out_arr = []
	for p in relative_points:
		var spot = Vector2i(pos.x, pos.y) + MapHelper.rotate_relative_pos(p, pos.dir)
		out_arr.append(spot)
	return out_arr
