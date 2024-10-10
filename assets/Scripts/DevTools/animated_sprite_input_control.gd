class_name AnimatedSpriteInputControl
extends Control

@onready var sprite_display_rect:TextureRect = $HBoxContainer/SpriteDisplay/SpriteRect
@onready var sprite_options_button:LoadedOptionButton = $HBoxContainer/VBoxContainer/SpritInputContainer/SpriteLoadedOptionButton
@onready var animation_option_button:LoadedOptionButton = $HBoxContainer/VBoxContainer/AnimationInputContainer/AnimationLoadedOptionButton
@onready var animation_line_edit:LineEdit = $HBoxContainer/VBoxContainer/AnimationInputContainer/AnimationLineEdit
@onready var sprite_width_input:SpinBox = $HBoxContainer/VBoxContainer/HBoxContainer/SpriteWHSContainer/WidthSpinBox
@onready var sprite_hight_input:SpinBox = $HBoxContainer/VBoxContainer/HBoxContainer/SpriteWHSContainer/HightSpinBox
@onready var sprite_speed_input:SpinBox = $HBoxContainer/VBoxContainer/HBoxContainer/SpriteWHSContainer/SpeedSpinBox

var _load_path:String = ''
var _data:AnimatedSpriteData

var _get_animations_func:Callable
var _animations_list:Array = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sprite_options_button.no_option_text = "No Sprite Path"
	sprite_options_button.get_options_func = get_sprite_options
	sprite_options_button.item_selected.connect(on_sprite_selected)
	if _data:
		_sync_load()
		
	pass # Replace with function body.
	
func _sync_load():
	if not _data or not sprite_options_button:
		printerr("Options not set or not ready")
		return
	if _get_animations_func or _animations_list.size() > 0:
		animation_line_edit.visible = false
		animation_option_button.visible = true
		animation_option_button.get_options_func = get_animations_options
		animation_option_button.load_options(_data.get_animation_name())
	else:
		animation_line_edit.visible = true
		animation_option_button.visible = false
		animation_line_edit.text = _data.get_animation_name()
	
	sprite_width_input.set_value_no_signal(_data.get_sprite_sheet_width())
	sprite_hight_input.set_value_no_signal(_data.get_sprite_sheet_hight())
	sprite_speed_input.set_value_no_signal(_data.get_animation_speed())
	sprite_display_rect.visible = true
	sprite_display_rect.texture = _data.get_sprite()
	sprite_options_button.load_options(_data.get_sprite_name())
		
func clear():
	_data = null
	sprite_width_input.set_value_no_signal(1)
	sprite_hight_input.set_value_no_signal(1)
	sprite_speed_input.set_value_no_signal(1)
	animation_option_button.clear()
	animation_line_edit.text = ''
	sprite_options_button.clear()
	sprite_display_rect.visible = false
	printerr("Clear Options: ")
	

func load_options(load_path:String, data:Dictionary, animation_options):
	printerr("Load Options: ")
	_load_path = load_path
	_data = AnimatedSpriteData.new(data, load_path)
	if animation_options is Callable:
		_get_animations_func = animation_options
	if animation_options is Array:
		_animations_list = animation_options
	if sprite_options_button:
		_sync_load()

func save_data()->Dictionary:
	var dict = {}
	dict["SpriteName"] = sprite_options_button.get_current_option_text()
	if animation_option_button.visible:
		dict["AnimationName"] = animation_option_button.get_current_option_text()
	else:
		dict["AnimationName"] = animation_line_edit.text
	dict["AnimationSpeed"] = sprite_speed_input.value
	dict["TileSheetWidth"] = sprite_width_input.value
	dict["TileSheetHight"] = sprite_hight_input.value
	return dict

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func on_sprite_selected(index):
	var sprite_name = sprite_options_button.get_item_text(index)
	sprite_display_rect.texture = load(_load_path.path_join(sprite_name))
	sprite_display_rect.visible = true

func lose_focus_if_has():
	drop_spinbox_focus(sprite_width_input)
	drop_spinbox_focus(sprite_hight_input)
	drop_spinbox_focus(sprite_speed_input)
		
func drop_spinbox_focus(box:SpinBox):
	if box.has_focus():
		box.release_focus()
	var line_edit = box.get_line_edit()
	if line_edit.has_focus():
		box.apply()
		line_edit.release_focus()

func get_animations_options():
	if _get_animations_func:
		return _get_animations_func.call()
	return _animations_list

func get_sprite_options():
	var list = []
	var dir = DirAccess.open(_load_path)
	if dir:
		dir.list_dir_begin()
		var file_name:String = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".png"):
				list.append(file_name)
			file_name = dir.get_next()
	return list
