@tool
class_name PageEditorControl
extends RootEditorControler

@export var preview_subedit_container:PreviewSubEditorContainer
@export var cost_subedit_container:CostSubEditorContainer
@export var subactions_subedit_container:SubActionSubEditorControl
@export var damage_subedit_container:DamageSubEditorContainer
@export var missile_subedit_container:MissileSubEditorContainer
@export var target_subedit_container:TargetSubEditorContainer

func _ready() -> void:
	self.object_file_sufux = "_ActionDefs.json"
	self.object_key_name = "ActionKey"
	super()

func get_keys_to_subeditor_mapping()->Dictionary:
	var dict = super()
	dict['CostData'] = cost_subedit_container
	dict['TargetParams'] = target_subedit_container
	dict['DamageDatas'] = damage_subedit_container
	dict['MissileDatas'] = missile_subedit_container
	dict['SubActions'] = subactions_subedit_container
	dict['Preview'] = preview_subedit_container
	return dict

func on_exit_menu():
	ActionLibrary.Instance.reload()
	super()
