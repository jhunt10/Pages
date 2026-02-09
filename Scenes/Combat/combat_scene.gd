class_name CombatRootControl
extends Control

signal loading_actor_progressed(count:int, index:int)
signal actor_spawned(actor:BaseActor, map_pos:MapPos)
signal item_spawned(item:BaseItem, map_pos:MapPos)

@export var ui_control:CombatUiControl
@export var camera:MoveableCamera2D
@export var start_combat_screen:StartCombatScreen
@export var map_background:MapBackground

@export var MapController:MapControllerNode
@export var dialog_controller:DialogController
@export var GridCursor:GridCursorNode

static var Instance:CombatRootControl 
static var QueController:ActionQueController = ActionQueController.new()
	
var combat_map_data:Dictionary = {}
var _current_phase_key:String = ""
var GameState:GameStateData

static var is_paused:bool = false
static var auto_targeting_enabled:bool = true
static var _current_player_index:int = 0
static var _player_actor_ids:Array = []

static func is_valid()->bool:
	return is_instance_valid(Instance)

static func get_player_index_of_actor(actor:BaseActor)->int:
	for index in range(_player_actor_ids.size()):
		if actor.Id == _player_actor_ids[index]:
			return index
	return -1


## If true, will call StoryState.load_next_stage() when battle finishes
static var is_story_map:bool
var supress_win_conditions:bool = false
var combat_started:bool = false
var combat_finished:bool = false
var combat_cleaned:bool = false

var last_target_records:Dictionary = {}

func _enter_tree() -> void:
	if !Instance: 
		Instance = self
		#if !GameState:
			#GameState = GameStateData.new()
	if !QueController:
		QueController = ActionQueController.new()
	#elif Instance != self: 
		#printerr("Multiple CombatRootControls found")
		#queue_free()
		#return

func _exit_tree() -> void:
	if not combat_cleaned:
		cleanup_combat()
	QueController = null
	Instance = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if !Instance: Instance = self
	elif Instance != self: 
		printerr("Multiple CombatRootControls found")
		queue_free()
		return
	
	start_combat_screen.hide()
	start_combat_screen.screen_blacked_out.connect(_on_combat_screen_blackout)
	start_combat_screen.screen_clear.connect(_on_combat_screen_cleared)
	
	map_background.set_map(MapController)
	
	if dialog_controller:
		ui_control.hide()
		MapController.grid_tile_map.hide()
	#
	#MapController._build_terrain()
	for actor:BaseActor in GameState._actors.values():
		actor.on_combat_start()
	camera.cach_camera_bounds()
	#ui_control.ui_state_controller.set_ui_state(UiStateController.UiStates.ActionInput)
	pass # Replace with function body.

func _process(delta: float) -> void:
	QueController.update(delta)
#
#func load_map(map_control:MapControllerNode):
	#GameState = GameStateData.new()
	#map_control.init_load()
##

static func get_time_scale()->float:
	return 1.5

static func get_remaining_frames_for_turn()->int:
	if Instance:
		if Instance.QueController and Instance.QueController.execution_state != ActionQueController.ActionStates.Waiting:
			return ActionQueController.FRAMES_PER_ACTION - Instance.QueController.sub_action_index
	return 0
static func get_actor_node(actor_id:String)->BaseActorNode:
	if !Instance: return null
	if !Instance.MapController: return null
	var actor_nodes = Instance.MapController.actor_nodes
	return actor_nodes.get(actor_id)

