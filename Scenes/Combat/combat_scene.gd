class_name CombatRootControl
extends Control

signal actor_spawned(actor:BaseActor, map_pos:MapPos)
signal item_spawned(item:BaseItem, map_pos:MapPos)

@export var ui_control:CombatUiControl
@export var camera:MoveableCamera2D

@export var MapController:MapControllerNode

@export var GridCursor:GridCursorNode

static var Instance:CombatRootControl 
static var QueController:ActionQueController = ActionQueController.new()
	
var GameState:GameStateData

func _enter_tree() -> void:
	if !Instance: 
		Instance = self
		if !GameState:
			GameState = GameStateData.new()
	if !QueController:
		QueController = ActionQueController.new()
	elif Instance != self: 
		printerr("Multiple CombatRootControls found")
		queue_free()
		return

func _exit_tree() -> void:
	QueController = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if !Instance: Instance = self
	elif Instance != self: 
		printerr("Multiple CombatRootControls found")
		queue_free()
		return
	#load_map(MapController)
	
		#
	
	ui_control.ui_state_controller.set_ui_state(UiStateController.UiStates.ActionInput)
	#
	#MapController._build_terrain()
	for actor:BaseActor in GameState._actors.values():
		actor.on_combat_start()
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


func load_init_state(map_scene_path:String):
	if !Instance: Instance = self
	elif Instance != self: 
		printerr("Multiple CombatRootControls found")
		queue_free()
		return
	if GameState:
		printerr("Combate Scene already init")
		return
	var map_scene = load(map_scene_path)
	if MapController:
		MapController.queue_free()
		
	MapController = map_scene.instantiate()
	self.add_child(MapController)
	
	# Keep Camera last in sceen (prevents flickering)
	self.remove_child(camera)
	self.add_child(camera)
	self.remove_child(GridCursor)
	self.add_child(GridCursor)
	
	var map_data = MapController.get_map_data()
	GameState = GameStateData.new()
	GameState.MapState = MapStateData.new(GameState, map_data)
	QueController = ActionQueController.new()
	QueController.end_of_round.connect(check_end_conditions)
	
	for actor_info:Dictionary in map_data['Actors']:
		var new_actor = null
		var actor_pos = actor_info['Pos']
		if actor_info.keys().has("ActorId"):
			if actor_info.keys().has("ActorKey"):
				new_actor = ActorLibrary.get_or_create_actor(actor_info['ActorKey'], actor_info['ActorId'])
			else:
				new_actor = ActorLibrary.get_actor(actor_info['ActorId'])
		elif actor_info.keys().has("ActorKey"):
			var actor_key = actor_info['ActorKey']
			if actor_key == "Player1":
				new_actor = StoryState.get_player_actor()
			else:
				new_actor = ActorLibrary.create_actor(actor_key, {})
		if new_actor:
			add_actor(new_actor, actor_info.get("FactionId", 1), actor_pos)
			
	
	var player_actor = StoryState.get_player_actor()
	if !player_actor or !GameState.get_actor(player_actor.Id):
		printerr("Player Actor not loaded to GameState")
	else:
		ui_control.set_player_actor(player_actor)
		var actor_pos = GameState.MapState.get_actor_pos(player_actor)
		if actor_pos:
			camera.snap_to_map_pos(actor_pos)
			camera.zoom = Vector2(2,2)

func kill_actor(actor:BaseActor):
	actor.die()
	QueController.remove_action_que(actor.Que)
	GameState.delete_actor(actor)
	#if actor.leaves_corpse:
	GameState.MapState.set_actor_layer(actor, MapStateData.MapLayers.Corpse)
	#else:
		#delete_actor(actor)


func delete_actor(actor:BaseActor):
	GameState.MapState.remove_actor(actor)
	MapController.delete_actor_node(actor)
	#GameState.Actors.erase(actor.Id)
	
