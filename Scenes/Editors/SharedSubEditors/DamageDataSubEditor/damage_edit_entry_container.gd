@tool
class_name DamageEditEntryContainer
extends BaseSubEditEntryContainer

@onready var stat_option_button:LoadedOptionButton = $InnerContainer/StatContainer/StatOptionButton
@onready var type_option_button:LoadedOptionButton = $InnerContainer/TypeSDefenseContainer/TypeOptionButton
@onready var defense_option_button:LoadedOptionButton = $InnerContainer/TypeSDefenseContainer/DefenseOptionButton
@onready var vfx_option_button:LoadedOptionButton = $InnerContainer/VFXContainer/VFXOptionButton

@onready var base_damage_spinbox:SpinBox = $InnerContainer/PowerStatContainer/PowerSpinBox
@onready var var_damage_spinbox:SpinBox = $InnerContainer/PowerStatContainer/VarientSpinBox
@onready var min_max_label:Label = $InnerContainer/PowerStatContainer/MinMaxLabel

func _get_key_input()->LineEdit:
	return $InnerContainer/KeyContainer/KeyLineEdit
func _get_delete_button()->Button:
	return $InnerContainer/KeyContainer/DeleteButton

func _ready() -> void:
	super()
	if Engine.is_editor_hint(): return
	var nam = self.name
	printerr(self.name)
	stat_option_button.get_options_func = get_attack_stats
	type_option_button.get_options_func = get_damage_types
	defense_option_button.get_options_func = get_defense_types
	vfx_option_button.get_options_func = get_damage_effect_options
	base_damage_spinbox.value_changed.connect(on_base_or_var_damage_change)
	var_damage_spinbox.value_changed.connect(on_base_or_var_damage_change)
	set_min_max()
	pass
	

func get_key_to_input_mapping()->Dictionary:
	return {
		"AtkPower": $InnerContainer/PowerStatContainer/PowerSpinBox,
		"AtkStat": $InnerContainer/StatContainer/StatOptionButton,
		"DamageType": $InnerContainer/TypeSDefenseContainer/TypeOptionButton,
		"DefenseType": $InnerContainer/TypeSDefenseContainer/DefenseOptionButton,
		"DamageEffect": $InnerContainer/VFXContainer/VFXOptionButton,
		"DamageVarient": $InnerContainer/PowerStatContainer/VarientSpinBox
	}

func load_data(object_key:String, data:Dictionary):
	super(object_key, data)
	set_min_max()

func on_base_or_var_damage_change(val):
	set_min_max()

func set_min_max():
	var base = base_damage_spinbox.value
	var vare = var_damage_spinbox.value
	var min = base - (base * vare)
	var max = base + (base * vare)
	min_max_label.text = "( %s - %s )" % [min, max]

func get_damage_effect_options():
	return MainRootNode.vfx_libray._vfx_datas.keys()

func get_damage_types()->Array:
	return DamageEvent.DamageTypes.keys()
	
func get_attack_stats()->Array:
	return StatHelper.CoreStats.keys()
	
func get_defense_types()->Array:
	return DamageEvent.DefenseType.keys()
