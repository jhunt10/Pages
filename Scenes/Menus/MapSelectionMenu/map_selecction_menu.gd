class_name MapSelectionMenu
extends Control

@export var premade_option_button:CampOptionButton
@export var option_button_container:VBoxContainer
@export var description_box:RichTextLabel
@export var map_preview_image:TextureRect
@export var back_button:CampOptionButton
@export var explore_button:CampOptionButton

var _selected_map_key
var _map_buttons:Dictionary = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	premade_option_button.hide()
	if MainRootNode.Instance:
		explore_button.button.pressed.connect(_on_explore)
		back_button.button.pressed.connect(MainRootNode.Instance.open_camp_menu)
	_build_options()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _build_options():
	var maps = MapLoader.get_map_datas()
	for map_key in maps.keys():
		var new_button:CampOptionButton = premade_option_button.duplicate()
		new_button.text = maps[map_key]['MapName']
		option_button_container.add_child(new_button)
		new_button.button.pressed.connect(_on_button_pressed.bind(map_key))
		new_button.show()
		_map_buttons[map_key] = new_button
	if maps.size() > 0:
		_selected_map_key = maps.keys()[0]
		display_map_details(_selected_map_key)

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
	MainRootNode.Instance.start_combat(_selected_map_key)
