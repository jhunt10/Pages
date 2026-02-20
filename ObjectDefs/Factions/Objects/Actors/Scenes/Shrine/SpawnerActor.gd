class_name SpawnerActor
extends BaseActor

# emited by Spawner ActorNode at end of spawn animation
signal spawn_finished()

var triggered_already:bool = false
var state_on:bool
var spawning_actor
var last_spawned_actor_id:String = ''

func start_spawning(actor:BaseActor):
	self.spawning_actor = actor
	var actor_node = CombatRootControl.get_actor_node(self.Id)
	actor_node.start_spawning_animation()
	

# Called by ActorNode when animation is ready
func _spawn_actor():
	if spawning_actor == null:
		return
	var game_state = CombatRootControl.Instance.GameState
	var cur_map_pos = game_state.get_actor_pos(self)
	var adj_spot = MapHelper.get_adjacent_poses(cur_map_pos)
	var chosen_spot = null
	var spawn_priority = [[0,-1],[-1,-1],[1,-1],[-1,0],[1,0],[-1,1],[1,1],[0,1]]
	for perfered_spot in spawn_priority:
		var check_pos = MapPos.new( cur_map_pos.x + perfered_spot[0], 
									cur_map_pos.y + perfered_spot[1], 
									cur_map_pos.z,
									cur_map_pos.dir)
		if game_state.map_data.is_spot_open(check_pos):
			chosen_spot = check_pos
	if !chosen_spot:
		printerr("ShrineActorNode: No Open Spots found")
		return
	CombatRootControl.Instance.add_actor(spawning_actor, chosen_spot, false, true)
	last_spawned_actor_id = spawning_actor.Id
	spawning_actor = null
