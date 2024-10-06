class_name PageTextsInputControl
extends Control

@onready var key_input:LineEdit = $TextsInputContainer/PageKeyInput
@onready var display_name_input:LineEdit = $TextsInputContainer/DisplayNameContainer/LineEdit
@onready var snippet_input:LineEdit = $TextsInputContainer/SnippetContainer/LineEdit
@onready var preview_target_option:LoadedOptionButton = $TextsInputContainer/PreviewTargetContainer/TargetPreviewOptionButton
@onready var description_input:TextEdit = $TextsInputContainer/DescriptionContainer/DescriptionInput
@onready var tags_container:TagListEditControl = $TextsInputContainer/TagsListContainer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	preview_target_option.get_options_func = get_target_preview_options
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
	preview_target_option.load_options(data.get('PreviewTargetKey', ''))

func save_page_data()->Dictionary:
	var data = {}
	data['ActionKey'] = key_input.text
	data['DisplayName'] = display_name_input.text
	data['SnippetDesc'] = snippet_input.text
	data['Description'] = description_input.text
	data['Tags'] = tags_container.output_tags()
	if preview_target_option.get_current_option_text() != 'None':
		data['PreviewTargetKey'] = preview_target_option.get_current_option_text()
	return data

func get_target_preview_options():
	return PageEditControl.Instance.get_target_params().keys()

#func _preview_target_input_focused(current_option:String = ''):
	#if current_option == '' and preview_target_option.selected >= 0:
		#current_option = preview_target_option.get_item_text(preview_target_option.selected)
	## Reload and rebuild options
	#preview_target_option.clear()
	#var selected_index = -1
	#var keys = 
	#if keys.size() != 0:
		#for key in keys:
			#preview_target_option.add_item(key)
			#if key == current_option:
				#selected_index = preview_target_option.item_count - 1
	#else:
		#preview_target_option.add_item("No Targeting")
		#selected_index = 0
	#preview_target_option.select(selected_index)
