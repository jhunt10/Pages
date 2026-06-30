class_name ActorAwarenessDisplay
extends TileMapLayer


func sync():
	var actor_node:BaseActorNode = $".."
	var actor = actor_node.Actor
	var actor_pos = MapPos.new(0,0,0,actor_node.facing_dir)
	for x in range(-2,2):
		for y in range(-2,2):
			var dir = AttackHandler.get_relative_attack_direction(
				actor_pos,
				 MapPos.new(x, y, 0, 0), actor.stats.get_stat(StatHelper.Awareness))
			if dir == AttackHandler.AttackDirection.Front:
				self.set_cell(Vector2i(x, y), 0, Vector2i(0,1))
			if dir == AttackHandler.AttackDirection.Flank:
				self.set_cell(Vector2i(x, y), 0, Vector2i(1,0))
			if dir == AttackHandler.AttackDirection.Back:
				self.set_cell(Vector2i(x, y), 0, Vector2i(0,0))
