@tool
class_name DamageEditEntryContainer
extends BaseSubEditorContainer

@onready var damage_key_line_edit:LineEdit =  $InnerContainer/DamageDataKeyContainer/DamageDataKeyLineEdit
@onready var base_power_spin_box:SpinBox = $InnerContainer/PowerStatContainer/PowerSpinBox
@onready var stat_option_button:LoadedOptionButton = $InnerContainer/PowerStatContainer/StatOptionButton
@onready var type_option_button:LoadedOptionButton = $InnerContainer/TypeSDefenseContainer/TypeOptionButton
@onready var defense_option_button:LoadedOptionButton = $InnerContainer/TypeSDefenseContainer/DefenseOptionButton
@onready var vfx_option_button:LoadedOptionButton = $InnerContainer/VFXContainer/VFXOptionButton

func _ready() -> void:
	stat_option_button.get_options_func = get_attack_stats
	type_option_button.get_options_func = get_damage_types
	defense_option_button.get_options_func = get_defense_types
	vfx_option_button.get_options_func = get_damage_effect_options
	pass
	

func get_key_to_input_mapping()->Dictionary:
	return {
		"BaseDamage": $InnerContainer/PowerStatContainer/PowerSpinBox,
		"AtkStat": $InnerContainer/PowerStatContainer/StatOptionButton,
		"DamageType": $InnerContainer/TypeSDefenseContainer/TypeOptionButton,
		"DefenseType": $InnerContainer/TypeSDefenseContainer/DefenseOptionButton,
		"DamageEffect": $InnerContainer/VFXContainer/VFXOptionButton
	}

func load_data(object_key:String, data:Dictionary):
	$InnerContainer/DamageDataKeyContainer/DamageDataKeyLineEdit.text = object_key
	super(object_key, data)

func lose_focus_if_has():
	if damage_key_line_edit.has_focus():
		damage_key_line_edit.release_focus()
	if base_power_spin_box.has_focus():
		base_power_spin_box.apply()
		base_power_spin_box.release_focus()
	var base_line = base_power_spin_box.get_line_edit()
	if base_line.has_focus():
		base_line.release_focus()
		base_power_spin_box.apply()


func get_damage_effect_options():
	return MainRootNode.vfx_libray._vfx_datas.keys()

func get_damage_types()->Array:
	return DamageEvent.DamageTypes.keys()
	
func get_attack_stats()->Array:
	return StatHelper.CoreStats.keys()
	
func get_defense_types()->Array:
	return DamageEvent.DefenseType.keys()
