@tool
class_name SubEffectEditEntryContainer
extends BaseSubEditEntryContainer

@onready var script_box:LineEdit = $InnerContainer/ScriptContainer/ScriptLineEdit
@onready var premade_prop_input:SubEffectPropInputContainer = $InnerContainer/SubEffectPropertyEditorEntry
@onready var props_container:VBoxContainer = $InnerContainer/PropsContainer

func _get_key_input()->LineEdit:
	return $InnerContainer/KeyContainer/KeyLineEdit
func _get_delete_button()->Button:
	return $InnerContainer/KeyContainer/DeleteButton

var _prop_inputs:Dictionary = {}
var _enum_prop_options:Dictionary = {}
var _full_script_path:String

func _ready() -> void:
	super()
	if Engine.is_editor_hint(): return
	premade_prop_input.visible = false

func get_key_to_input_mapping():
	return _prop_inputs

func load_data(object_key:String, data:Dictionary):
	_get_key_input().text = object_key
	_object_key = object_key
	_loaded_data = data.duplicate(true)
	_full_script_path = data.get("SubEffectScript")
	if !_full_script_path:
		script_box.text = "No SubEffectScript"
		return
	var script:BaseSubEffect = EffectLibrary.get_sub_effect_script(_full_script_path)
	if !script:
		script_box.text = "Script Not Found"
		return
	script_box.text = _full_script_path.get_file()
	var required_props = script.get_required_props()
	for key in required_props.keys():
		var prop_type = required_props[key]
		if prop_type == BaseSubEffect.SubEffectPropTypes.EnumVal:
			_enum_prop_options[key] = script.get_prop_enum_values(key)
			
		var new_prop_input:SubEffectPropInputContainer = premade_prop_input.duplicate()
		props_container.add_child(new_prop_input)
		new_prop_input.visible = true
		if prop_type == BaseSubEffect.SubEffectPropTypes.EnumVal:
			new_prop_input._prop_enum_options = script.get_prop_enum_values(key)
		new_prop_input.set_props(self, key, prop_type, data.get(key))
		_prop_inputs[key] = new_prop_input

func build_save_data()->Dictionary:
	var dict = super()
	dict['SubEffectScript'] = _full_script_path
	return dict
