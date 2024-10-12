class_name DamageModEditControl
extends Control

@onready var drop_options:OptionButton = $VBoxContainer/HBoxContainer/OptionButton
@onready var add_button:Button = $VBoxContainer/HBoxContainer/AddButton
@onready var data_panel:NinePatchRect = $VBoxContainer/DataPanelBackground

@onready var key_input:LineEdit = $VBoxContainer/DataPanelBackground/VBoxContainer/KeyInputContainer/KeyLineEdit
@onready var display_name_line_edit:LineEdit = $VBoxContainer/DataPanelBackground/VBoxContainer/DisplayNameContainer/DisplayNameLineEdit
@onready var take_damage_check_box:CheckBox = $VBoxContainer/DataPanelBackground/VBoxContainer/GiveTakeContainer/TakeCheckBox
@onready var deal_damage_check_box:CheckBox = $VBoxContainer/DataPanelBackground/VBoxContainer/GiveTakeContainer/GiveCheckBox
@onready var mod_type_option_button:LoadedOptionButton = $VBoxContainer/DataPanelBackground/VBoxContainer/HBoxContainer/LoadedOptionButton
@onready var mod_value_int_spin_box:SpinBox = $VBoxContainer/DataPanelBackground/VBoxContainer/HBoxContainer/IntSpinBox
@onready var mod_value_float_spin_box:SpinBox = $VBoxContainer/DataPanelBackground/VBoxContainer/HBoxContainer/FloatSpinBox

var damage_mod_datas:Dictionary = {}
var editing_key:String = ''

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	data_panel.visible = false
	key_input.focus_exited.connect(_save_current_values)
	display_name_line_edit.focus_exited.connect(_save_current_values)
	take_damage_check_box.pressed.connect(_save_current_values)
	deal_damage_check_box.pressed.connect(_save_current_values)
	mod_type_option_button.item_selected.connect(_save_current_values)
	mod_value_int_spin_box.get_line_edit().focus_exited.connect(_save_current_values)
	mod_value_float_spin_box.get_line_edit().focus_exited.connect(_save_current_values)
	
	add_button.pressed.connect(_add_new_data)
	drop_options.item_selected.connect(on_item_selected)
	mod_type_option_button.get_options_func = get_damage_mod_types
	mod_type_option_button.item_selected.connect(on_type_selected)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func lose_focus_if_has():
	if key_input.has_focus():
		key_input.release_focus()
	if display_name_line_edit.has_focus():
		display_name_line_edit.release_focus()
	if mod_value_int_spin_box.has_focus():
		mod_value_int_spin_box.release_focus()
	if mod_value_int_spin_box.get_line_edit().has_focus():
		mod_value_int_spin_box.get_line_edit().release_focus()
	if mod_value_float_spin_box.has_focus():
		mod_value_float_spin_box.release_focus()
	if mod_value_float_spin_box.get_line_edit().has_focus():
		mod_value_float_spin_box.get_line_edit().release_focus()
	
func _add_new_data():
	if data_panel.visible:
		_save_current_values()
	else:
		data_panel.visible = true
	editing_key = ''
	key_input.clear()
	display_name_line_edit.clear()
	take_damage_check_box.button_pressed = false
	deal_damage_check_box.button_pressed = false
	mod_type_option_button.load_options('')
	mod_value_int_spin_box.set_value_no_signal(0)
	mod_value_float_spin_box.visible = false
	mod_value_float_spin_box.set_value_no_signal(0)

func get_damage_mod_types():
	return BaseStatMod.ModTypes.keys()
	
func on_type_selected(index:int):
	var type = mod_type_option_button.get_item_text(index)
	if type == 'Scale':
		if mod_value_int_spin_box.visible:
			mod_value_float_spin_box.set_value_no_signal(mod_value_int_spin_box.value)
		mod_value_int_spin_box.visible = false
		mod_value_float_spin_box.visible = true
	else:
		if mod_value_float_spin_box.visible:
			mod_value_int_spin_box.set_value_no_signal(mod_value_float_spin_box.value)
		mod_value_int_spin_box.visible = true
		mod_value_float_spin_box.visible = false


