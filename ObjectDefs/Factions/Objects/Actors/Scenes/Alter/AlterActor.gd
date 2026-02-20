class_name AlterActor
extends BaseActor

signal triggered(on:bool)

var triggered_already:bool = false
var state_on:bool

func on_combat_start():
	super()
	if not CombatRootControl.is_valid():
		printerr("ObjectActor.on_combat_start: CombatRootControl is not valid")
		return
	CombatRootControl.Instance.QueController.end_of_round_with_state.connect(do_thing)

func do_thing(game_state:GameStateData):
	# Get Spawners
	var front_spawners = []
	var back_spawners = []
	var players = []
	var min_player_y = 999
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
			min_player_y = min(pos.y, min_player_y)
	
	# Only use spawners from Back once player enters final room 
	var spawners = front_spawners
	if min_player_y <= 12:
		spawners = back_spawners
	
	var spawner_count = spawners.size() 
	if spawner_count == 0:
		return
		
	var roll = randi_range(0,spawner_count-1)
	var new_actor = ActorLibrary.create_actor("ZombieBasic", {})
	new_actor.TeamKey = "Enemies"
	spawners[roll].start_spawning(new_actor)
	
		