func load_init_state(sub_scene_data:Dictionary):
	printerr("Loading init state")
	
	var map_key = sub_scene_data.get("MapKey")
	if !map_key:
		printerr("CombatScene.load_init_state: NoMapKey provided")
		queue_free()
		return
	
	combat_map_data = MapLoader.get_map_data(map_key)
	
	if !Instance: Instance = self
	elif Instance != self: 
		printerr("Multiple CombatRootControls found")
		queue_free()
		return
	if GameState:
		printerr("Combate Scene already init")
		return
	var map_scene_path = combat_map_data.get("LoadPath", "").path_join(combat_map_data.get("MapScene"))
	var map_scene = load(map_scene_path)
	if MapController:
		MapController.queue_free()
	MapController = map_scene.instantiate()
	MapController.name = "MapController"
	self.add_child(MapController)
	
	# Keep Camera last in sceen (prevents flickering)
	self.remove_child(camera)
	self.add_child(camera)
	self.remove_child(GridCursor)
	self.add_child(GridCursor)
	
	# Build GameState & Map Data
	var map_data = MapController.get_map_data()
	GameState = GameStateData.new()
	GameState.set_map_data(map_data)
	GameState.actor_entered_item_spot.connect(_on_actor_pickup_item)
	GameState.set_team_data(combat_map_data.get("TeamData", {}))
	# Build Action Que Controller
	QueController = ActionQueController.new()
	QueController.end_of_round.connect(check_end_conditions)
	
	## Build Actors from Map Data
	#_player_actor_ids.clear()
	#var npcs_to_name = {}
	#var actor_count = map_data['Actors'].size()
	#var actor_index = 0
	#for actor_info:Dictionary in map_data['Actors']:
		#var new_actor = null
		#var actor_pos = actor_info['Pos']
		#
		#
		#if new_actor:
			#if actor_info['WaitToSpawn']:
				## Must call without signals because actors are spawned before MapControlNode._ready()
				#MapController.get_or_create_actor_node(new_actor, actor_pos, true)
			#else:
				#add_actor(new_actor, actor_pos)
		#actor_index += 1
		#loading_actor_progressed.emit(actor_count, actor_index)
	#
	# Name NPC Actors
	#for display_name in npcs_to_name.keys():
		#if npcs_to_name[display_name].size() == 1:
			#continue
		#var index = 0
		#for actor:BaseActor in npcs_to_name[display_name]:
			#actor.enemy_npc_index = index
			#index += 1
	
	
	#var player_actor = StoryState.get_player_actor()
	## Check that actor in actually in game
	#player_actor = GameState.get_actor(player_actor.Id)
	#if !player_actor:
		#printerr("Player Actor not loaded to GameState")
	
	
	camera.zoom = Vector2(2,2)
	#var camera_point = MapController.get_pos_marker("CameraStart")
	#if camera_point:
		#camera.snap_to_map_pos(camera_point)
	
	is_story_map = sub_scene_data.get("IsStoryMap", false)
	#var dialog_script = sub_scene_data.get("DialogScript")
	#if dialog_script:
		#dialog_controller.load_dialog_script(dialog_script)
		#dialog_controller.show()
	#else:
		#dialog_controller.queue_free()
		#dialog_controller = null
		#camera.freeze = false
	var starting_phase = combat_map_data.get("StartingPhase")
	start_phase(starting_phase)

func get_current_phase_data()->Dictionary:
	var phase_datas = combat_map_data.get("PhaseDatas", {})
	if phase_datas.keys().has(_current_phase_key):
		return phase_datas[_current_phase_key]
	printerr("CombatScene.get_current_phase_data: Unknown Phase Key: %s" % [_current_phase_key])
	return {}

func start_phase(phase_key):
	if phase_key.to_lower() == "end":
		combat_finished = true
		ui_control.victory_screen.show_game_result()
		return
	var phase_datas = combat_map_data.get("PhaseDatas", {})
	if not phase_datas.keys().has(phase_key):
		printerr("CombatScene.start_phase: Unknown Phase Key: %s" % [phase_key])
		combat_finished = true
		ui_control.victory_screen.show_game_result()
		return
	_current_phase_key = phase_key
	
	var phase_data = phase_datas[_current_phase_key]
	var phase_type = phase_data.get("PhaseType", "")
	
	# Clear and cache markers for this phase
	_cached_markers.clear()
	var phase_map_name = phase_data.get("MarkerMap")
	if phase_map_name:
		var phase_map = MapController.get_phase_marker_map(phase_map_name)
		var spawn_nodes = []
		for child in phase_map.get_children():
			_cached_markers[child.name] = child
		
	match(phase_type):
		"SpawnEnemy":
			spawn_actors_for_phase(phase_data)
			start_next_phase()
		"PlacePlayers":
			var ui_state_data = {
				"SpawnArea" = MapController.get_player_spawn_area()
			}
			ui_control.ui_state_controller.set_ui_state(UiStateController.UiStates.PlaceActors, ui_state_data)
		"Combat":
			if not combat_started:
				start_combat_animation()
			CombatRootControl.Instance.ui_control.ui_state_controller.set_ui_state(UiStateController.UiStates.ActionInput)
		"Dialog":
			var dialog_data = phase_data.get("DialogData")
			dialog_controller.load_dialog_data(dialog_data)
			pass
		

