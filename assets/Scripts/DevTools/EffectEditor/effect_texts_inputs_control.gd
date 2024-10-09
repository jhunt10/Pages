class_name EffectTextsInputControl
extends Control

@onready var key_input:LineEdit = $TextsInputContainer/EffectKeyInput
@onready var display_name_input:LineEdit = $TextsInputContainer/DisplayNameContainer/LineEdit
@onready var snippet_input:LineEdit = $TextsInputContainer/SnippetContainer/LineEdit
@onready var description_input:TextEdit = $TextsInputContainer/DescriptionContainer/DescriptionInput
@onready var tags_container:TagListEditControl = $TextsInputContainer/TagsListContainer

@onready var duration_check_box:CheckBox = $TextsInputContainer/DurationContainer/CheckBox
@onready var duration_spin_box:SpinBox = $TextsInputContainer/DurationContainer/SpinBox
@onready var duration_option_button:OptionButton = $TextsInputContainer/DurationContainer/OptionButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	duration_check_box.pressed.connect(on_toggle_duration)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func on_toggle_duration():
	if duration_check_box.button_pressed:
		duration_spin_box.editable = true
		duration_option_button.disabled = false
		duration_option_button.select(0)
	else:
		duration_spin_box.editable = false
		duration_spin_box.set_value_no_signal(0)
		duration_option_button.disabled = true
		duration_option_button.select(-1)

func load_effect_data(data:Dictionary):
	key_input.text = data.get('EffectKey', '')
	display_name_input.text = data.get('DisplayName', '')
	snippet_input.text = data.get('SnippetDesc', '') 
	description_input.text = data.get('Description', '')
	tags_container.set_tags(data.get('Tags',[]))
		

func save_effect_data()->Dictionary:
	var data = {}
	data['EffectKey'] = key_input.text
	data['DisplayName'] = display_name_input.text
	data['SnippetDesc'] = snippet_input.text
	data['Description'] = description_input.text
	data['Tags'] = tags_container.output_tags()
	return data
