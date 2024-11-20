class_name TargetAreaDisplayNode
extends Node2D

@onready var map_controller:MapControllerNode = $".."
@onready var permade_target_area_tile_map:TileMapLayer =$TargetAreaTileMap
#@onready var effect_area_tile_map:TileMapLayer =$EffectAreaTileMap

# TODO: Create new instances of this class for each new target area
var _target_area_maps:Dictionary = {}
var _effect_area_maps:Dictionary = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	permade_target_area_tile_map.visible = false
	pass # Replace with function body.

#func _process(delta: float) -> void:
	#if _effect_area_maps.size() > 0:
		#var mouse_pos = CombatRootControl.Instance.GridCursor.current_spot
		#var map_pos = permade_target_area_tile_map.map_to_local(mouse_pos) - permade_target_area_tile_map.map_to_local(Vector2i.ZERO)
		#for effect_area:TileMapLayer in _effect_area_maps.values():
			#effect_area.position = map_pos

func show_area_effect(key):
	if _effect_area_maps.keys().has(key):
		_effect_area_maps[key].visible = true

func set_area_effect_coor(key, coor):
	var map_pos = permade_target_area_tile_map.map_to_local(coor) - permade_target_area_tile_map.map_to_local(Vector2i.ZERO)
	var effect_area:TileMapLayer = _effect_area_maps.get(key)
	if effect_area:
		effect_area.position = map_pos
		effect_area.visible = true

func hide_area_effect(key):
	if _effect_area_maps.keys().has(key):
		_effect_area_maps[key].visible = false

func build_from_target_selection_data(data:TargetSelectionData, show_area_effect:bool=false):
	var new_area:TileMapLayer = permade_target_area_tile_map.duplicate()
	self.add_child(new_area)
	new_area.visible = true
	new_area.clear()
	
	var id = str(ResourceUID.create_id())
	_target_area_maps[id] = new_area
	
	for coor in data.get_targeting_area_coords():
		var los_val = data.get_coords_los(coor)
		var selectable = data.is_coor_selectable(coor)
		if los_val == TargetingHelper.LOS_VALUE.Open:
			if selectable:
				new_area.set_cell(coor, 0, Vector2i(2,0))
			else:
				new_area.set_cell(coor, 0, Vector2i(0,0))
			#open_list.append(spot)
		if los_val == TargetingHelper.LOS_VALUE.Cover:
			if selectable:
				new_area.set_cell(coor, 0, Vector2i(3,0))
			else:
				new_area.set_cell(coor, 0, Vector2i(1,0))
		if los_val == TargetingHelper.LOS_VALUE.Blocked:
			new_area.set_cell(coor, 0, Vector2i(0,1))
	
	if data.target_params.has_area_of_effect():
		var effect_area = data.target_params.get_area_of_effect(MapPos.new(0,0,0, data.actor_pos.dir))
		var new_effect_area:TileMapLayer = permade_target_area_tile_map.duplicate()
		self.add_child(new_effect_area)
		new_effect_area.visible = show_area_effect
		new_effect_area.clear()
		new_effect_area.set_cells_terrain_connect(effect_area, 0, 0)
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
