class_name CustAStar
extends AStar2D

var map_width:int
var allow_slide = false

func _compute_cost(from_id: int, to_id: int):
	var from_pos = _index_to_pos(from_id)
	var to_pos = _index_to_pos(to_id)
	var dist = abs(from_pos.x - to_pos.x) + abs(from_pos.y - to_pos.y)
	if from_pos.dir != to_pos.dir:
		dist += 1
	if not allow_slide:
		if from_pos.dir == MapPos.Directions.North:
			if to_pos.y >= from_pos.y:
				dist += 1
		elif from_pos.dir == MapPos.Directions.South:
			if to_pos.y <= from_pos.y:
				dist += 1
		elif from_pos.dir == MapPos.Directions.West:
			if to_pos.x >= from_pos.x:
				dist += 1
		elif from_pos.dir == MapPos.Directions.East:
			if to_pos.x <= from_pos.x:
				dist += 1
	return dist

func _estimate_cost(from_id: int, to_id: int):
	var from_pos = _index_to_pos(from_id)
	var to_pos = _index_to_pos(to_id)
	var dist = abs(from_pos.x - to_pos.x) + abs(from_pos.y - to_pos.y)
	return min(0, dist -1)

func get_cost_to_pos(from_pos:MapPos, to_pos:MapPos)->int:
	var dist = abs(from_pos.x - to_pos.x) + abs(from_pos.y - to_pos.y)
	return min(0, dist -1)

#func _compute_cost(from_id: int, to_id: int) -> float:
	##var cost = super(from_id, to_id)
	#return cost


func enable_all_points():
	#print("CustStar: Enabling All Points")
	for point in get_point_ids():
		self.set_point_disabled(point, false)

func set_pos_disabled(pos, disabled):
	#print("CustStar: Disable Point: %s" % [pos])
	for dir in MapPos.Directions.values():
		var index = _pos_to_index(MapPos.new(pos.x, pos.y, 0, dir))
		if not self.has_point(index):
			printerr("CustStarset_pos_disabled: Position %s not found." % [pos])
		else:
			self.set_point_disabled(index, disabled)


static func _pos_to_index(pos:MapPos)->int:
	var pos_index = pos.x
	pos_index = pos_index << 8
	pos_index += pos.y
	pos_index = pos_index << 2
	pos_index += pos.dir
	return pos_index
	#return (pos.x + (pos.y * game_state.map_width)) * 10 + pos.dir

static func _index_to_pos(pos_index:int)->MapPos:
	var decode_pos = MapPos.new(0,0,0,0)
	decode_pos.dir = pos_index % 4
	pos_index = pos_index >> 2
	decode_pos.y = pos_index % 256
	pos_index = pos_index >> 8
	decode_pos.x = pos_index
	return decode_pos
