class_name TargetAreaDisplayNode
extends Node2D

@onready var map_controller:MapControllerNode = $".."
@onready var permade_target_area_tile_map:TileMapLayer =$TargetAreaTileMap
@onready var effect_area_tile_map:TileMapLayer =$EffectAreaTileMap

var _target_area_maps:Dictionary = {}
var _effect_area_maps:Dictionary = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	permade_target_area_tile_map.visible = false
	pass # Replace with function body.

func _process(delta: float) -> void:
	if _effect_area_maps.size() > 0:
		var mouse_pos = CombatRootControl.Instance.GridCursor.current_spot
		var map_pos = permade_target_area_tile_map.map_to_local(mouse_pos) - permade_target_area_tile_map.map_to_local(Vector2i.ZERO)
		for effect_area:TileMapLayer in _effect_area_maps.values():
			effect_area.position = map_pos

func show_area_effect(key):
	if _effect_area_maps.keys().has(key):
		_effect_area_maps[key].visible = true

func hide_area_effect(key):
	if _effect_area_maps.keys().has(key):
		_effect_area_maps[key].visible = false

# Returns a unique key to use for clear_display later
func set_target_parameters(pos:MapPos, target_params:TargetParameters, show_area_effect=false)->String:
	var target_area = target_params.get_valid_target_area(pos)
	var effect_area = [Vector2i.ZERO]
	if target_params.has_area_of_effect():
		effect_area = target_params.get_area_of_effect(MapPos.new(0,0,0, pos.dir))
	return set_target_area(target_area, effect_area, show_area_effect)

func get_target_tile_map_layer(key)->TileMapLayer:
	return _target_area_maps.get(key, null)

func set_target_area(target_area:Dictionary, effect_area:Array, show_area_effect:bool):
	var new_area:TileMapLayer = permade_target_area_tile_map.duplicate()
	self.add_child(new_area)
	new_area.visible = true
	new_area.clear()
	var open_list = []
	var covered_list = []
	var blocked_list = []
	for spot in target_area.keys():
		if target_area[spot] == TargetingHelper.LOS_VALUE.Open:
			open_list.append(spot)
		if target_area[spot] == TargetingHelper.LOS_VALUE.Cover:
			covered_list.append(spot)
		if target_area[spot] == TargetingHelper.LOS_VALUE.Blocked:
			blocked_list.append(spot)
	new_area.set_cells_terrain_connect(open_list,0,0)
	new_area.set_cells_terrain_connect(covered_list,0,1)
	
	var id = str(ResourceUID.create_id())
	_target_area_maps[id] = new_area
	
	if effect_area:
		var new_effect_area = permade_target_area_tile_map.duplicate()
		self.add_child(new_effect_area)
		new_effect_area.visible = show_area_effect
		new_effect_area.clear()
		new_effect_area.set_cells_terrain_connect(effect_area,0,2)
		_effect_area_maps[id] = new_effect_area
	return id
	
func clear_display(key:String, error_if_wrong_key:bool = true):
	if _effect_area_maps.has(key):
		_effect_area_maps[key].queue_free()
		_effect_area_maps.erase(key)
	if _target_area_maps.has(key):
		_target_area_maps[key].queue_free()
		_target_area_maps.erase(key)
	elif error_if_wrong_key:
		printerr("Wrong key given to clear display")
