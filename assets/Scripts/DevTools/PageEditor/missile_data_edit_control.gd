class_name MissileEditControl
extends Control

@onready var drop_options:OptionButton = $VBoxContainer/HBoxContainer/OptionButton
@onready var add_button:Button = $VBoxContainer/HBoxContainer/AddButton
@onready var data_panel:NinePatchRect = $VBoxContainer/Background2

@onready var key_input:LineEdit = $VBoxContainer/Background2/VBoxContainer/KeyInputContainer/KeyInput
@onready var sprite_options:LoadedOptionButton = $VBoxContainer/Background2/VBoxContainer/HBoxContainer/LoadedOptionButton
@onready var damage_data_options:LoadedOptionButton = $VBoxContainer/Background2/VBoxContainer/HBoxContainer2/LoadedOptionButton
@onready var speed_input:SpinBox = $VBoxContainer/Background2/VBoxContainer/HBoxContainer3/SpinBox

var missile_datas:Dictionary = {}
var editing_key:String = ''

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	data_panel.visible = false
	key_input.focus_exited.connect(_save_current_values)
	sprite_options.get_options_func = get_sprite_options
	damage_data_options.get_options_func = get_damage_options
	
	add_button.pressed.connect(_add_new_data)
	drop_options.item_selected.connect(on_item_selected)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _add_new_data():
	if data_panel.visible:
		_save_current_values()
	else:
		data_panel.visible = true
	editing_key = ''
	speed_input.set_value_no_signal(0)
	key_input.clear()
	damage_data_options.load_options()
	sprite_options.load_options()

func get_sprite_options():
	var list = []
	var path
	var dir = DirAccess.open(PageEditControl.Instance.selected_file.get_base_dir())
	if dir:
		dir.list_dir_begin()
		var file_name:String = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".png"):
				list.append(file_name)
			file_name = dir.get_next()
	#else:
		#print("An error occurred when trying to access the path: " + path)
	return list

func get_damage_options():
	return PageEditControl.Instance.get_damage_datas().keys()

func _save_current_values():
	var missile_key = key_input.text
	if missile_key == '':
		return
		
	if editing_key != missile_key and missile_datas.has(editing_key):
		missile_datas.erase(editing_key)
	
	if !missile_datas.has(missile_key):
		missile_datas[missile_key] = {}
	missile_datas[missile_key]['MissileDataKey'] = key_input.text
	speed_input.apply()
	missile_datas[missile_key]['FramesPerTile'] = speed_input.value
	missile_datas[missile_key]['MissileSprite'] = sprite_options.get_current_option_text()
	missile_datas[missile_key]['DamageDataKey'] = damage_data_options.get_current_option_text()
	
	drop_options.clear()
	drop_options.add_item("None", 0)
	drop_options.set_item_disabled(0, true)
	for data_key in missile_datas.keys():
		drop_options.add_item(data_key)
	for n in range(drop_options.item_count):
		if drop_options.get_item_text(n) == missile_key:
			drop_options.select(n)
			break
	editing_key = missile_key
	
func on_item_selected(index:int):
	if index >= 0:
		var val = drop_options.get_item_text(index)
		load_values(val)

func load_values(missile_key:String):
	if not missile_datas.has(missile_key):
		return
	editing_key = missile_key
	key_input.text = missile_key
	speed_input.set_value_no_signal(missile_datas[missile_key]['FramesPerTile'])
	sprite_options.load_options(missile_datas[missile_key]['MissileSprite'])
	damage_data_options.load_options(missile_datas[missile_key]['DamageDataKey'])

func load_page_data(data:Dictionary):
	missile_datas = data.get('MissileDatas', {})
	drop_options.clear()
	for data_key in missile_datas.keys():
		drop_options.add_item(data_key)
	if missile_datas.size() > 0:
		on_item_selected(0)
		data_panel.visible = true
	else:
		data_panel.visible = false
		editing_key = ''
		key_input.clear()
		speed_input.set_value_no_signal(0)
		sprite_options.load_options()
		damage_data_options.load_options()

func save_page_data()->Dictionary:
	_save_current_values()
	return missile_datas
