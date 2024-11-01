@tool
class_name SubActionEditEntryContainer
extends BaseSubEditorContainer

signal on_frame_changed

@onready var script_box:LineEdit = $InnerContainer/TitleContainer/ScriptLineEdit
@onready var frame_spin_box:SpinBox = $InnerContainer/TitleContainer/FrameSpinBox
@onready var delete_button:Button = $InnerContainer/TitleContainer/DeleteButton
@onready var premade_prop_input:SubActionPropInputContainer = $InnerContainer/SubActionPropertyEditorEntry
@onready var props_container:VBoxContainer = $InnerContainer/PropsContainer

var _parent_subaction_subeditor:SubActionSubEditorControl
var _prop_inputs:Dictionary = {}
var _enum_prop_options:Dictionary = {}
var _full_script_path:String

func _ready() -> void:
	super()
	if Engine.is_editor_hint(): return
	premade_prop_input.visible = false
	delete_button.pressed.connect(self.queue_free)
	frame_spin_box.value_changed.connect(on_frame_spin_box_change)

func get_key_to_input_mapping():
	return _prop_inputs

func load_data(object_key:String, data:Dictionary):
	_object_key = object_key
	_loaded_data = data.duplicate(true)
	_full_script_path = data.get("SubActionScript")
	if !_full_script_path:
		script_box.text = "No SubActionScript"
		return
	var script:BaseSubAction = ActionLibrary.get_sub_action_script(_full_script_path)
	if !script:
		script_box.text = "Script Not Found"
		return
	script_box.text = _full_script_path.get_file()
	var required_props = script.get_required_props()
	for key in required_props.keys():
		var prop_type = required_props[key]
		if prop_type == BaseSubAction.SubActionPropTypes.EnumVal:
			_enum_prop_options[key] = script.get_prop_enum_values(key)
			
		var new_prop_input:SubActionPropInputContainer = premade_prop_input.duplicate()
		props_container.add_child(new_prop_input)
		new_prop_input.visible = true
		new_prop_input.set_props(self, key, prop_type, data.get(key))
		_prop_inputs[key] = new_prop_input

func build_save_data()->Dictionary:
	var dict = super()
	dict['SubActionScript'] = _full_script_path
	return dict

func on_frame_spin_box_change(val):
	on_frame_changed.emit()