func start_next_phase():
	var phase_data = get_current_phase_data()
	var next_key = phase_data.get("NextPhase")
	start_phase(next_key)
		

#func pre_load_actors_for_phases():
	## Make Nodes for each player actor, but hide them until they are placed
	#for player_actor:BaseActor in StoryState.list_party_actors():
		#if not player_actor:
			#continue
		#var player_actor_node = MapController.get_or_create_actor_node(player_actor, MapPos.new(0,0,0,0), true)
		##player_actor_node.prep_for_combat()
		#player_actor_node.hide()
	#
var _cached_markers = {}
func get_pos_marker(marker_name)->MapPos:
	if _cached_markers.has(marker_name):
		return _cached_markers[marker_name]
	return null
	
func get_path_marker(marker_name)->MapPathNode:
	if _cached_markers.has(marker_name):
		return _cached_markers[marker_name]
	return null
	
func get_spawn_node(marker_name)->ActorSpawnNode:
	if _cached_markers.has(marker_name):
		return _cached_markers[marker_name]
	return null

func spawn_actors_for_phase(phase_data:Dictionary):
	var actors = []
	var phase_map = MapController.get_phase_marker_map(phase_data.get("MarkerMap", ""))
	var spawn_nodes = []
	for child in phase_map.get_children():
		if not child is ActorSpawnNode:
			continue
		if !child.visible:
			continue
		spawn_nodes.append(child)
	var total_count = spawn_nodes.size()
	var index = 0
	for child in spawn_nodes:
		var actor_pos = MapPos.new(child.map_coor.x, child.map_coor.y, 0, child.facing)
		var actor_key = ""
		var actor_id = ""
		var team_index = child.team_index
		if child.spawn_actor_key != '':
			if child.spawn_actor_key == "RandomEnemy":
				actor_key = _get_random_enemy_key(phase_data)
			else:
				actor_key = child.spawn_actor_key
		if child.spawn_actor_id != '':
			actor_id = child.spawn_actor_id
		if child.is_player:
			team_index = 0
		var new_actor = null
		
		# Specific Actor Id was provided
		if actor_id != "":
			new_actor = ActorLibrary.get_or_create_actor(actor_key, actor_id)
			if not new_actor:
				printerr("CombatRootControl.load_init_state: Failed to get or create actor with id %s" % [actor_id])
		# Only Actor Key was provided
		elif actor_key != '':
			if actor_key.begins_with("Player"):
				continue # This shouldn't happen? Maybe in scripted scenes?
			else:
				# Spawn Enemy NPC
				new_actor = ActorLibrary.create_actor(actor_key, {})
		index += 1
		loading_actor_progressed.emit(total_count, index)
		if new_actor:
			new_actor.TeamIndex = team_index
			add_actor(new_actor, actor_pos)
					#var display_name = new_actor.get_display_name()
					#if not npcs_to_name.keys().has(display_name):
						#npcs_to_name[display_name] = []
					#npcs_to_name[display_name].append(new_actor)
	pass

func _get_random_enemy_key(map_data)->String:
	var enemy_data = map_data.get("EnemySet", {})
	var enemy_set = {}
	for enemy_key in enemy_data:
		enemy_set[enemy_key] = enemy_data[enemy_key].get("Weight", -1)
	var actor_key = Roll.from_set(enemy_set)
	return actor_key
	

func start_combat_animation():
	start_combat_screen.show()
	start_combat_screen.start_combat_animation()
	
	combat_started = true

