class_name DamageEditControl
extends Control

@onready var drop_options:OptionButton = $VBoxContainer/HBoxContainer/OptionButton
@onready var add_button:Button = $VBoxContainer/HBoxContainer/AddButton
@onready var data_panel:NinePatchRect = $VBoxContainer/Background2

@onready var key_input:LineEdit = $VBoxContainer/Background2/VBoxContainer/DamageKeyInputContainer/DamageKeyInput
@onready var damage_type_options:LoadedOptionButton = $VBoxContainer/Background2/VBoxContainer/DamageKeyInputContainer2/DamageTypeOptionButton
@onready var defense_type_options:LoadedOptionButton = $VBoxContainer/Background2/VBoxContainer/DamageKeyInputContainer2/DefTypeOptionButton
@onready var base_power_input:SpinBox = $VBoxContainer/Background2/VBoxContainer/HBoxContainer/BaseDamageSpinBox
@onready var attack_stat_options:LoadedOptionButton = $VBoxContainer/Background2/VBoxContainer/HBoxContainer/AtackStatOptionButton
@onready var damage_effect_options:LoadedOptionButton = $VBoxContainer/Background2/VBoxContainer/HBoxContainer2/LoadedOptionButton

var damage_datas:Dictionary = {}
var editing_key:String = ''

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	data_panel.visible = false
	key_input.focus_exited.connect(_save_current_values)
	base_power_input.focus_exited.connect(_save_current_values)
	
	damage_type_options.get_options_func = get_damage_types
	attack_stat_options.get_options_func = get_attack_stats
	defense_type_options.get_options_func = get_defense_types
	
	add_button.pressed.connect(_add_new_data)
	drop_options.item_selected.connect(on_item_selected)
	damage_effect_options.get_options_func = get_damage_effect_options
	pass # Replace with function body.

func get_damage_types()->Array:
	return DamageEvent.DamageTypes.keys()
	
func get_attack_stats()->Array:
	return StatHelper.CoreStats.keys()
	
func get_defense_types()->Array:
	return DamageEvent.DefenseType.keys()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _add_new_data():
	if data_panel.visible:
		_save_current_values()
	else:
		data_panel.visible = true
	editing_key = ''
	base_power_input.set_value_no_signal(0)
	key_input.clear()
	damage_type_options.load_options()
	attack_stat_options.load_options()
	defense_type_options.load_options()
	damage_effect_options.load_options()

func get_damage_effect_options():
	return MainRootNode.vfx_libray._vfx_datas.keys()

func _save_current_values(base_damage_value:float = -1):
	printerr("Saving Damage Data")
	var damage_key = key_input.text
	if damage_key == '':
		return
		
	if editing_key != damage_key and damage_datas.has(editing_key):
		damage_datas.erase(editing_key)
	
	if !damage_datas.has(damage_key):
		damage_datas[damage_key] = {}
	damage_datas[damage_key]['DamageDataKey'] = key_input.text
	if base_damage_value < 0:
		damage_datas[damage_key]['BaseDamage'] = base_power_input.value
	else:
		damage_datas[damage_key]['BaseDamage'] = int(base_damage_value)
	damage_datas[damage_key]['DamageType'] = damage_type_options.get_current_option_text()
	damage_datas[damage_key]['AtkStat'] = attack_stat_options.get_current_option_text()
	damage_datas[damage_key]['DefenseType'] = defense_type_options.get_current_option_text()
	if damage_effect_options.get_current_option_text() != '':
		damage_datas[damage_key]['DamageEffect'] = damage_effect_options.get_current_option_text()
	
	drop_options.clear()
	drop_options.add_item("None", 0)
	drop_options.set_item_disabled(0, true)
	for data_key in damage_datas.keys():
		drop_options.add_item(data_key)
	for n in range(drop_options.item_count):
		if drop_options.get_item_text(n) == damage_key:
			drop_options.select(n)
			break
	editing_key = damage_key
	
func on_item_selected(index:int):
	if index >= 0:
		var val = drop_options.get_item_text(index)
		load_values(val)

func load_values(damage_key:String):
	if not damage_datas.has(damage_key):
		return
	editing_key = damage_key
	key_input.text = damage_key
	damage_type_options.load_options(damage_datas[damage_key].get("DamageType", ""))
	attack_stat_options.load_options(damage_datas[damage_key].get("AtkStat", ""))
	defense_type_options.load_options(damage_datas[damage_key].get("DefenseType", ""))
	base_power_input.set_value_no_signal(damage_datas[damage_key]['BaseDamage'])
	if damage_datas[damage_key].has("DamageEffect"):
		damage_effect_options.load_options(damage_datas[damage_key]['DamageEffect'])

func load_page_data(data:Dictionary):
	damage_datas = data.get('DamageDatas', {})
	drop_options.clear()
	for data_key in damage_datas.keys():
		drop_options.add_item(data_key)
	if damage_datas.size() > 0:
		on_item_selected(0)
		data_panel.visible = true
	else:
		data_panel.visible = false
		editing_key = ''
		base_power_input.set_value_no_signal(0)
		key_input.clear()
		damage_type_options.load_options()
		attack_stat_options.load_options()
		defense_type_options.load_options()

func save_page_data()->Dictionary:
	_save_current_values()
	return damage_datas
