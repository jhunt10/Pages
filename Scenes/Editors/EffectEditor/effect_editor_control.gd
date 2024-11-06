@tool
class_name EffectEditorContainer
extends RootEditorControler

@export var subeffect_subedit_container:SubEffectSubEditorContainer
@export var damage_subedit_container:DamageSubEditorContainer
@export var damage_mod_subedit_container:BaseListSubEditorConatiner
@export var stat_mod_subedit_container:BaseListSubEditorConatiner

func _ready() -> void:
	self.object_file_sufux = "_EffectDefs.json"
	self.object_key_name = "EffectKey"
	super()

func get_keys_to_subeditor_mapping()->Dictionary:
	var dict = super()
	dict['DamageDatas'] = damage_subedit_container
	dict['DamageMods'] = damage_mod_subedit_container
	dict['StatMods'] = stat_mod_subedit_container
	dict['SubEffects'] = subeffect_subedit_container
	return dict

func on_exit_menu():
	EffectLibrary.Instance.reload()
	super()
