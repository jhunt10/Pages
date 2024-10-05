class_name CombatRootControl
extends Control

@onready var QueController:QueControllerNode = $QueController
@onready var MapController:MapControllerNode = $MapControlerNode

@onready var QueInput = $CombatUiControl/QueInputControl
@onready var QueDisplay = $CombatUiControl/QueDisplayControl
@onready var GridCursor:GridCursorNode = $MapControlerNode/GridCursor
@onready var  StatDisplay:StatPanelControl = $CombatUiControl/StatPanelControl

@onready var ui_controller:UiStateController = $CombatUiControl
static var Instance:CombatRootControl 
var GameState:GameStateData

# Actors to create on ready {ActorKey,Position}
var actor_creation_que:Dictionary = {}
var player_actor_key:String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if !Instance: Instance = self
	else: 
		printerr("Multiple CombatRootControls found")
		queue_free()
		return
	for actor_key in actor_creation_que.keys():
		var actor_data = MainRootNode.actor_libary.get_actor_data(actor_key)
		var new_actor = create_new_actor(actor_data, 1, actor_creation_que[actor_key])
		new_actor.effects.add_effect("ManaRegenOnTurn", {})
		new_actor.effects.add_effect("StaminaRegenOnTurn", {})
		if actor_key == player_actor_key:
			new_actor.FactionIndex = 0
			StatDisplay.set_actor(new_actor)
			QueInput.set_actor(new_actor)
			QueDisplay.set_actor(new_actor)
	actor_creation_que.clear()
	
	ui_controller.set_ui_state(UiStateController.UiStates.ActionInput)
	MapController._build_terrain()
	pass # Replace with function body.


func set_init_state(map_data:Dictionary, player_actor:String, actors_pos:Dictionary):
	if GameState:
		printerr("Combate Scene already init")
		return
	GameState = GameStateData.new()
	GameState.MapState = MapStateData.new(GameState, map_data)
	player_actor_key = player_actor
	actor_creation_que = actors_pos
	
func kill_actor(actor:BaseActor):
	GameState.kill_actor(actor)
	
func create_new_actor(data:Dictionary, faction_index:int, pos:MapPos):
	#var file = FileAccess.open(path, FileAccess.READ)
	#var text:String = file.get_as_text()
	#var data = JSON.parse_string(text)
	var new_actor = BaseActor.new(data, faction_index)
	
	# Add actor to GameState and set position
	GameState.Actors[new_actor.Id] = new_actor
	GameState.MapState.set_actor_pos(new_actor, pos)
	QueController.add_action_que(new_actor.Que)
	
	# Register new node with MapController and sync  pos
	var new_node = load("res://Scenes/actor_node.tscn").instantiate()
	new_node.set_actor(new_actor)
	MapController.add_actor_node(new_actor, new_node)
	MapController._sync_actor_positions()
	new_node.visible = true
	
	return new_actor

func create_new_missile_node(missile:BaseMissile):
	var new_node:MissileNode  = load("res://Scenes/missile_node.tscn").instantiate()
	new_node.set_missile_data(missile)
	MapController.add_missile_node(missile, new_node)
	
func create_damage_effect(actor:BaseActor, veffect_key:String, flash_number:int):
	var new_node:DamageEffectNode  = load("res://Scenes/Effects/damage_effect_node.tscn").instantiate()
	var actor_node:ActorNode = MapController.actor_nodes[actor.Id]
	new_node.set_props(veffect_key, actor_node, flash_number)
	actor_node.add_child(new_node)
	actor_node.play_shake()
	
	
func create_flash_text(actor:BaseActor, value:String, color:Color):
	var new_node:FlashTextControl  = load("res://Scenes/Effects/flash_text_control.tscn").instantiate()
	new_node.set_values(value, color)
	var actor_node:ActorNode = MapController.actor_nodes[actor.Id]
	actor_node.add_child(new_node)

func create_damage_number(actor:BaseActor, damage:int):
	if damage < 0:
		create_flash_text(actor, "+"+str(abs(damage)), Color.DARK_GREEN)
	else:
		create_flash_text(actor, "-"+str(damage), Color.DARK_RED)
		
	
func add_zone(zone:BaseZone):
	var new_node:ZoneNode  = load("res://Scenes/zone_node.tscn").instantiate()
	new_node._zone = zone
	MapController.add_zone_node(zone, new_node)
