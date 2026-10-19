class_name PathFinder
extends AStar3D


func _compute_cost(from_id: int, to_id: int) -> float:
	var from_coor = get_point_position(from_id)
	var to_coor = get_point_position(to_id)
	if from_coor.x == to_coor.x and from_coor.y == to_coor.y:
		return 1.5
	else:
		return 1

func _estimate_cost(from_id: int, end_id: int) -> float:
	var from_coor = get_point_position(from_id)
	var end_coor = get_point_position(end_id)
	var dist = abs(from_coor.x - end_coor.x) + abs(from_coor.y - end_coor.y)
	if from_coor.z != end_coor.z:
		dist = dist * 1.5
	return dist

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


static func build_path_finder(game_state:GameStateData)->PathFinder:
	var path_finder = PathFinder.new()
	path_finder.reserve_space(game_state.map_hight * game_state.map_width * MapPos.Directions.keys().size())
	for y in range(game_state.map_hight):
		for x in range(game_state.map_width):
			
			if not game_state.is_spot_traversable(Vector2i(x, y)):
				continue
			
			# Add a cell for each dir at this coor
			for dir in range(MapPos.Directions.keys().size()):
				var cell = Vector3i(x,y,dir)
				var pos = MapPos.new(x,y,0, dir)
				
				var index = _pos_to_index(pos)
				if not path_finder.has_point(index):
					path_finder.add_point(index, cell)
				
				# Connect pos if moved forward
				var forward_pos:MapPos = null
				match(dir):
					0: forward_pos = MapPos.new(x, y-1, 0, MapPos.Directions.North)
					1: forward_pos = MapPos.new(x+1, y, 0, MapPos.Directions.East)
					2: forward_pos = MapPos.new(x, y+1, 0, MapPos.Directions.South)
					3: forward_pos = MapPos.new(x-1, y, 0, MapPos.Directions.West)
				if game_state.map_data.has_spot(forward_pos) and game_state.is_spot_traversable(pos):
					var forward_index = _pos_to_index(forward_pos)
					if not path_finder.has_point(forward_index):
							path_finder.add_point(forward_index, Vector3i(forward_pos.x,forward_pos.y,forward_pos.dir))
					path_finder.connect_points(index, forward_index, false)
				
				# Connect pos if turned right
				var turn_right_pos = MapPos.new(x, y, 0, (dir+1)%4)
				var turn_right_index = _pos_to_index(turn_right_pos)
				if not path_finder.has_point(turn_right_index):
					path_finder.add_point(turn_right_index, Vector3i(turn_right_pos.x,turn_right_pos.y,turn_right_pos.dir))
				path_finder.connect_points(index, turn_right_index, true)
				
				# Connect pos if turned left (handled by looping through all turn-rights)
				#var turn_left_pos = MapPos.new(x, y, 0, (dir-1+4)%4)
				#var turn_left_index = _pos_to_index(turn_left_pos)
				#if not path_finder.has_point(turn_left_index):
					#path_finder.add_point(turn_left_index, Vector3i(turn_left_pos.x,turn_left_pos.y,turn_left_pos.dir))
				#path_finder.connect_points(index, turn_left_index)
				
			
	return path_finder


func get_pos_path(from_pos:MapPos, to_pos:MapPos)->Array:
	var from_index = _pos_to_index(from_pos)
	var to_index = _pos_to_index(to_pos)
	var has_from = has_point(from_index)
	var has_to = has_point(to_index)
	var point_path = []
	if has_from and has_to:
		point_path = get_point_path(from_index, to_index)
	return point_path

func get_move_action_path(from_pos:MapPos, to_pos:MapPos)->Array:
	var pos_path = get_pos_path(from_pos, to_pos)
	var action_path = []
	var last_pos = null
	for cur_pos in pos_path:
		if last_pos == null:
			last_pos = cur_pos
			continue
		# Turning
		if cur_pos.x == last_pos.x and cur_pos.y == last_pos.y:
			if last_pos.z == 0 and cur_pos.z == 3:
				action_path.append("TurnLeft")
			elif  last_pos.z == 3 and cur_pos.z == 0:
				action_path.append("TurnRight")
			elif last_pos.z > cur_pos.z:
				action_path.append("TurnLeft")
			else:
				action_path.append("TurnRight")
		else:
			action_path.append("Forward")
		last_pos = cur_pos 
	return action_path
				
				
			
