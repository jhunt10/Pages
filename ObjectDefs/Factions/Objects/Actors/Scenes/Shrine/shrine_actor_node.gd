class_name ShrineActorNode
extends BaseActorNode

func play_spawn_animation(actor:BaseActor, game_state:GameStateData):
	body_animation.play("flash")
	var adj_spot = MapHelper.get_adjacent_poses(self.cur_map_pos)
	var chosen_spot = null
	var spawn_priority = [[0,-1],[-1,-1],[1,-1],[-1,0],[1,0],[-1,1],[1,1],[0,1]]
	for perfered_spot in spawn_priority:
		var check_pos = MapPos.new( self.cur_map_pos.x + perfered_spot[0], 
									self.cur_map_pos.y + perfered_spot[1], 
									self.cur_map_pos.z,
									self.cur_map_pos.dir)
		if game_state.map_data.is_spot_open(check_pos):
			chosen_spot = check_pos
	if !chosen_spot:
		printerr("ShrineActorNode: No Open Spots found")
		return
	CombatRootControl.Instance.add_actor(actor, chosen_spot)
