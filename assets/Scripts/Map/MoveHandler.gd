class_name MoveHandler

const LOGGING:bool = false

# Incase of diagninal movement
static var MOVE_MOD:int = 4
static var PushableMovement:Array = ['Walk']

static func relative_pos_to_real(current_pos:MapPos, relative_pos:MapPos) -> MapPos:
	var new_pos = MapPos.new(current_pos.x, current_pos.y, current_pos.z, current_pos.dir)
	match current_pos.dir:
		0: # North (x,y)
			new_pos.x += relative_pos.x
			new_pos.y += relative_pos.y
		1: # East (-y,-x)
			new_pos.x -= relative_pos.y
			new_pos.y -= relative_pos.x
		2: # South (-x,-y)
			new_pos.x -= relative_pos.x
			new_pos.y -= relative_pos.y
		3: # West (y,x)
			new_pos.x += relative_pos.y
			new_pos.y += relative_pos.x
	new_pos.z += relative_pos.z
	new_pos.dir = (current_pos.dir + relative_pos.dir + MOVE_MOD) % MOVE_MOD
	return new_pos

static func handle_movement(game_state:GameStateData, moving_actor:BaseActor, 
		relative_movement:MapPos, move_type:String) -> bool:
	var actor_pos:MapPos = game_state.MapState.get_actor_pos(moving_actor)
	var new_pos = relative_pos_to_real(actor_pos, relative_movement)
	if (new_pos.x < 0 or new_pos.x >= game_state.MapState.max_width 
		or new_pos.y < 0 or new_pos.y >= game_state.MapState.max_hight):
			return false
	if LOGGING:
		print("------------------------------")
		print("Handing Move '%s' to %s" % [moving_actor.ActorKey, new_pos])
	
	# Skip pushing logic if we aren't changing spots
	if new_pos.x == actor_pos.x and new_pos.y == actor_pos.y:
		game_state.MapState.set_actor_pos(moving_actor, new_pos)
		if LOGGING:
			print("------------------------------")
		return true
	
	# Check if spot is valid
	if not is_spot_traversable(moving_actor, game_state, new_pos):
		if LOGGING: 
			print("\tSpot is not traversable" )
			print("------------------------------")
		return false
	
	# Get actor in same z layer as where we are going
	var occupying_actors:Array = game_state.MapState.get_actors_at_pos(Vector2i(new_pos.x, new_pos.y))
	var blocking_actor = null
	if LOGGING: print("\t%s occupying_actors found" % [occupying_actors.size()])
	for b_act:BaseActor in occupying_actors:
		var b_act_pos = game_state.MapState.get_actor_pos(b_act)
		if b_act_pos.z == new_pos.z:
			blocking_actor = b_act
			
	if blocking_actor:
		if LOGGING: print("\tFound blocking actor: " + blocking_actor.ActorKey)
		if not PushableMovement.has(move_type):
			if LOGGING: print("\t\tPush NotAllowed")
			return false
		var push_res = _try_push(game_state, moving_actor, blocking_actor, relative_movement)
		if push_res:
			if LOGGING: print("\t\tPush success")
			game_state.MapState.set_actor_pos(blocking_actor, push_res)
		else:
			if LOGGING: print("\t\tPush Failed")
			return false
	
	game_state.MapState.set_actor_pos(moving_actor, new_pos)
	if LOGGING:
		print("------------------------------")
	return true

# Returns new pos for pushed_actor if the pushed_actor can be pushed
static func _try_push(game_state:GameStateData, moving_actor:BaseActor, pushed_actor:BaseActor, relative_movemnt:MapPos)->MapPos:
	DamageHelper.handle_push(moving_actor, pushed_actor, game_state)
	
	if moving_actor.stats.get_stat("Mass") < pushed_actor.stats.get_stat("Mass"):
		return null
	
	var current_mover_pos:MapPos = game_state.MapState.get_actor_pos(moving_actor)
	var current_pushed_pos:MapPos = game_state.MapState.get_actor_pos(pushed_actor)
	# Need to use pushed's pos but mover's direction. Also ignore dir change of move
	var pushed_to_pos = relative_pos_to_real(
		MapPos.new(current_pushed_pos.x, current_pushed_pos.y, current_pushed_pos.z, current_mover_pos.dir),
		 MapPos.new(relative_movemnt.x, relative_movemnt.y, 0, 0))
	
	if not spot_is_valid_and_open(game_state, pushed_to_pos):
		return null
	
	pushed_to_pos.dir = current_pushed_pos.dir
	return pushed_to_pos
	
static func is_spot_traversable(actor:BaseActor, game_state:GameStateData, pos:MapPos):
	var terrain = game_state.MapState.get_terrain_at_pos(pos)
	return terrain > 0
	
static func spot_is_valid_and_open(game_state:GameStateData, pos:MapPos):
	if (pos.x < 0 or pos.x >= game_state.MapState.max_width 
		or pos.y < 0 or pos.y >= game_state.MapState.max_hight):
			if LOGGING: print("\tSpot %s outside map bounds [%s,%s]" % [pos, game_state.MapState.max_width, game_state.MapState.max_hight])
			return false
	return game_state.MapState.is_spot_open(pos)
