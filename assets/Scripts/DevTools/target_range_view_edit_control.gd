class_name TargetRangeViewEditControl
extends Control

signal selection_changed()

@onready var grid_tile_layer:TileMapLayer = $CenterContainer/SubViewportContainer/SubViewport/Node2D/TileMapLayer
@onready var center_sprite:Sprite2D = $CenterContainer/SubViewportContainer/SubViewport/Node2D/TileMapLayer/Sprite2D

var selected_spots:Array = []
var mouse_pressed = false
var adding = true
var last_pressed_spot

var _center_spot = Vector2i(0,0)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
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
		var grid_window_rect: Rect2 = Rect2(self.global_position, self.size)
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

func _flip_spot(cur_spot):
	printerr("Flip Spot: " + str(cur_spot))
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

func get_selected_spots()->Array:
	var list = []
	for spot in selected_spots:
		# Flip spots to oriant north
		list.append([-spot.x, -spot.y])
	return list

func set_selected_spots(arr:Array):
	selected_spots.clear()
	for sub in arr:
		# Flip spots to oriant north
		selected_spots.append(Vector2i(-sub[0], -sub[1]))
	_sync_tiles()

func clear():
	selected_spots.clear()
	_sync_tiles()

#func on_copy():
	#_set_notification_text("Copied")
	#DisplayServer.clipboard_set(output.text)
	#pass
#
#func on_load():
	#var arr = JSON.parse_string(output.text)
	#selected_spots.clear()
	#for sub in arr:
		#selected_spots.append(Vector2i(sub[0], sub[1]))
	#_sync_tiles()
