class_name CombatRootControl
extends Control

signal actor_spawned(actor:BaseActor)

@onready var MapController:MapControllerNode = $MapControlerNode

@onready var QueInput = $CombatUiControl/QueInputControl
@onready var QueDisplay = $CombatUiControl/QueDisplayControl
@onready var GridCursor:GridCursorNode = $MapControlerNode/GridCursor
@onready var  StatDisplay:StatPanelControl = $CombatUiControl/StatPanelControl
@onready var ui_controller:UiStateController = $CombatUiControl

static var Instance:CombatRootControl 
static var QueController:ActionQueController = ActionQueController.new()
	
var GameState:GameStateData

# Actors to create on ready {ActorKey,Position}
var actor_creation_que:Dictionary = {}
var player_actor_key:String

func _enter_tree() -> void:
	if !Instance: 
		Instance = self
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
	
	for actor_key in actor_creation_que.keys():
		var actor_data = MainRootNode.actor_libary.get_actor_data(actor_key)
		var new_actor = create_new_actor(actor_data, 1, actor_creation_que[actor_key])
		if actor_key == player_actor_key:
			new_actor.FactionIndex = 0
			StatDisplay.set_actor(new_actor)
			QueInput.set_actor(new_actor)
			QueDisplay.set_actor(new_actor)
		new_actor.effects.add_effect("FlashText", {})
	actor_creation_que.clear()
	
	ui_controller.set_ui_state(UiStateController.UiStates.ActionInput)
	MapController._build_terrain()
	pass # Replace with function body.

func _process(delta: float) -> void:
	QueController.update(delta)

func set_init_state(map_data:Dictionary, player_actor:String, actors_pos:Dictionary):
	if GameState:
		printerr("Combate Scene already init")
		return
	GameState = GameStateData.new()
	GameState.MapState = MapStateData.new(GameState, map_data)
	player_actor_key = player_actor
	actor_creation_que = actors_pos
	
func kill_actor(actor:BaseActor):
	actor.die()
	QueController.remove_action_que(actor.Que)
	if actor.leaves_corpse:
		GameState.MapState.set_actor_layer(actor, MapStateData.MapLayers.Corpse)
	else:
		delete_actor(actor)


func delete_actor(actor:BaseActor):
	GameState.MapState.delete_actor(actor)
	MapController.delete_actor(actor)
	#GameState.Actors.erase(actor.Id)
	
func create_new_actor(data:Dictionary, faction_index:int, pos:MapPos):
	#var file = FileAccess.open(path, FileAccess.READ)
	#var text:String = file.get_as_text()
	#var data = JSON.parse_string(text)
	var new_actor = BaseActor.new(data, faction_index)
	
	# Add actor to GameState and set position
	GameState.add_actor(new_actor)
	GameState.MapState.set_actor_pos(new_actor, pos, new_actor.spawn_map_layer)
	QueController.add_action_que(new_actor.Que)
	
	# Register new node with MapController and sync  pos
	var new_node = load("res://Scenes/actor_node.tscn").instantiate()
	new_node.set_actor(new_actor)
	MapController.add_actor_node(new_actor, new_node)
	MapController._sync_actor_positions()
	new_node.visible = true
	
	if new_actor._allow_auto_que:
		new_actor.auto_build_que(QueController.action_index)
	
	actor_spawned.emit(new_actor)
		
	return new_actor

func create_new_missile_node(missile):
	var new_node:MissileNode  = load("res://Scenes/missile_node.tscn").instantiate()
	new_node.set_missile_data(missile)
	MapController.add_missile_node(missile, new_node)
	
func create_damage_effect(actor:BaseActor, vfx_key:String, flash_number:int):
	var actor_node:ActorNode = MapController.actor_nodes.get(actor.Id, null)
	if !actor_node:
		printerr("Failed to find actor node for: %s" % [actor.Id])
		return
	var vfx_node = MainRootNode.vfx_libray.create_vfx_node_from_key(vfx_key)
	if !vfx_node:
		printerr("Failed to create VFX node from key '%s'." % [vfx_key])
		return
	actor_node.add_child(vfx_node)
	actor_node.play_shake()
	vfx_node.add_flash_text(str(-flash_number), Color.RED)
	vfx_node.start_vfx()


func create_flash_text_on_actor(actor:BaseActor, value:String, color:Color):
	var actor_node:ActorNode = MapController.actor_nodes[actor.Id]
	create_flash_text(actor_node, value, color)
	

func create_flash_text(parent_node:Node, value:String, color:Color):
	var new_node:FlashTextControl  = load("res://Scenes/Effects/flash_text_control.tscn").instantiate()
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
