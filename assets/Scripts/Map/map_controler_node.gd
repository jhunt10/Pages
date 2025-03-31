@tool
class_name MapControllerNode
extends Node2D

const LOGGING = false

var grid_tile_map:TileMapLayer:
	get:
		return $GridDisplayLayer
@export var map_name:String
@export var zone_tile_map:TileMapLayer 
@export var actor_tile_map:TileMapLayer 
@export var item_tile_map:TileMapLayer 
@export var terrain_path_map:TerrainPathingMap
@export var marker_tile_map:TileMapLayer
@onready var target_area_display:TargetAreaDisplayNode = $TargetAreaDisplayNode

static var game_state:GameStateData:
	get:
		return CombatRootControl.Instance.GameState

var actor_nodes = {}
var item_nodes = {}
var missile_nodes = {}
var zone_nodes = {}

var _cached_marker_poses:Dictionary = {}
var _cached_marker_paths:Dictionary = {}
var _cached_spawn_nodes:Dictionary = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Engine.is_editor_hint(): return
	terrain_path_map.hide()
	if LOGGING: print("Readying MapCont: Inst:%s" % [CombatRootControl.Instance])
	CombatRootControl.Instance.actor_spawned.connect(create_actor_node)
	CombatRootControl.QueController.end_of_frame.connect(_sync_positions)
	pass # Replace with function body.

func get_map_data()->Dictionary:
	var map_data = terrain_path_map.get_map_data()
	var actors = []
	for child in marker_tile_map.get_children():
		if child is ActorSpawnNode:
			if !child.visible:
				continue
			var pos = MapPos.new(child.map_coor.x, child.map_coor.y, 0, child.facing)
			var data = {"Pos": pos}
			if child.spawn_actor_key != '':
				if child.spawn_actor_key == "RandomEnemy":
					data["ActorKey"] = _get_random_enemy_key()
				else:
					data["ActorKey"] = child.spawn_actor_key
			if child.spawn_actor_id != '':
				data["ActorId"] = child.spawn_actor_id
			if child.is_player:
				data["FactionId"] = 0
			else:
				data["FactionId"] = 1
			data['WaitToSpawn'] = child.wait_to_spawn
			actors.append(data)
			var marker_name = child.marker_name
			_cached_spawn_nodes[marker_name] = child
		elif child is MapMarkerNode:
			var pos = MapPos.new(child.map_coor.x, child.map_coor.y, 0, child.facing)
			var marker_name = child.marker_name
			_cached_marker_poses[marker_name] = pos
		elif child is MapPathNode:
			var marker_name = child.marker_name
			_cached_marker_paths[marker_name] = child
	marker_tile_map.hide()
	map_data['Actors'] = actors
	return map_data

func _get_random_enemy_key()->String:
	var map_data = MapLoader.get_map_data(map_name)
	var enemy_data = map_data.get("EnemySet", {})
	var enemy_set = {}
	for enemy_key in enemy_data:
		enemy_set[enemy_key] = enemy_data[enemy_key].get("Weight", -1)
	var actor_key = RandomHelper.roll_from_set(enemy_set)
	return actor_key
	

func get_pos_marker(marker_name)->MapPos:
	if _cached_marker_poses.has(marker_name):
		return _cached_marker_poses[marker_name]
	return null
	
func get_path_marker(marker_name)->MapPathNode:
	if _cached_marker_paths.has(marker_name):
		return _cached_marker_paths[marker_name]
	return null
	
func get_spawn_node(marker_name)->ActorSpawnNode:
	if _cached_spawn_nodes.has(marker_name):
		return _cached_spawn_nodes[marker_name]
	return null