func _save_current_values(val=null):
	var damage_mod_key = key_input.text
	if damage_mod_key == '':
		return
	mod_value_int_spin_box.apply()
	mod_value_float_spin_box.apply()
		
	if editing_key != damage_mod_key and damage_mod_datas.has(editing_key):
		damage_mod_datas.erase(editing_key)
	
	if !damage_mod_datas.has(damage_mod_key):
		damage_mod_datas[damage_mod_key] = {}
	damage_mod_datas[damage_mod_key]['DamageModKey'] = key_input.text
	damage_mod_datas[damage_mod_key]['DisplayName'] = display_name_line_edit.text
	damage_mod_datas[damage_mod_key]['OnTakeDamage'] = take_damage_check_box.button_pressed
	damage_mod_datas[damage_mod_key]['OnDealDamage'] = deal_damage_check_box.button_pressed
	damage_mod_datas[damage_mod_key]['ModType'] = mod_type_option_button.get_current_option_text()
	if mod_type_option_button.get_current_option_text() == "Scale":
		damage_mod_datas[damage_mod_key]['Value'] = float(mod_value_float_spin_box.value) / 100.0
	else:
		damage_mod_datas[damage_mod_key]['Value'] = mod_value_int_spin_box.value
	
	drop_options.clear()
	drop_options.add_item("None", 0)
	drop_options.set_item_disabled(0, true)
	for data_key in damage_mod_datas.keys():
		drop_options.add_item(data_key)
	for n in range(drop_options.item_count):
		if drop_options.get_item_text(n) == damage_mod_key:
			drop_options.select(n)
			break
	editing_key = damage_mod_key
	
func on_item_selected(index:int):
	if index >= 0:
		var val = drop_options.get_item_text(index)
		load_values(val)

func load_values(damage_mod_key:String):
	if not damage_mod_datas.has(damage_mod_key):
		return
	editing_key = damage_mod_key
	key_input.text = damage_mod_key
	display_name_line_edit.text = damage_mod_datas[damage_mod_key].get("DisplayName", '')
	take_damage_check_box.button_pressed  = damage_mod_datas[damage_mod_key].get("OnTakeDamage", false)
	deal_damage_check_box.button_pressed  = damage_mod_datas[damage_mod_key].get("OnDealDamage", false)
	mod_type_option_button.load_options(damage_mod_datas[damage_mod_key].get("ModType", ''))
	if mod_type_option_button.get_current_option_text() == "Scale":
		mod_value_int_spin_box.visible = false
		mod_value_float_spin_box.visible = true
		mod_value_float_spin_box.set_value_no_signal(damage_mod_datas[damage_mod_key].get("Value", 0) * 100)
	else:
		mod_value_float_spin_box.visible = false
		mod_value_int_spin_box.visible = true
		mod_value_int_spin_box.set_value_no_signal(damage_mod_datas[damage_mod_key].get("Value", 0))

func load_effect_data(data:Dictionary):
	damage_mod_datas = data.get('DamageMods', {})
	drop_options.clear()
	for data_key in damage_mod_datas.keys():
		drop_options.add_item(data_key)
	if damage_mod_datas.size() > 0:
		on_item_selected(0)
		data_panel.visible = true
	else:
		data_panel.visible = false
		editing_key = ''
		key_input.clear()
		display_name_line_edit.clear()
		take_damage_check_box.button_pressed = false
		deal_damage_check_box.button_pressed = false
		mod_type_option_button.load_options('')
		mod_value_float_spin_box.visible = false
		mod_value_float_spin_box.set_value_no_signal(0)

func save_effect_data()->Dictionary:
	_save_current_values()
	return damage_mod_datas
