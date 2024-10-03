class_name MapControllerNode
extends Node2D

@onready var que_controler:QueControllerNode = $"../QueController"
@onready var actor_tile_map:TileMapLayer = $ActorTileMap
@onready var target_area_display:TargetAreaDisplayNode = $TargetAreaDisplayNode

static var game_state:GameStateData:
	get:
		return CombatRootControl.Instance.GameState

var actor_nodes = {}
var missile_nodes = {}
var zone_nodes = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	que_controler.end_of_frame.connect(_sync_positions)
	pass # Replace with function body.

func add_actor_node(actor:BaseActor, node:ActorNode):
	actor_nodes[actor.Id] = node
	
func _build_terrain():
	var map_state = game_state.MapState
	var terrain_arrys = {}
			
	for spot:MapSpot in map_state.list_map_spots():
		if spot.terrain_index == 0:
			actor_tile_map.set_cell(Vector2i(spot.X,spot.Y), 0, Vector2i(10,1))
		else:
			if not terrain_arrys.keys().has(spot.terrain_index):
				terrain_arrys[spot.terrain_index] = []
			terrain_arrys[spot.terrain_index].append(Vector2i(spot.X, spot.Y))
	for terrain_index in terrain_arrys.keys():
		actor_tile_map.set_cells_terrain_connect(terrain_arrys[terrain_index],0,0)
	
	
func add_missile_node(missile:BaseMissile, node:MissileNode):
	missile_nodes[missile.Id] = node
	game_state.add_missile(missile)
	# Set missile parent if not already set
	var current_partent = node.get_parent()
	if current_partent != actor_tile_map and current_partent != null:
		current_partent.remove_child(node)
		actor_tile_map.add_child(node)
	elif current_partent == null:
		actor_tile_map.add_child(node)
	node.sync_pos()
	
func add_zone_node(zone:BaseZone, node:ZoneNode):
	zone_nodes[zone.Id] = node
	game_state.add_zone(zone)
	# Set node parent if not already set
	var current_partent = node.get_parent()
	if current_partent != actor_tile_map and current_partent != null:
		current_partent.remove_child(node)
		
	#var pos = zone._get_pos()
	if zone.is_aura:
		var actor_node:ActorNode = actor_nodes[zone._source_actor.Id]
		actor_node.add_child(node)
		node.position = actor_tile_map.map_to_local(Vector2i(-1,-1))
	else:
		actor_tile_map.add_child(node)
		
func _sync_positions():
	_build_terrain()
	_sync_actor_positions()
	_sync_missile_positions()

func _sync_actor_positions():
	for actor in game_state.Actors.values():
		var node = actor_nodes.get(actor.Id, null)
		if !node:
			printerr("Failed to find node for actor: ", actor.Id)
			continue
		var pos = game_state.MapState.get_actor_pos(actor)
		node.set_display_pos(pos)
		var local_pos = actor_tile_map.map_to_local(Vector2i(pos.x, pos.y))
		
		# Set actor parent if not already set
		var current_partent = node.get_parent()
		if current_partent != actor_tile_map and current_partent != null:
			current_partent.remove_child(node)
			actor_tile_map.add_child(node)
		elif current_partent == null:
			actor_tile_map.add_child(node)
			
		node.position = local_pos

func _sync_missile_positions():
	# Clean up old nodes
	for missile_id in missile_nodes.keys():
		if !is_instance_valid(missile_nodes[missile_id]):
			missile_nodes.erase(missile_id)
	for missile:BaseMissile in game_state.Missiles.values():
		var node:MissileNode = missile_nodes.get(missile.Id, null)
		if !node:
			printerr("Failed to find node for missile: ", missile.Id)
			continue
		node.sync_pos()
