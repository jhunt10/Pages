class_name AreaMatrix

# List of Vec2i points relative to center
var relative_points:Array = []

func _init(points):
	if points is String:
		points = JSON.parse_string(points)
	for p in points:
		relative_points.append(Vector2i(p[0], -p[1]))
	var org_size = relative_points.size()
	var distinct = []
	for p in relative_points:
		if not distinct.has(p):
			distinct.append(p)
	var dist_size = distinct.size()
	if dist_size != org_size:
		printerr("Non-Distinct Area Matrix loaded.")
		relative_points = distinct

# Returns Array of Vector2i points in AreaMatrix
func to_map_spots(pos:MapPos)->Array:
	var out_arr = []
	for p in relative_points:
		var spot = Vector2i(pos.x, pos.y) + MapHelper.rotate_relative_pos(p, pos.dir)
		out_arr.append(spot)
	return out_arr
