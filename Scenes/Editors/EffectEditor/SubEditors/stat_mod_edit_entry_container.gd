@tool
class_name StatModEditEntryContainer
extends BaseSubEditEntryContainer

func _get_key_input()->LineEdit:
	return $InnerContainer/KeyContainer/KeyLineEdit
func _get_delete_button()->Button:
	return $InnerContainer/KeyContainer/DeleteButton

func _ready() -> void:
	super()
	if Engine.is_editor_hint(): return
	$InnerContainer/TypeValContainer/ModTypeOptionButton.get_options_func = get_mod_types
	$InnerContainer/StatContainer/StatOptionButton.get_options_func = get_stat_names
	pass
	

func get_key_to_input_mapping()->Dictionary:
	return {
		"DisplayName": $InnerContainer/DisplayNameContainer/DisplayNameLineEdit,
		"StatName": $InnerContainer/StatContainer/StatOptionButton,
		"ModType": $InnerContainer/TypeValContainer/ModTypeOptionButton,
		"Value": $InnerContainer/TypeValContainer/ModValSpinBox
	}

func get_mod_types()->Array:
	return BaseStatMod.ModTypes.keys()

func get_stat_names()->Array:
	var list = StatHelper.CoreStats.keys()
	list.append_array(StatHelper.BasicStats)
	return list
