@tool
class_name DamageModEditEntryContainer
extends BaseSubEditEntryContainer

func _get_key_input()->LineEdit:
	return $InnerContainer/KeyContainer/KeyLineEdit
func _get_delete_button()->Button:
	return $InnerContainer/KeyContainer/DeleteButton

func _ready() -> void:
	super()
	if Engine.is_editor_hint(): return
	$InnerContainer/TypeValContainer/ModTypeOptionButton.get_options_func = get_mod_types
	pass
	

func get_key_to_input_mapping()->Dictionary:
	return {
		"DisplayName": $InnerContainer/DisplayNameContainer/DisplayNameLineEdit,
		"ModType": $InnerContainer/TypeValContainer/ModTypeOptionButton,
		"OnTakeDamage": $InnerContainer/TakeDealContainer/OnTakeCheckBox,
		"OnDealDamage": $InnerContainer/TakeDealContainer/OnDealCheckBox,
		"Value": $InnerContainer/TypeValContainer/ModValSpinBox
	}

func get_mod_types():
	return BaseDamageMod.ModTypes.keys()
