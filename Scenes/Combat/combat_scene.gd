class_name CombatRootControl
extends Control

signal loading_actor_progressed(count:int, index:int)
signal actor_spawned(actor:BaseActor, map_pos:MapPos)
signal item_spawned(item:BaseItem, map_pos:MapPos)

@export var ui_control:CombatUiControl
@export var camera:MoveableCamera2D
@export var start_combat_screen:StartCombatScreen

@export var MapController:MapControllerNode
@export var dialog_controller:DialogController
@export var GridCursor:GridCursorNode

static var Instance:CombatRootControl 
static var QueController:ActionQueController = ActionQueController.new()
	
var GameState:GameStateData

static var _current_player_index:int = 0

## If true, will call StoryState.load_next_stage() when battle finishes
static var is_story_map:bool
var supress_win_conditions:bool = false
var combat_started:bool = false
var combat_finished:bool = false
var combat_cleaned:bool = false

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
	
	if dialog_controller:
		ui_control.hide()
		MapController.grid_tile_map.hide()
	#
	#MapController._build_terrain()
	for actor:BaseActor in GameState._actors.values():
		actor.on_combat_start()
	
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
	if !Instance: Instance = self
	elif Instance != self: 
		printerr("Multiple CombatRootControls found")
		queue_free()
		return
	if GameState:
		printerr("Combate Scene already init")
		return
	var map_scene_path = sub_scene_data.get("MapPath")
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
	
	var map_data = MapController.get_map_data()
	GameState = GameStateData.new()
	GameState.set_map_data(map_data)
	GameState.actor_entered_item_spot.connect(_on_actor_pickup_item)
	
	QueController = ActionQueController.new()
	QueController.end_of_round.connect(check_end_conditions)
	var actor_count = map_data['Actors'].size()
	var actor_index = 0
	for actor_info:Dictionary in map_data['Actors']:
		var new_actor = null
		var actor_pos = actor_info['Pos']
		if actor_info.keys().has("ActorId"):
			if actor_info.keys().has("ActorKey"):
				new_actor = ActorLibrary.get_or_create_actor(actor_info['ActorKey'], actor_info['ActorId'])
			else:
				new_actor = ActorLibrary.get_actor(actor_info['ActorId'])
			new_actor.FactionIndex = 1
		elif actor_info.keys().has("ActorKey") and actor_info["ActorKey"] != '':
			var actor_key = actor_info['ActorKey']
			if actor_key.begins_with("Player"):
				continue
			else:
				new_actor = ActorLibrary.create_actor(actor_key, {})
				if new_actor:
					new_actor.FactionIndex = 1
		
		if new_actor:
			if actor_info['WaitToSpawn']:
				# Must call without signals because actors are spawned before MapControlNode._ready()
				MapController.get_or_create_actor_node(new_actor, actor_pos, true)
			else:
				add_actor(new_actor, actor_pos)
		actor_index += 1
		loading_actor_progressed.emit(actor_count, actor_index)
	
	# Make Nodes for each player actor, but hide them until they are placed
	for player_actor:BaseActor in StoryState.list_player_actor():
		if not player_actor:
			continue
		player_actor.prep_for_combat()
		var player_actor_node = MapController.get_or_create_actor_node(player_actor, MapPos.new(0,0,0,0), true)
		player_actor_node.prep_for_combat()
		player_actor_node.hide()
	#var player_actor = StoryState.get_player_actor()
	## Check that actor in actually in game
	#player_actor = GameState.get_actor(player_actor.Id)
	#if !player_actor:
		#printerr("Player Actor not loaded to GameState")
	
	
	camera.zoom = Vector2(2,2)
	var camera_point = MapController.get_pos_marker("CameraStart")
	if camera_point:
		camera.snap_to_map_pos(camera_point)
	
	is_story_map = sub_scene_data.get("IsStoryMap", false)
	var dialog_script = sub_scene_data.get("DialogScript")
	if dialog_script:
		dialog_controller.load_dialog_script(dialog_script)
		dialog_controller.show()
	else:
		dialog_controller.queue_free()
		dialog_controller = null
		camera.freeze = false
	var ui_state_data = {
		"SpawnArea" = map_data.get("SpawnArea")
	}
	ui_control.ui_state_controller.set_ui_state(UiStateController.UiStates.PlaceActors, ui_state_data)
	
		

