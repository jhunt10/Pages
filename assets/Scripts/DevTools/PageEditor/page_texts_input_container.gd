class_name PageTextsInputControl
extends Control

@onready var key_input:LineEdit = $TextsInputContainer/PageKeyInput
@onready var display_name_input:LineEdit = $TextsInputContainer/DisplayNameContainer/LineEdit
@onready var snippet_input:LineEdit = $TextsInputContainer/SnippetContainer/LineEdit
@onready var preview_target_option:LoadedOptionButton = $TextsInputContainer/PreviewTargetContainer/TargetPreviewOptionButton
@onready var preview_target_check_box:CheckBox = $TextsInputContainer/PreviewTargetContainer/PrevTargetCheckBox
@onready var preview_movement_input:MoveInputContainer = $TextsInputContainer/PreviewMoveContainer/MoveInputContainer
@onready var preview_movement_check_box:CheckBox = $TextsInputContainer/PreviewMoveContainer/PrevMoveCheckBox
@onready var description_input:TextEdit = $TextsInputContainer/DescriptionContainer/DescriptionInput
@onready var tags_container:TagListEditControl = $TextsInputContainer/TagsListContainer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	preview_target_option.get_options_func = get_target_preview_options
	preview_target_check_box.pressed.connect(toggle_prev_target)
	preview_movement_check_box.pressed.connect(toggle_prev_move)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func load_page_data(data:Dictionary):
	key_input.text = data.get('ActionKey', '')
	display_name_input.text = data.get('DisplayName', '')
	snippet_input.text = data.get('SnippetDesc', '') 
	description_input.text = data.get('Description', '')
	tags_container.set_tags(data.get('Tags',[]))
	if data.keys().has('PreviewTargetKey'):
		preview_target_option.load_options(data.get('PreviewTargetKey', ''))
		preview_target_option.disabled = false
		preview_target_check_box.button_pressed = true
	else:
		preview_target_option.load_options()
		preview_target_option.disabled = true
		preview_target_check_box.button_pressed = false
		
	if data.keys().has('PreviewMoveOffset'):
		preview_movement_input.set_value(data['PreviewMoveOffset'])
		preview_movement_input.set_disabled(false)
		preview_movement_check_box.button_pressed = true
	else:
		preview_movement_input.set_disabled(true)
		preview_movement_check_box.button_pressed = false
		

func save_page_data()->Dictionary:
	var data = {}
	data['ActionKey'] = key_input.text
	data['DisplayName'] = display_name_input.text
	data['SnippetDesc'] = snippet_input.text
	data['Description'] = description_input.text
	data['Tags'] = tags_container.output_tags()
	if preview_target_check_box.button_pressed:
		data['PreviewTargetKey'] = preview_target_option.get_current_option_text()
	if preview_movement_check_box.button_pressed:
		data['PreviewMoveOffset'] = preview_movement_input.get_val()
	return data

func get_target_preview_options():
	var list:Array = ["Self"]
	list.append_array(PageEditControl.Instance.get_target_params().keys())
	return list

func toggle_prev_target():
	preview_target_option.load_options()
	preview_target_option.disabled = not preview_target_check_box.button_pressed
	printerr("Toggle Targ: " + str(preview_target_check_box.button_pressed))

func toggle_prev_move():
	preview_movement_input.set_disabled(not preview_movement_check_box.button_pressed)
