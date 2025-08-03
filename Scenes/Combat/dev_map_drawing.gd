extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	queue_redraw()
	pass


func _draw() -> void:
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
			draw_line(last_coor, coor, Color.LIGHT_BLUE, 4.0)
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
		draw_line(last_coor, facing_coor, Color.BLUE, 4.0)
	
	for actor_id in CombatRootControl.Instance.GameState._actors.keys():
		var actor = CombatRootControl.Instance.GameState.get_actor(actor_id, false)
		if not actor or actor.is_player:
			continue
		var actor_node = CombatRootControl.get_actor_node(actor_id)
		if not actor_node:
			continue
		var aggro_id = actor.aggro.get_current_aggroed_actor_id()
		if aggro_id == '':
			continue
		var aggro_node = CombatRootControl.get_actor_node(aggro_id)
		if not aggro_node:
			continue
		
		draw_dashed_line(actor_node.position, aggro_node.position, Color(1,0,0,0.5), 4.0, 2)
