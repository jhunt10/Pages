@tool
class_name MapControllerNode_Cave
extends MapControllerNode


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	CombatRootControl.QueController.end_of_round_with_state.connect(_on_end_of_round)


func _on_end_of_round(game_state:GameStateData):
	# Get Spawners
	var front_spawners = []
	var back_spawners = []
	var players = []
	var min_player_y = 999
	if CombatRootControl.Instance.ui_control.victory_screen.is_visible_in_tree():
		return
	for actor:BaseActor in game_state.list_actors():
		if actor is SpawnerActor:
			# Skip if last spawned actor is still alive
			if actor.last_spawned_actor_id != '':
				var last_spawned_actor = game_state.get_actor(actor.last_spawned_actor_id, false, false)
				if last_spawned_actor:
					continue
			if actor.Id.begins_with("BackShrine_"):
				back_spawners.append(actor)
			else:
				front_spawners.append(actor)
		if actor.is_player:
			players.append(actor)
			var pos = game_state.get_actor_pos(actor)
			if pos:
				min_player_y = min(pos.y, min_player_y)
	
	# Only use spawners from Back once player enters final room 
	var spawners = front_spawners
	if min_player_y <= 12:
		spawners = back_spawners
	
	var spawner_count = spawners.size() 
	if spawner_count == 0:
		return
		
	var roll = randi_range(0,spawner_count-1)
	var new_actor = ActorLibrary.create_actor("Zombie_Actor", {})
	new_actor.TeamKey = "Enemies"
	spawners[roll].start_spawning(new_actor)
	
