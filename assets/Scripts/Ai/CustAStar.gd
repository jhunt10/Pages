class_name CustAStar
extends AStar2D

var map_width:int
var allow_slide = false

var occupied_indexes = []

func _compute_cost(from_id: int, to_id: int):
	var from_pos = _index_to_pos(from_id)
	var to_pos = _index_to_pos(to_id)
	var x_change = to_pos.x - from_pos.x
	var y_change = to_pos.y - from_pos.y
	var dist = abs(x_change) + abs(y_change)
	# Different Directions : +1
	if from_pos.dir != to_pos.dir:
		dist += 1
	if not allow_slide:
		# Facing North but not moving Up
		if from_pos.dir == MapPos.Directions.North and not (y_change < 0): dist += 1
		# Facing South  but not moving Down
		elif from_pos.dir == MapPos.Directions.South and not (y_change > 0): dist += 1
		# Facing West but not moving Left
		elif from_pos.dir == MapPos.Directions.West  and not (x_change < 0): dist += 1
		# Facing East but not moving Right
		elif from_pos.dir == MapPos.Directions.East  and not (x_change > 0): dist += 1
	if occupied_indexes.has(to_id):
		dist += 100
	return dist

func _estimate_cost(from_id: int, to_id: int):
	var from_pos = _index_to_pos(from_id)
	var to_pos = _index_to_pos(to_id)
	var dist = abs(from_pos.x - to_pos.x) + abs(from_pos.y - to_pos.y)
	if occupied_indexes.has((to_id)):
		dist += 100
	return min(0, dist -1)

#func get_cost_to_pos(from_pos:MapPos, to_pos:MapPos)->int:
	#var dist = abs(from_pos.x - to_pos.x) + abs(from_pos.y - to_pos.y)
	#return min(0, dist -1)

#func _compute_cost(from_id: int, to_id: int) -> float:
	##var cost = super(from_id, to_id)
	#return cost

func add_map_point(pos):
	var coor = Vector2i(pos.x, pos.y)
	var same_pos_indexes = []
	# Create points for each direction
	for dir in MapPos.Directions.values():
		var map_pos = MapPos.new(coor.x, coor.y, 0, dir)
		var index = _pos_to_index(map_pos)
		if not self.has_point(index):
			self.add_point(index, coor, 1)
		# Connect other points at some position
		for other_dir_index in same_pos_indexes:
			if not self.are_points_connected(index, other_dir_index, true):
				self.connect_points(index, other_dir_index, true)
		same_pos_indexes.append(index)

func connect_map_points(from_pos, to_pos, bidirectional=true):
	var y_change = to_pos.y - from_pos.y
	var x_change = to_pos.x - from_pos.x
	# Check if valid connection
	if ((y_change != 0 and x_change != 0 ) or # Diagnal
		( y_change == 0 and x_change == 0) or  # Same Spot
		(abs(y_change) > 1 or abs(x_change) > 1) ): # Not Adjacent
			print("CustAStart: Attempted invalid point connection: %s to %s" % [from_pos, to_pos])
			return
	# Conncting from North to South
	if y_change < 0:
		var from_index = _pos_to_index(MapPos.new(from_pos.x, from_pos.y, 0, MapPos.Directions.North))
		var to_index = _pos_to_index(MapPos.new(to_pos.x, to_pos.y, 0, MapPos.Directions.South))
		if self.has_point(from_index) and self.has_point(to_index):
			self.connect_points(from_index, to_index, bidirectional)
	# from South to North
	elif y_change > 0:
		var from_index = _pos_to_index(MapPos.new(from_pos.x, from_pos.y, 0, MapPos.Directions.South))
		var to_index = _pos_to_index(MapPos.new(to_pos.x, to_pos.y, 0, MapPos.Directions.North))
		if self.has_point(from_index) and self.has_point(to_index):
			self.connect_points(from_index, to_index, bidirectional)
	
	# Conncting from West to East
	if x_change < 0:
		var from_index = _pos_to_index(MapPos.new(from_pos.x, from_pos.y, 0, MapPos.Directions.West))
		var to_index = _pos_to_index(MapPos.new(to_pos.x, to_pos.y, 0, MapPos.Directions.East))
		if self.has_point(from_index) and self.has_point(to_index):
			self.connect_points(from_index, to_index, bidirectional)
	# from East to West
	elif x_change > 0:
		var from_index = _pos_to_index(MapPos.new(from_pos.x, from_pos.y, 0, MapPos.Directions.East))
		var to_index = _pos_to_index(MapPos.new(to_pos.x, to_pos.y, 0, MapPos.Directions.West))
		if self.has_point(from_index) and self.has_point(to_index):
			self.connect_points(from_index, to_index, bidirectional)
		

func enable_all_points():
	#print("CustStar: Enabling All Points")
	occupied_indexes.clear()
	for point in get_point_ids():
		self.set_point_disabled(point, false)

func set_pos_disabled(pos, disabled):
	#print("CustStar: Disable Point: %s" % [pos])
	for dir in MapPos.Directions.values():
		var index = _pos_to_index(MapPos.new(pos.x, pos.y, 0, dir))
		if not self.has_point(index):
			printerr("CustStarset_pos_disabled: Position %s not found." % [pos])
		else:
			if disabled:
				occupied_indexes.append(index)
			else:
				occupied_indexes.erase(index)
			#self.set_point_disabled(index, disabled)
func is_occupied(val):
	if val is Vector2i:
		val = MapPos.Vector2i(val)
	if val is MapPos :
		val = _pos_to_index(val)
	return occupied_indexes.has(val)

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
