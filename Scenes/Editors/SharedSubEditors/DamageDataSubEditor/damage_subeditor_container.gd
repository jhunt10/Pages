@tool
class_name DamageSubEditorContainer
extends BaseListSubEditorConatiner

func get_option_keys()->Array:
	var out_list = ["Weapon"]
	out_list.append_array(get_key_to_input_mapping().keys())
	return out_list
	