static func pause_combat():
	if !Instance:
		return
	Instance.get_tree().paused = true
	is_paused = true
	if Instance.QueController.execution_state == ActionQueController.ActionStates.Running:
		Instance.QueController.pause_execution()

static func resume_combat():
	if !Instance:
		return
	Instance.get_tree().paused = false
	is_paused = false
	if Instance.QueController.execution_state == ActionQueController.ActionStates.Paused:
		Instance.QueController.start_or_resume_execution()
	

func _on_combat_screen_blackout():
	ui_control.show()
	MapController.grid_tile_map.show()
	ui_control.build_player_stats_panels()

func _on_combat_screen_cleared():
	start_combat_screen.hide()

func kill_actor(actor:BaseActor):
	actor.die()
	QueController.remove_action_que(actor.Que)
	if actor.leaves_corpse():
		GameState.move_actor_to_corpse_layer(actor)
	else:
		GameState.remove_actor_from_map(actor)
		#delete_actor(actor)

func revive_actor(actor:BaseActor):
	actor.revive()
	QueController.add_action_que(actor.Que)
	if GameState.get_actor(actor.Id):
		GameState.move_actor_to_default_layer(actor)
	else:
		printerr("Revived Actor '%s' no longer exists in GameState." % [actor.Id])

#func remove_actor(actor:BaseActor):
	#actor.die()
	#QueController.remove_action_que(actor.Que)
	#GameState.remove_actor_from_map(actor)
	#var actor_node = get_actor_node(actor.Id)
	#if actor_node:
		#actor_node.queue_free()


func add_actor(actor:BaseActor, pos:MapPos, is_player:bool=false):
	if not actor:
		return
	if GameState._actors.keys().has(actor.Id):
		printerr("Actor '%s' already added" % [actor.Id])
		return
	print("Adding Actor %s with TeamIndex: %s" % [actor.Id, actor.TeamIndex])
	
	var actor_node = MapController.get_or_create_actor_node(actor, pos)
	actor_node.visible = true
	MapController.reparent_actor_node_to_actor_tile_map(actor_node)
	
	# Add actor to GameState and set position
	GameState.add_actor(actor)
	QueController.add_action_que(actor.Que)
	GameState.set_actor_pos(actor, pos)
	
	# Add to player list if player
	if is_player and not _player_actor_ids.has(actor.Id):
			_player_actor_ids.append(actor.Id)
	
	if combat_started:
		actor.clean_state()
		actor.on_combat_start()
	

func add_item(item:BaseItem, pos:MapPos):
	if GameState._items.keys().has(item.Id):
		printerr("Item '%s' already added" % [item.Id])
		return
	# Add item to GameState and set position
	GameState.add_item(item, pos)
	# Must call without signals because items are spawned before MapControlNode._ready()
	MapController.create_item_node(item, pos)
	item_spawned.emit(item, pos)

func remove_item(item_id):
	if item_id is BaseItem:
		item_id = item_id.Id
	GameState.delete_item(item_id)
	MapController.delete_item_node(item_id)

func _on_actor_pickup_item(actor:BaseActor, items_ids:Array):
	for item_id in items_ids:
		var item = ItemLibrary.get_item(item_id)
		var popup_data = ItemHelper.try_pickup_item(actor, item)
		ui_control.drop_message_control.add_card(
			popup_data['Message'],
			popup_data['Image'],
			popup_data['Background']
		)
	pass

func create_new_missile_node(missile):
	GameState.add_missile(missile)
	var new_node  = load("res://Scenes/Combat/MapObjects/missile_node.tscn").instantiate()
	new_node.set_missile_data(missile)
	MapController.add_missile_node(missile, new_node)

func add_zone(zone:BaseZone):
	var new_node:ZoneNode  = load(zone.get_zone_scene_path()).instantiate()
	new_node._zone = zone
	zone.node = new_node
	GameState.add_zone(zone)
	MapController.add_zone_node(zone, new_node)

func remove_zone(zone):
	if zone is String:
		zone = GameState._zones.get(zone)
	if !zone:
		return
	GameState.delete_zone(zone.Id)
	MapController.delete_zone_node(zone)

