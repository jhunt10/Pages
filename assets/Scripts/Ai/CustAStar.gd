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

#func _compute_cost(from_id: int, to_id: int) -> float:
	##var cost = super(from_id, to_id)
	#return cost


static func _index_to_pos(pos_index:int)->MapPos:
	var decode_pos = MapPos.new(0,0,0,0)
	decode_pos.dir = pos_index % 4
	pos_index = pos_index >> 2
	decode_pos.y = pos_index % 256
	pos_index = pos_index >> 8
	decode_pos.x = pos_index
	return decode_pos
