@tool
class_name AreaEditorContainer
extends BackPatchContainer

@export var sub_viewport_container:SubViewportContainer
@export var root_subview_node:Node2D 
@export var grid_tile_layer:TileMapLayer
@export var center_sprite:Sprite2D
@export var pan_up_button:TextureButton
@export var pan_center_button:TextureButton
@export var pan_down_button:TextureButton
@export var edit_buttons_container:VBoxContainer

var mouse_pressed = false
var adding = true
var last_pressed_spot

var _center_spot = Vector2i(0,0)
var _root_start_pos:Vector2i
var _view_offset:Vector2i

var _editing_key:String
var _editing_areas:Dictionary = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	if Engine.is_editor_hint(): return
	pan_up_button.pressed.connect(on_pan_up)
	pan_center_button.pressed.connect(on_pan_center)
	pan_down_button.pressed.connect(on_pan_down)
	_root_start_pos = root_subview_node.position
	_view_offset = Vector2i.ZERO
	for button:Button in edit_buttons_container.get_children():
		_editing_areas[button.text] = []
	#load_button.pressed.connect(on_load)
	#copy_button.pressed.connect(on_copy)
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	super(delta)
	if Engine.is_editor_hint(): return
	if mouse_pressed:
		var cur_spot = grid_tile_layer.local_to_map(grid_tile_layer.get_local_mouse_position())
		if cur_spot != last_pressed_spot:
			_flip_spot(cur_spot)
	pass

func _input(event: InputEvent) -> void:
	if Engine.is_editor_hint(): return
	if not self.is_visible_in_tree():
		return
	if !_editing_areas.keys().has(_editing_key):
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
				adding = not _editing_areas[_editing_key].has(Vector2i(-spot.x, -spot.y))
				_flip_spot(spot)
			if m_event.button_index == 2:
				#print("Click 2")
				_center_spot = spot
				_sync_tiles()
		#else:
			#print("Click '%s' outside area: %s" % [m_event.global_position, grid_window_rect])
			
	if event is InputEventMouseButton and not (event as InputEventMouseButton).pressed:
		mouse_pressed = false





func has_change():
	#TODO
	return false

func clear():
	for button:Button in edit_buttons_container.get_children():
			button.queue_free()
	_editing_areas.clear()
	_editing_key = ""
	_sync_tiles()

func add_editable_area(key:String, val, show_now:bool):
	var arr = try_parse_as_area(val)
	if arr != null:
		_create_editing_area(key, arr, show_now)

func build_area_data(key:String)->String:
	var out_list = []
	if _editing_areas.has(key):
		for vec in _editing_areas[key]:
			out_list.append([vec.x, vec.y])
	return JSON.stringify(out_list)

func _create_editing_area(key:String, spots:Array, show_now:bool=false):
	if !_editing_areas.keys().has(key):
		var edit_button = Button.new()
		edit_button.text = key
		edit_button.disabled = show_now
		edit_button.pressed.connect(set_editing_area.bind(key))
		edit_buttons_container.add_child(edit_button)
	_editing_areas[key] = spots
	if show_now:
		set_editing_area(key)

func set_editing_area(key:String):
	if !_editing_areas.has(key):
		return
	for button:Button in edit_buttons_container.get_children():
			button.disabled = (button.text == key)
	_editing_key = key
	_sync_tiles()

func remove_editable_area(key:String):
	if _editing_areas.keys().has(key):
		_editing_areas.erase(key)
	for button:Button in edit_buttons_container.get_children():
		if button.text == key:
			button.queue_free()

func on_pan_up():
	_view_offset.y = min(7,_view_offset.y + 1)
	root_subview_node.position = _root_start_pos + (_view_offset * 16)
	
func on_pan_center():
	root_subview_node.position = _root_start_pos
	
func on_pan_down():
	_view_offset.y = max(-7,_view_offset.y - 1)
	root_subview_node.position = _root_start_pos + (_view_offset * 16)

func _flip_spot(clicked_spot:Vector2i):
	var rot_spot = Vector2i(-clicked_spot.x, -clicked_spot.y)
	if _editing_key == '':
		return
	if adding: 
		_editing_areas[_editing_key].append(rot_spot)
	else:
		_editing_areas[_editing_key].erase(rot_spot)
	last_pressed_spot = clicked_spot
	_sync_tiles()

func _sync_tiles():
	center_sprite.position = grid_tile_layer.map_to_local(_center_spot)
	grid_tile_layer.clear()
	if _editing_areas.keys().has(_editing_key):
		var flip_spots = []
		for spot in _editing_areas[_editing_key]:
			flip_spots.append(Vector2i(-spot.x, -spot.y))
		grid_tile_layer.set_cells_terrain_connect(flip_spots, 0, 0)

#func set_selected_spots(key:String, arr:Array):
	#if !_editing_areas.keys().has(key):
		#_editing_areas[key] = ''
		#_editing_key = key
	#_editing_areas[_editing_key].clear()
	#var min_y = 0
	#var max_y = 0
	#for sub in arr:
		## Flip spots to oriant north
		#_editing_areas[_editing_key].append(Vector2i(-sub[0], -sub[1]))
		#if min_y > sub[1]:
			#min_y = sub[1]
		#if max_y < sub[1]:
			#max_y = sub[1]
	#var avg_y = (max_y + min_y) / 2
	#_view_offset.y = avg_y
	#root_subview_node.position = _root_start_pos + (_view_offset * 16)
	#
	#_sync_tiles()
	
func get_selected_spots(key:String)->Array:
	var list = []
	if _editing_areas.has(key):
		for spot in _editing_areas[key]:
			# Flip spots to oriant north
			list.append([-spot.x, -spot.y])
	return list

static func try_parse_as_area(val):
	var arr = val
	if arr is String:
		arr = JSON.parse_string(val)
	if not arr is Array:
		return null
	if arr.size() == 0:
		return arr
	if arr[0] is Vector2i:
		return arr
	if arr[0] is Array:
		var out_list = []
		for sub in arr:
			out_list.append(Vector2i(sub[0], sub[1]))
		return out_list
	printerr("AreaSubEditorContainer: Failed to parse '%' as Array[int[]]." % [val])
	return null
