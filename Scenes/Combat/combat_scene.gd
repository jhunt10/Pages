class_name CombatRootControl
extends Control

signal actor_spawned(actor:BaseActor)

@export var ui_control:CombatUiControl
@export var camera:MoveableCamera2D

@onready var MapController:MapControllerNode = $MapControlerNode

@onready var GridCursor:GridCursorNode = $MapControlerNode/GridCursor

static var Instance:CombatRootControl 
static var QueController:ActionQueController = ActionQueController.new()
	
var GameState:GameStateData

# Actors to create on ready {ActorKey,Position}
var actor_creation_que:Array

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
	
	for actor_info in actor_creation_que:
		var actor_id = actor_info['ActorId']
		var actor_pos = actor_info['Pos']
		var actor = ActorLibrary.get_actor(actor_id)
		if actor_info.get('IsPlayer', false):
			actor.FactionIndex = 0
			ui_control.set_player_actor(actor)
			add_actor(actor, 0, actor_pos)
			camera.snap_to_map_pos(actor_pos)
			camera.zoom = Vector2(2,2)
		else:
			add_actor(actor, 1, actor_pos)
		
	actor_creation_que.clear()
	
	ui_control.ui_state_controller.set_ui_state(UiStateController.UiStates.ActionInput)
	
	MapController._build_terrain()
	for actor:BaseActor in GameState._actors.values():
		actor.on_combat_start()
	pass # Replace with function body.

func _process(delta: float) -> void:
	QueController.update(delta)

func set_init_state(map_data:Dictionary, actor_creation_que:Array):
	if GameState:
		printerr("Combate Scene already init")
		return
	GameState = GameStateData.new()
	GameState.MapState = MapStateData.new(GameState, map_data)
	self.actor_creation_que = actor_creation_que
	
func kill_actor(actor:BaseActor):
	actor.die()
	QueController.remove_action_que(actor.Que)
	#if actor.leaves_corpse:
	GameState.MapState.set_actor_layer(actor, MapStateData.MapLayers.Corpse)
	#else:
		#delete_actor(actor)


func delete_actor(actor:BaseActor):
	GameState.MapState.delete_actor(actor)
	MapController.delete_actor(actor)
	#GameState.Actors.erase(actor.Id)
	
func add_actor(actor:BaseActor, faction_id:int, pos:MapPos):
	if GameState._actors.keys().has(actor.Id):
		printerr("Actor '%s' already added" % [actor.Id])
		return
	# Add actor to GameState and set position
	actor.FactionIndex = faction_id
	GameState.add_actor(actor)
	GameState.MapState.set_actor_pos(actor, pos, actor.spawn_map_layer)
	QueController.add_action_que(actor.Que)
	
	# Register new node with MapController and sync  pos
	var new_node = load("res://Scenes/Combat/MapObjects/actor_node.tscn").instantiate()
	new_node.set_actor(actor)
	MapController.add_actor_node(actor, new_node)
	MapController._sync_actor_positions()
	new_node.visible = true
	
	if actor._allow_auto_que:
		actor.auto_build_que(QueController.action_index)
	
	actor_spawned.emit(actor)

func create_new_missile_node(missile):
	var new_node:MissileNode  = load("res://Scenes/Combat/MapObjects/missile_node.tscn").instantiate()
	new_node.set_missile_data(missile)
	MapController.add_missile_node(missile, new_node)
	
func create_damage_effect(target_actor:BaseActor, vfx_key:String, flash_number:int, source = null):
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
		extra_data['Direction'] = source.node.rot_dir
	var vfx_node = MainRootNode.vfx_libray.create_vfx_node(vfx_data, extra_data)
	if !vfx_node:
		printerr("Failed to create VFX node from key '%s'." % [vfx_key])
		return
	target_actor_node.vfx_holder.add_child(vfx_node)
	if flash_number >= 0:
		if flash_number > 0 and vfx_node._data.shake_actor:
			target_actor_node.play_shake()
		vfx_node.add_flash_text(str(0-flash_number), Color.RED)
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