func create_actor_node(actor:BaseActor, map_pos:MapPos, wait_to_show:bool=false)->ActorNode:
	if Engine.is_editor_hint(): return
	if LOGGING: print("MapControllerNode: Creating Actor Node: %s" % [actor.Id])
	if actor_nodes.keys().has(actor.Id):
		return actor_nodes[actor.Id]
	
	var new_node:ActorNode = load("res://Scenes/Combat/MapObjects/actor_node.tscn").instantiate()
	actor_nodes[actor.Id] = new_node
	actor_tile_map.add_child(new_node)
	new_node.position = actor_tile_map.map_to_local(map_pos.to_vector2i())
	new_node.set_actor(actor)
	new_node.set_map_pos(map_pos)
	new_node.visible = !wait_to_show
	new_node.tree_exiting.connect(_on_actor_node_leave_tree.bind(actor.Id))
	if LOGGING: print("MapControllerNode: Created Actor Node: %s" % [actor.Id])
	return new_node

func _on_actor_node_leave_tree(actor_id):
	if actor_nodes.has(actor_id):
		actor_nodes.erase(actor_id)

func delete_actor_node(actor:BaseActor):
	if Engine.is_editor_hint(): return
	var node:ActorNode = actor_nodes.get(actor.Id, null)
	if !node:
		return
	node.queue_free()
	actor_nodes.erase(actor.Id)
	
func create_item_node(item:BaseItem, map_pos:MapPos):
	if Engine.is_editor_hint(): return
	if LOGGING: print("MapControllerNode: Creating Item Node: %s" % [item.Id])
	if item_nodes.keys().has(item.Id):
		return
	
	var new_node = load("res://Scenes/Combat/MapObjects/item_node.tscn").instantiate()
	item_nodes[item.Id] = new_node
	item_tile_map.add_child(new_node)
	new_node.position = item_tile_map.map_to_local(map_pos.to_vector2i())
	new_node.set_item(item)
	new_node.visible = true
	if LOGGING: print("MapControllerNode: Created item Node: %s" % [item.Id])

func delete_item_node(item:BaseItem):
	if Engine.is_editor_hint(): return
	var node:ItemNode = item_nodes.get(item.Id, null)
	if !node:
		return
	node.queue_free()
	item_nodes.erase(item.Id)

func add_missile_node(missile:BaseMissile, node:MissileNode):
	if Engine.is_editor_hint(): return
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
	if Engine.is_editor_hint(): return
	zone_nodes[zone.Id] = node
	# Set node parent if not already set
	var current_partent = node.get_parent()
	if current_partent != actor_tile_map and current_partent != null:
		current_partent.remove_child(node)
	
	zone_tile_map.add_child(node)
	node.position = actor_tile_map.map_to_local(zone.get_pos().to_vector2i())

func delete_zone_node(zone:BaseZone):
	if Engine.is_editor_hint(): return
	var node:ZoneNode = zone_nodes.get(zone.Id, null)
	if !node:
		return
	node.queue_free()
	zone_nodes.erase(zone.Id)


func _sync_positions():
	if Engine.is_editor_hint(): return
	#_build_terrain()
	#_sync_actor_positions()
	#_sync_missile_positions()

#func _sync_actor_positions():
	#if Engine.is_editor_hint(): return
	#for node:ActorNode in actor_nodes.values():
		#var actor = game_state.get_actor(node.Actor.Id, true)
		#if !node:
			#if LOGGING: printerr("Failed to find node for actor: ", actor.Id)
			#continue
		#var pos = game_state.get_actor_pos(actor)
		#node.set_display_pos(pos)
		#var local_pos = actor_tile_map.map_to_local(Vector2i(pos.x, pos.y))
		#
		## Set actor parent if not already set
		#var current_partent = node.get_parent()
		#if current_partent != actor_tile_map and current_partent != null:
			#current_partent.remove_child(node)
			#actor_tile_map.add_child(node)
		#elif current_partent == null:
			#actor_tile_map.add_child(node)
		#node.position = local_pos

func _sync_missile_positions():
	if Engine.is_editor_hint(): return
	# Clean up old nodes
	for missile_id in missile_nodes.keys():
		if !is_instance_valid(missile_nodes[missile_id]):
			missile_nodes.erase(missile_id)
	for missile:BaseMissile in game_state.Missiles.values():
		var node:MissileNode = missile_nodes.get(missile.Id, null)
		if !node:
			if LOGGING: printerr("Failed to find node for missile: ", missile.Id)
			continue
		node.sync_pos()
