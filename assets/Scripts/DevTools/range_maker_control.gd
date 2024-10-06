class_name RangeMakerControl
extends Control

@onready var drop_options:OptionButton = $VBoxContainer/HBoxContainer2/OptionButton
@onready var add_button:Button = $VBoxContainer/HBoxContainer2/AddButton

@onready var range_viewer:TargetRangeViewEditControl = $VBoxContainer/TargetRangeViewEditControl

@onready var key_input:LineEdit = $VBoxContainer/TargetKeyContainer/LineEdit
@onready var target_type_input:OptionButton = $VBoxContainer/TargetTypeContainer/TargetTypeInput

var target_datas:Dictionary = {}
var editing_key:String = ''

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#data_panel.visible = false
	key_input.focus_exited.connect(_save_current_values)
	target_type_input.focus_exited.connect(_save_current_values)
	drop_options.focus_entered.connect(_save_current_values)
	add_button.pressed.connect(_add_new_data)
	drop_options.item_selected.connect(on_item_selected)
	for targ_type in TargetParameters.TargetTypes:
		target_type_input.add_item(str(targ_type))
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _add_new_data():
	_save_current_values()
	editing_key = ''
	key_input.clear()
	target_type_input.select(0)
	range_viewer.set_selected_spots([])

func _save_current_values(base_damage_value:float = -1):
	var target_key = key_input.text
	if target_key == '':
		return
		
	if editing_key != target_key and target_datas.has(editing_key):
		target_datas.erase(editing_key)
	
	if !target_datas.has(target_key):
		target_datas[target_key] = {}
	target_datas[target_key]['TargetType'] = target_type_input.get_item_text(target_type_input.selected)
	target_datas[target_key]['TargetArea'] = range_viewer.get_selected_spots()
	
	drop_options.clear()
	drop_options.add_item("None", 0)
	drop_options.set_item_disabled(0, true)
	for data_key in target_datas.keys():
		drop_options.add_item(data_key)
	for n in range(drop_options.item_count):
		if drop_options.get_item_text(n) == target_key:
			drop_options.select(n)
			break
	editing_key = target_key
	
func on_item_selected(index:int):
	if index >= 0:
		var val = drop_options.get_item_text(index)
		load_values(val)

func load_values(target_key:String):
	if not target_datas.has(target_key):
		return
	editing_key = target_key
	key_input.text = target_key
	for index in range(target_type_input.item_count):
		if target_type_input.get_item_text(index) == target_datas[target_key]['TargetType']:
			target_type_input.select(index)
			break
	range_viewer.set_selected_spots(target_datas[target_key]['TargetArea'])
	

func load_page_data(data:Dictionary):
	target_datas = data.get("TargetParams", {})
	drop_options.clear()
	for key in target_datas.keys():
		drop_options.add_item(key)
	if target_datas.size() > 0:
		on_item_selected(0)
	else:
		range_viewer.clear()
		target_type_input.select(-1)
		key_input.clear()

func save_page_data()->Dictionary:
	return target_datas
