@tool
class_name DamageEditEntryContainer
extends BaseSubEditEntryContainer

@onready var stat_option_button:LoadedOptionButton = $InnerContainer/PowerStatContainer/StatOptionButton
@onready var type_option_button:LoadedOptionButton = $InnerContainer/TypeSDefenseContainer/TypeOptionButton
@onready var defense_option_button:LoadedOptionButton = $InnerContainer/TypeSDefenseContainer/DefenseOptionButton
@onready var vfx_option_button:LoadedOptionButton = $InnerContainer/VFXContainer/VFXOptionButton

func _get_key_input()->LineEdit:
	return $InnerContainer/KeyContainer/KeyLineEdit
func _get_delete_button()->Button:
	return $InnerContainer/KeyContainer/DeleteButton

func _ready() -> void:
	super()
	if Engine.is_editor_hint(): return
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

func get_damage_effect_options():
	return MainRootNode.vfx_libray._vfx_datas.keys()

func get_damage_types()->Array:
	return DamageEvent.DamageTypes.keys()
	
func get_attack_stats()->Array:
	return StatHelper.CoreStats.keys()
	
func get_defense_types()->Array:
	return DamageEvent.DefenseType.keys()
