class_name TargetAreaDisplayNode
extends Node2D

@onready var map_controller:MapControllerNode = $".."
@onready var target_area_tile_map:TileMapLayer =$TargetAreaTileMap
@onready var effect_area_tile_map:TileMapLayer =$EffectAreaTileMap

var current_view_key:String
var _target_params:TargetParameters


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Returns a unique key to use for clear_display later
func set_target_parameters(pos:MapPos, target_params:TargetParameters)->String:
	if current_view_key != '':
		printerr("New TargetArea given to display before clearing")
	_target_params = target_params
	target_area_tile_map.clear()
	self.visible = true
	var target_area = _target_params.target_area.to_map_spots(pos)
	target_area_tile_map.set_cells_terrain_connect(target_area,0,0)
	current_view_key = str(ResourceUID.create_id())
	return current_view_key
	
func clear_display(key:String, error_if_wrong_key:bool = true):
	if key == current_view_key:
		target_area_tile_map.clear()
		self.visible = false
		current_view_key = ''
	elif error_if_wrong_key:
		printerr("Wrong key given to clear display")
