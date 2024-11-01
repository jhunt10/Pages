@tool
class_name PreviewSubEditorContainer
extends BaseSubEditorContainer

@export var preview_target_option_button:LoadedOptionButton
@export var preview_move_input_container:MoveInputContainer
@export var preview_move_check_box:CheckBox


func get_key_to_input_mapping()->Dictionary:
	return {
		"PreviewTargetKey": preview_target_option_button,
		"PreviewMoveOffset": preview_move_input_container
	}


func _ready() -> void:
	super()
	if Engine.is_editor_hint():
		return
	preview_move_check_box.button_up.connect(toggle_move_preview)
	preview_target_option_button.get_options_func = get_target_param_options

func load_data(object_key:String, data:Dictionary):
	super(object_key, data)
	if data.keys().has("PreviewMoveOffset"):
		preview_move_check_box.button_pressed = true
		preview_move_input_container.set_disabled(false)
	else:
		preview_move_check_box.button_pressed = false
		preview_move_input_container.set_disabled(true)

func build_save_data():
	var out_dict = {}
	var target_key = preview_target_option_button.get_current_option_text()
	if target_key != preview_target_option_button.no_option_text:
		out_dict['PreviewTargetKey'] = target_key
	if not preview_move_input_container.disabled:
		out_dict['PreviewMoveOffset'] = preview_move_input_container.get_val()
	return out_dict

func toggle_move_preview():
	printerr("Togle Move button pressed: %s" % [preview_move_check_box.button_pressed])
	preview_move_input_container.set_disabled(!preview_move_check_box.button_pressed)

func get_target_param_options():
	return PageEditorControl.Instance.get_subeditor_option_keys("TargetParams")
