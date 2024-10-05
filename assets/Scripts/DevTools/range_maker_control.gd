extends Control

@onready var grid_window:NinePatchRect = $VBoxContainer/GridWindow
@onready var grid_tile_layer:TileMapLayer = $VBoxContainer/GridWindow/SubViewportContainer/SubViewport/Node2D/TileMapLayer
@onready var center_sprite:Sprite2D = $VBoxContainer/GridWindow/SubViewportContainer/SubViewport/Node2D/TileMapLayer/Sprite2D
@onready var output:TextEdit = $VBoxContainer/TextOutput
@onready var load_button:Button = $VBoxContainer/HBoxContainer/LoadButton
@onready var copy_button:Button = $VBoxContainer/HBoxContainer/CopyButton
@onready var label:Label = $VBoxContainer/HBoxContainer/Label

var selected_spots:Array = []
var mouse_pressed = false
var adding = true
var last_pressed_spot
var label_timer_delay:int = 3
var label_timer = 0

var _center_spot = Vector2i(0,0)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_button.pressed.connect(on_load)
	copy_button.pressed.connect(on_copy)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if label_timer > 0:
		label_timer = max(label_timer - delta, 0)
		if label_timer == 0:
			label.text = ""
	if mouse_pressed:
		var cur_spot = grid_tile_layer.local_to_map(grid_tile_layer.get_local_mouse_position())
		if cur_spot != last_pressed_spot:
			_flip_spot(cur_spot)
	pass
	
func _set_text(val:String):
	label.text = val
	label_timer = label_timer_delay

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and (event as InputEventMouseButton).pressed:
		var m_event = event as InputEventMouseButton
		var grid_window_rect: Rect2 = Rect2(grid_window.global_position, grid_window.size)
		if grid_window_rect.has_point(m_event.global_position):
			var spot = grid_tile_layer.local_to_map(grid_tile_layer.get_local_mouse_position())
			print("Clicked Spot: " + str(spot) + " Index: " + str(m_event.button_index))
			if m_event.button_index == 1:
				mouse_pressed = true
				adding = not selected_spots.has(spot)
				_flip_spot(spot)
			if m_event.button_index == 2:
				print("Click 2")
				_center_spot = spot
				_sync_tiles()
		else:
			print("Click '%s' outside area: %s" % [m_event.global_position, grid_window_rect])
			
	if event is InputEventMouseButton and not (event as InputEventMouseButton).pressed:
		mouse_pressed = false

func _flip_spot(cur_spot):
	print("Flip Spot: " + str(cur_spot))
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
	output.text = JSON.stringify(list)

func on_copy():
	_set_text("Copied")
	DisplayServer.clipboard_set(output.text)
	pass

func on_load():
	var arr = JSON.parse_string(output.text)
	selected_spots.clear()
	for sub in arr:
		selected_spots.append(Vector2i(sub[0], sub[1]))
	_sync_tiles()
