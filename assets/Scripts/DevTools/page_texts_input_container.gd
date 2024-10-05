class_name PageTextsInputControl
extends VBoxContainer

@onready var key_input:LineEdit = $PageKeyInput
@onready var display_name_input:LineEdit = $DisplayNameContainer/LineEdit
@onready var snippet_input:LineEdit = $SnippetContainer/LineEdit
@onready var preview_target_option:OptionButton = $PreviewTargetContainer/OptionButton
@onready var description_input:TextEdit = $DescriptionContainer/DescriptionInput
@onready var tags_container:TagListEditControl = $TagsListContainer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	preview_target_option.focus_entered.connect(_preview_target_input_focused)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func load_page_data(data:Dictionary):
	key_input.text = data['ActionKey']
	display_name_input.text = data['DisplayName']
	snippet_input.text = data['SnippetDesc']
	description_input.text = data['Description']
	tags_container.set_tags(data['Tags'])
	_preview_target_input_focused(data.get('PreviewTargetKey', ''))
	


func _preview_target_input_focused(current_option:String = ''):
	if current_option == '' and preview_target_option.selected >= 0:
		current_option = preview_target_option.get_item_text(preview_target_option.selected)
	# Reload and rebuild options
	preview_target_option.clear()
	var selected_index = -1
	var keys = PageEditControl.Instance.get_target_params().keys()
	if keys.size() != 0:
		for key in keys:
			preview_target_option.add_item(key)
			if key == current_option:
				selected_index = preview_target_option.item_count - 1
	else:
		preview_target_option.add_item("No Targeting")
		selected_index = 0
	preview_target_option.select(selected_index)