func add_actor(actor:BaseActor, faction_id:int, pos:MapPos):
	if GameState._actors.keys().has(actor.Id):
		printerr("Actor '%s' already added" % [actor.Id])
		return
	# Add actor to GameState and set position
	actor.FactionIndex = faction_id
	GameState.add_actor(actor)
	QueController.add_action_que(actor.Que)
	
	GameState.MapState.set_actor_pos(actor, pos, actor.spawn_map_layer)
	# Must call without signals because actors are spawned before MapControlNode._ready()
	MapController.create_actor_node(actor, pos)
	
	actor.Que.clear_que()
	actor.stats.fill_bar_stats()
	if actor._allow_auto_que:
		actor.auto_build_que(QueController.action_index)
		if QueController.execution_state == ActionQueController.ActionStates.Running:
			actor.Que.fail_turn()
	actor_spawned.emit(actor, pos)

func add_item(item:BaseItem, pos:MapPos):
	if GameState._items.keys().has(item.Id):
		printerr("Item '%s' already added" % [item.Id])
		return
	# Add item to GameState and set position
	GameState.add_item(item)
	GameState.MapState.set_item_pos(item, pos)
	# Must call without signals because items are spawned before MapControlNode._ready()
	MapController.create_item_node(item, pos)
	item_spawned.emit(item, pos)

func remove_item(item:BaseItem):
	GameState.MapState.remove_item(item)
	MapController.delete_item_node(item)

func create_new_missile_node(missile):
	var new_node:MissileNode  = load("res://Scenes/Combat/MapObjects/missile_node.tscn").instantiate()
	new_node.set_missile_data(missile)
	MapController.add_missile_node(missile, new_node)
	
func create_damage_effect(target_actor:BaseActor, vfx_key:String, flash_number:int, source = null, color:Color=Color.RED):
	var target_actor_node:ActorNode = MapController.actor_nodes.get(target_actor.Id, null)
	if !target_actor_node:
		printerr("Failed to find actor node for: %s" % [target_actor.Id])
		return
	var vfx_data = MainRootNode.vfx_libray.get_vfx_data(vfx_key)
	if !vfx_data:
		printerr("Failed to VFX with key: %s" % [vfx_key])
		return
	
	var extra_data = {}
	if vfx_data.match_source_dir and source is BaseActor:
		var node = MapController.actor_nodes.get(source.Id)
		if node:
			extra_data['Direction'] = node.facing_dir
	var vfx_node = MainRootNode.vfx_libray.create_vfx_node(vfx_data, extra_data)
	if !vfx_node:
		printerr("Failed to create VFX node from key '%s'." % [vfx_key])
		return
	target_actor_node.vfx_holder.add_child(vfx_node)
	if flash_number >= 0:
		if flash_number > 0 and vfx_node._data.shake_actor:
			target_actor_node.play_shake()
		vfx_node.add_flash_text(str(0-flash_number), color)
	if flash_number < 0:
		vfx_node.add_flash_text(str(0-flash_number), Color.GREEN)
	vfx_node.start_vfx()


func create_flash_text_on_actor(actor:BaseActor, value:String, color:Color):
	var actor_node:ActorNode = MapController.actor_nodes[actor.Id]
	create_flash_text(actor_node.vfx_holder, value, color)
	

func create_flash_text(parent_node:Node, value:String, color:Color):
	var new_node:FlashTextControl  = load("res://Scenes/Combat/Effects/flash_text_control.tscn").instantiate()
	new_node.set_values(value, color)
	parent_node.add_child(new_node)

func create_damage_number(actor:BaseActor, damage:int):
	if damage < 0:
		create_flash_text_on_actor(actor, "+"+str(abs(damage)), Color.DARK_GREEN)
	else:
		create_flash_text_on_actor(actor, "-"+str(damage), Color.DARK_RED)
		
	
func add_zone(zone:BaseZone):
	var new_node:ZoneNode  = load("res://Scenes/zone_node.tscn").instantiate()
	new_node._zone = zone
	MapController.add_zone_node(zone, new_node)

func check_end_conditions():
	var player_actor = StoryState.get_player_actor()
	if player_actor.is_dead:
		ui_control.game_over_screen.show()
