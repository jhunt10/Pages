@tool
class_name PageEditorControl
extends RootEditorControler

@export var preview_subedit_container:PreviewSubEditorContainer
@export var cost_subedit_container:CostSubEditorContainer

func _ready() -> void:
	self.object_file_sufux = "_Pages.json"
	self.object_key_name = "ActionKey"
	super()

func get_keys_to_subeditor_mapping()->Dictionary:
	var dict = super()
	dict['Preview'] = preview_subedit_container
	dict['CostData'] = cost_subedit_container
	return dict