func check_end_conditions():
	if supress_win_conditions:
		return
	
	var living_actor_by_team = {}
	var party_ids = StoryState.list_party_actors_ids()
	for actor:BaseActor in GameState.list_actors(true):
		if not living_actor_by_team.keys().has(str(actor.TeamIndex)):
			living_actor_by_team[str(actor.TeamIndex)] = 0
		if actor.is_dead:
			continue
		living_actor_by_team[str(actor.TeamIndex)] += 1
		
	# All Players dead, Game Over
	if living_actor_by_team["0"] == 0:
		trigger_end_condition(false)

	var combat_condition = get_current_phase_data().get("CombatCondition")
	var condition_key = combat_condition
	if combat_condition is String:
		condition_key = combat_condition
	elif combat_condition is Dictionary:
		condition_key =  combat_condition.get("ConditionKey")
	
	if condition_key == "KillAll":
		var any_alive = false
		for team_index in living_actor_by_team.keys():
			if team_index == 0:
				continue
			if living_actor_by_team[team_index] > 0:
				any_alive = true
		if not any_alive:
			start_next_phase()
	elif condition_key == "KillTeam":
		var team_index = str(combat_condition.get("EnemyTeamIndex"))
		var keys = living_actor_by_team.keys()
		if not keys.has(team_index):
			printerr("CombatScene.check_end_conditions KillTeam: No team found with index %s." % [team_index])
			start_next_phase()
			return
		if living_actor_by_team[team_index] == 0:
			start_next_phase()
			

func trigger_end_condition(victory:bool):
	combat_finished = true
	if victory:
		ui_control.victory_screen.show_game_result()
	else:
		ui_control.game_over_screen.show()

func cleanup_combat():
	for actor:BaseActor in GameState.list_actors(true):
		actor.effects.on_combat_end(GameState)
		if actor.is_player:
			actor.effects.purge_combat_efffects()
			actor.Que.clear_que(true)
		else:
			ActorLibrary.delete_actor(actor)
	ui_control.ui_state_controller.clear_states()
	_player_actor_ids.clear()
	if is_paused:
		get_tree().paused = false
		is_paused = false

func list_actors_by_order()->Array:
	var out_list = []
	for que_id in CombatRootControl.Instance.QueController._que_order:
		var que:ActionQue = CombatRootControl.Instance.QueController._action_ques[que_id]
		out_list.append(que.actor)
	return out_list
		

static func list_player_actor_ids()->Array:
	var out_list = []
	for que_id in CombatRootControl.Instance.QueController._que_order:
		var que:ActionQue = CombatRootControl.Instance.QueController._action_ques[que_id]
		var actor = que.actor
		if _player_actor_ids.has(actor.Id):
			out_list.append(actor.Id)
	return out_list

static func list_player_actors()->Array:
	var out_list = []
	for id in list_player_actor_ids():
		var actor = ActorLibrary.get_actor(id)
		out_list.append(actor)
	return out_list

func get_current_player_index()->int:
	return _current_player_index
	
func get_current_player_actor()->BaseActor:
	return get_player_actor(_current_player_index)

func set_player_index(index:int, move_camera:bool=true):
	if index >= 0 and index < _player_actor_ids.size():
		_current_player_index = index
		ui_control.set_player_actor_index(_current_player_index)
		if move_camera:
			var actor = get_player_actor(index)
			camera.lock_to_actor(actor, true)


func get_player_actor(index:int = _current_player_index)->BaseActor:
	if index >= 0 and index < _player_actor_ids.size():
		var player_id = _player_actor_ids[index]
		if player_id:
			return ActorLibrary.get_actor(player_id)
	return null

func get_next_player_index(use_index:int=-1)->int:
	if use_index < 0:
		use_index = _current_player_index
	var next_index = (use_index + 1) % _player_actor_ids.size()
	#var extra_check = 0
	#while StoryState.get_player_id(next_index) == null and extra_check < 4:
		#extra_check += 1
		#next_index = (next_index + 1) % 4
	return next_index
