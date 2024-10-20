class_name TargetRangeViewEditControl
extends Control

signal selection_changed()

@onready var sub_viewport_container:SubViewportContainer = $CenterContainer/HBoxContainer/SubViewportContainer
@onready var root_subview_node:Node2D = $CenterContainer/HBoxContainer/SubViewportContainer/SubViewport/Node2D
@onready var grid_tile_layer:TileMapLayer = $CenterContainer/HBoxContainer/SubViewportContainer/SubViewport/Node2D/TileMapLayer
@onready var center_sprite:Sprite2D = $CenterContainer/HBoxContainer/SubViewportContainer/SubViewport/Node2D/TileMapLayer/Sprite2D
@onready var pan_up_button:TextureButton = $CenterContainer/HBoxContainer/PanControl/UpButton
@onready var pan_center_button:TextureButton = $CenterContainer/HBoxContainer/PanControl/CenterButton
@onready var pan_down_button:TextureButton = $CenterContainer/HBoxContainer/PanControl/DownButton

var selected_spots:Array = []
var mouse_pressed = false
var adding = true
var last_pressed_spot

var _center_spot = Vector2i(0,0)
var _root_start_pos:Vector2i
var _view_offset:Vector2i

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pan_up_button.pressed.connect(on_pan_up)
	pan_center_button.pressed.connect(on_pan_center)
	pan_down_button.pressed.connect(on_pan_down)
	_root_start_pos = root_subview_node.position
	_view_offset = Vector2i.ZERO
	#load_button.pressed.connect(on_load)
	#copy_button.pressed.connect(on_copy)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if mouse_pressed:
		var cur_spot = grid_tile_layer.local_to_map(grid_tile_layer.get_local_mouse_position())
		if cur_spot != last_pressed_spot:
			_flip_spot(cur_spot)
	pass

func _input(event: InputEvent) -> void:
	if not self.is_visible_in_tree():
		return
	if event is InputEventMouseButton and (event as InputEventMouseButton).pressed:
		var m_event = event as InputEventMouseButton
		var grid_window_rect: Rect2 = Rect2(sub_viewport_container.global_position, sub_viewport_container.size)
		#print("Event: Rect: %s | spot: %s" % [grid_window_rect, m_event.global_position])
		if grid_window_rect.has_point(m_event.global_position):
			var spot = grid_tile_layer.local_to_map(grid_tile_layer.get_local_mouse_position())
			#print("Clicked Spot: " + str(spot) + " Index: " + str(m_event.button_index))
			if m_event.button_index == 1:
				mouse_pressed = true
				adding = not selected_spots.has(spot)
				_flip_spot(spot)
			if m_event.button_index == 2:
				#print("Click 2")
				_center_spot = spot
				_sync_tiles()
		#else:
			#print("Click '%s' outside area: %s" % [m_event.global_position, grid_window_rect])
			
	if event is InputEventMouseButton and not (event as InputEventMouseButton).pressed:
		mouse_pressed = false

func on_pan_up():
	_view_offset.y = min(7,_view_offset.y + 1)
	root_subview_node.position = _root_start_pos + (_view_offset * 16)
	
func on_pan_center():
	root_subview_node.position = _root_start_pos
	
func on_pan_down():
	_view_offset.y = max(-7,_view_offset.y - 1)
	root_subview_node.position = _root_start_pos + (_view_offset * 16)

func _flip_spot(cur_spot):
	if adding: 
		selected_spots.append(cur_spot)
	else:
		selected_spots.erase(cur_spot)
	last_pressed_spot = cur_spot
	_sync_tiles()

func _sync_tiles():
	center_sprite.position = grid_tile_layer.map_to_local(_center_spot)
	grid_tile_layer.clear()
	grid_tile_layer.set_cells_terrain_connect(selected_spots, 0, 0)
	var list = []
	for spot in selected_spots:
		list.append([spot.x, spot.y])
	#output.text = JSON.stringify(list)

func set_selected_spots(arr:Array):
	selected_spots.clear()
	var min_y = 0
	var max_y = 0
	for sub in arr:
		# Flip spots to oriant north
		selected_spots.append(Vector2i(-sub[0], -sub[1]))
		if min_y > sub[1]:
			min_y = sub[1]
		if max_y < sub[1]:
			max_y = sub[1]
	var avg_y = (max_y + min_y) / 2
	_view_offset.y = avg_y
	root_subview_node.position = _root_start_pos + (_view_offset * 16)
	
	_sync_tiles()
	
func get_selected_spots()->Array:
	var list = []
	for spot in selected_spots:
		# Flip spots to oriant north
		list.append([-spot.x, -spot.y])
	return list

func clear():
	selected_spots.clear()
	_sync_tiles()
