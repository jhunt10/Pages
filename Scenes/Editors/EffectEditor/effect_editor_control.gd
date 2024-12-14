@tool
class_name EffectEditorContainer
extends RootEditorControler

@export var subeffect_subedit_container:SubEffectSubEditorContainer
@export var damage_subedit_container:DamageSubEditorContainer
@export var damage_mod_subedit_container:BaseListSubEditorConatiner
@export var stat_mod_subedit_container:BaseListSubEditorConatiner
@export var show_in_hud_checkbox:CheckBox
@export var show_durration_checkbox:CheckBox

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
	#EffectLibrary.Instance.reload()
	super()

func _build_active_object_save_data(object_key:String)->Dictionary:
	var data = super(object_key)
	data['ShowInHud'] = show_in_hud_checkbox.button_pressed
	data['ShowDuration'] = show_durration_checkbox.button_pressed
	return data

func _on_data_loaded(data:Dictionary):
	show_in_hud_checkbox.button_pressed = data.get("ShowInHud", false)
	show_durration_checkbox.button_pressed = data.get("ShowDuration", false)
	
