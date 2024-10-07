class_name TargetAreaDisplayNode
extends Node2D

@onready var map_controller:MapControllerNode = $".."
@onready var permade_target_area_tile_map:TileMapLayer =$TargetAreaTileMap
@onready var effect_area_tile_map:TileMapLayer =$EffectAreaTileMap

var _target_area_maps:Dictionary = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	permade_target_area_tile_map.visible = false
	pass # Replace with function body.

# Returns a unique key to use for clear_display later
func set_target_parameters(pos:MapPos, target_params:TargetParameters)->String:
	var target_area = target_params.get_valid_target_area(pos, true)
	return set_target_area(target_area)
	
func set_target_area(target_area:Dictionary):
	var new_area = permade_target_area_tile_map.duplicate()
	self.add_child(new_area)
	new_area.visible = true
	new_area.clear()
	var open_list = []
	var covered_list = []
	var blocked_list = []
	for spot in target_area.keys():
		if target_area[spot] == TargetParameters.LOS_VALUE.Open:
			open_list.append(spot)
		if target_area[spot] == TargetParameters.LOS_VALUE.Cover:
			covered_list.append(spot)
		if target_area[spot] == TargetParameters.LOS_VALUE.Blocked:
			blocked_list.append(spot)
	new_area.set_cells_terrain_connect(open_list,0,0)
	new_area.set_cells_terrain_connect(covered_list,0,1)
	var id = str(ResourceUID.create_id())
	_target_area_maps[id] = new_area
	return id
	
func clear_display(key:String, error_if_wrong_key:bool = true):
	if _target_area_maps.has(key):
		_target_area_maps[key].queue_free()
		_target_area_maps.erase(key)
	elif error_if_wrong_key:
		printerr("Wrong key given to clear display")
