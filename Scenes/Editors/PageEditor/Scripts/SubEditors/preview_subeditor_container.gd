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
	preview_target_option_button.get_options_func = get_targeting_options
	super()
	if Engine.is_editor_hint():
		return


func get_targeting_options()->Array:
	return []

func load_data(object_key:String, data:Dictionary):
	super(object_key, data)
	if data.keys().has("PreviewMoveOffset"):
		preview_move_check_box.button_pressed = true
		preview_move_input_container.set_disabled(false)
	else:
		preview_move_check_box.button_pressed = false
		preview_move_input_container.set_disabled(true)
