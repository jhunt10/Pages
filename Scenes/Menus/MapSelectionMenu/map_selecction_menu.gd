class_name MapSelectionMenu
extends Control

@export var premade_option_button:CampOptionButton
@export var option_button_container:VBoxContainer
@export var description_box:RichTextLabel
@export var map_preview_image:TextureRect
@export var back_button:CampOptionButton
@export var explore_button:CampOptionButton
@export var color_div:Control

var _selected_map_key
var _next_unlock_map_key = ''
var _map_buttons:Dictionary = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	premade_option_button.hide()
	if MainRootNode.Instance:
		explore_button.button.pressed.connect(_on_explore)
		back_button.button.pressed.connect(MainRootNode.Instance.open_camp_menu)
	_build_options()

func _build_options():
	var maps = MapLoader.get_map_datas()
	var sorted_map_array = maps.values()
	sorted_map_array.sort_custom(_sort_maps)
	
	var index = -1
	var newest_key = ''
	var has_maps_left_to_unlock = false
	for sorted_data in sorted_map_array:
		var map_key = sorted_data.get("MapKey")
		var new_button:CampOptionButton = premade_option_button.duplicate()
		var disabled = index >= StoryState._story_stage_index +1
		if disabled:
			has_maps_left_to_unlock = true
			new_button.disabled = true
			new_button.text = "           ?????????            "
		else:
			newest_key = map_key
			new_button.text = maps[map_key]['MapName']
			new_button.button.pressed.connect(_on_button_pressed.bind(map_key))
		option_button_container.add_child(new_button)
		new_button.show()
		_map_buttons[map_key] = new_button
		if index < 0:
			option_button_container.remove_child(color_div)
			option_button_container.add_child(color_div)
		index += 1
	if _selected_map_key:
		display_map_details(_selected_map_key)
	else:
		_on_button_pressed(newest_key)
	if has_maps_left_to_unlock:
		_next_unlock_map_key = newest_key
		

func _sort_maps(a, b)->bool:
	return a.get("SortOrder", 0) < b.get("SortOrder", 0)

func _on_button_pressed(map_key):
	_selected_map_key = map_key
	display_map_details(_selected_map_key)
	pass

func display_map_details(map_key):
	for button:CampOptionButton in _map_buttons.values():
		button.is_highlighted = false
		button.highlight.hide()
	print("Map Display: %s" % [map_key])
	_map_buttons[map_key].highlight.show()
	_map_buttons[map_key].is_highlighted = true
	var map_data = MapLoader.get_map_data(map_key)
	description_box.text = map_data.get("Description")
	map_preview_image.texture = SpriteCache.get_sprite(map_data['LoadPath'].path_join("preview_image.png"))

func _on_explore():
	if !_selected_map_key:
		return
	var path = MapLoader.get_map_path_for_key(_selected_map_key)
	#MainRootNode.Instance.start_combat(path)
	var is_story_map = _selected_map_key == _next_unlock_map_key
	LoadManager.load_combat(_selected_map_key, is_story_map)
