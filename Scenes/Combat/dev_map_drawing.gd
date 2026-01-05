extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	queue_redraw()
	pass


func _draw() -> void:
	
	draw_astar_map()
	 #Draw Paths
	for action_que:ActionQue in CombatRootControl.QueController._action_ques.values():
		var actor_node = CombatRootControl.get_actor_node(action_que.actor.Id)
		if not actor_node:
			continue
		var tile_map:TileMapLayer = actor_node.get_parent()
		var last_coor = actor_node.position 
		var last_pos = actor_node.cur_map_pos 
		var previw_path = action_que.get_movement_preview_path()
		for pos:MapPos in previw_path:
			var coor = tile_map.map_to_local(pos.to_vector2i()) 
			draw_line(last_coor, coor, Color.BLUE, 4.0)
			last_coor = coor
			last_pos = pos
		
		var facing_coor = last_coor
		if last_pos.dir == MapPos.Directions.North:
			facing_coor.y -= 16
		if last_pos.dir == MapPos.Directions.South:
			facing_coor.y += 16
		if last_pos.dir == MapPos.Directions.West:
			facing_coor.x -= 16
		if last_pos.dir == MapPos.Directions.East:
			facing_coor.x += 16
		draw_line(last_coor, facing_coor, Color.RED, 4.0)
	
	for actor in CombatRootControl.Instance.GameState.list_actors():
		if not actor or actor.is_player:
			continue
		var actor_node = CombatRootControl.get_actor_node(actor.Id)
		if not actor_node:
			continue
		var aggro_id = actor.aggro.get_current_aggroed_actor_id()
		if aggro_id == '':
			continue
		var aggro_node = CombatRootControl.get_actor_node(aggro_id)
		if not aggro_node:
			continue
		
		draw_dashed_line(actor_node.position, aggro_node.position, Color(1,0,0,0.5), 4.0, 2)
		
	
func draw_astar_map():
	var astar = AiHandler.astar
	if astar:
		for index in astar.get_point_ids():
			var map_pos = astar._index_to_pos(index)
			var draw_point = get_map_pos_dir_point(map_pos)
			for connected_index in astar.get_point_connections(index):
				var other_pos = astar._index_to_pos(connected_index)
				var other_draw_point = get_map_pos_dir_point(other_pos)
				if other_pos.x == map_pos.x and other_pos.y == map_pos.y:
					draw_line(draw_point, other_draw_point, Color.WHITE, 2)
				else:
					draw_line(draw_point, other_draw_point, Color.LIGHT_GREEN, 2)
				#draw_circle(other_draw_point, 3, Color.BLUE)
			if astar.is_occupied(index):
				draw_circle(draw_point, 3, Color.RED)
			else:
				draw_circle(draw_point, 3, Color.BLUE)
		#for y in range(CombatRootControl.Instance.GameState.map_hight):
			#for x in range(CombatRootControl.Instance.GameState.map_width):
				#var map_pos = MapPos.new(x, y, 0, 0)
				#var index = AiHandler._pos_to_index(map_pos)
				#
				#if not astar.has_point(index):
					#continue
				#
				#var position = CombatRootControl.Instance.MapController.actor_tile_map.map_to_local(Vector2i(x,y))
				#
				#for dir in MapPos.Directions.values():
					##if dir == 1:
						##continue
					#var other_vec = MapHelper.get_vect_in_dir(map_pos, dir)
					#var other_map_pos = MapPos.new(other_vec.x, other_vec.y, 0, dir)
					#var other_index = AiHandler._pos_to_index(other_map_pos)
					#var other_position = CombatRootControl.Instance.MapController.actor_tile_map\
														#.map_to_local(other_map_pos.to_vector2i())
					#
					#var half_point = position + ((other_position- position) / 2.5)
					#if astar.are_points_connected(index, other_index, false):
						#draw_line(position, half_point, Color.LIGHT_GREEN, 8)
					#else:
						#draw_line(position, half_point, Color.DARK_RED, 10)
				#
				#draw_circle(position, 8, Color.BLUE)
				#if astar.is_point_disabled(index):
					#draw_circle(position, 10, Color.RED)

func get_map_pos_dir_point(map_pos:MapPos):
	var tile_map = CombatRootControl.Instance.MapController.actor_tile_map
	var center_position = tile_map.map_to_local(Vector2i(map_pos.x,map_pos.y))
	var other_vert = MapHelper.get_vect_in_dir(map_pos, map_pos.dir)
	var other_position = tile_map.map_to_local(other_vert)
	
	var half_point = center_position + ((other_position- center_position) / 4)
	return half_point
				
	