func start_combat_animation():
	start_combat_screen.show()
	start_combat_screen.start_combat_animation()
	combat_started = true

func _on_combat_screen_blackout():
	ui_control.show()
	MapController.grid_tile_map.show()

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


func add_actor(actor:BaseActor, pos:MapPos):
	if not actor:
		return
	if GameState._actors.keys().has(actor.Id):
		printerr("Actor '%s' already added" % [actor.Id])
		return
	print("Adding Actor %s with FactionIndex: %s" % [actor.Id, actor.FactionIndex])
	# Add actor to GameState and set position
	GameState.add_actor(actor)
	QueController.add_action_que(actor.Que)
	
	var actor_node = MapController.get_or_create_actor_node(actor, pos)
	actor_node.visible = true
	actor_node.reparent(MapController.actor_tile_map)
	if not MapController.actor_nodes.has(actor.Id):
		MapController.actor_nodes[actor.Id] = actor_node
	GameState.set_actor_pos(actor, pos)
	actor.stats.fill_bar_stats()
	actor.Que.fill_page_ammo()

func add_item(item:BaseItem, pos:MapPos):
	if GameState._items.keys().has(item.Id):
		printerr("Item '%s' already added" % [item.Id])
		return
	# Add item to GameState and set position
	GameState.add_item(item, pos)
	# Must call without signals because items are spawned before MapControlNode._ready()
	MapController.create_item_node(item, pos)
	item_spawned.emit(item, pos)

func remove_item(item:BaseItem):
	GameState.delete_item(item)
	MapController.delete_item_node(item)

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
	var new_node  = load("res://Scenes/Combat/MapObjects/missile_node.tscn").instantiate()
	new_node.set_missile_data(missile)
	MapController.add_missile_node(missile, new_node)

#func create_flash_text(parent_node:Node, value:String, color:Color):
	#var new_node:FlashTextControl  = load("res://Scenes/Combat/Effects/flash_text_control.tscn").instantiate()
	#new_node.set_values(value, color)
	#parent_node.add_child(new_node)
	
	
func add_zone(zone:BaseZone):
	var new_node:ZoneNode  = load(zone.get_zone_scene_path()).instantiate()
	new_node._zone = zone
	zone.node = new_node
	GameState.add_zone(zone)
	MapController.add_zone_node(zone, new_node)
	for spot in zone.get_area():
		for actor in GameState.get_actors_at_pos(spot):
			zone.on_actor_enter(actor, GameState)

func get_zone(zone_id:String)->BaseZone:
	return GameState._zones.get(zone_id)

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
	
	var living_players = []
	var living_enimes = []
	for actor:BaseActor in GameState.list_actors(false):
		if actor.is_player:
			living_players.append(actor)
		else:
			living_enimes.append(actor)
	if living_players.size() == 0:
		trigger_end_condition(false)
	elif living_enimes.size() == 0:
		trigger_end_condition(true)

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
			actor.Que.clear_que()
		else:
			ActorLibrary.delete_actor(actor)
	ui_control.ui_state_controller.clear_states()

func list_actors_by_order()->Array:
	var out_list = []
	for que_id in CombatRootControl.Instance.QueController._que_order:
		var que:ActionQue = CombatRootControl.Instance.QueController._action_ques[que_id]
		out_list.append(que.actor)
	return out_list
		
		
static func list_player_actors()->Array:
	var out_list = []
	for que_id in CombatRootControl.Instance.QueController._que_order:
		var que:ActionQue = CombatRootControl.Instance.QueController._action_ques[que_id]
		var actor = que.actor
		if StoryState._player_ids.has(actor.Id):
			out_list.append(actor)
	return out_list

func get_current_player_actor()->BaseActor:
	return StoryState.get_player_actor(_current_player_index)

func set_player_index(index:int, move_camera:bool=true):
	if index >= 0 and index < 4 and StoryState._player_ids[index] != null:
		_current_player_index = index
		ui_control.set_player_actor_index(_current_player_index)
		if move_camera:
			var actor = StoryState.get_player_actor(index)
			camera.start_auto_pan_to_actor(actor, false)

func get_next_player_index()->int:
	var next_index = (_current_player_index + 1) % 4
	var extra_check = 0
	while StoryState.get_player_id(next_index) == null and extra_check < 4:
		extra_check += 1
		next_index = (next_index + 1) % 4
	return next_index
