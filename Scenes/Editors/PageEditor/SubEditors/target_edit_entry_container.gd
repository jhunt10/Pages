@tool
class_name TargetEditEntryContainer
extends BaseSubEditEntryContainer

@onready var area_subedit_container:AreaEditorContainer = $InnerContainer/AreaSubEditorContainer
@onready var type_option_button:LoadedOptionButton = $InnerContainer/TypeContainer/TypeOptionButton
@onready var los_check_box:CheckBox = $InnerContainer/HasAreaContainer/LOSCheckBox
@onready var has_aoe_check_box:CheckBox = $InnerContainer/HasAreaContainer/HasEffectCheckBox
@onready var effects_allies_check_box:CheckBox = $InnerContainer/CheckBoxesContainer/AlliesCheckBox
@onready var effects_enemies_check_box:CheckBox = $InnerContainer/CheckBoxesContainer/EnemiesCheckBox
@onready var effect_check_boxes_container:HBoxContainer = $InnerContainer/CheckBoxesContainer

func _get_key_input()->LineEdit:
	return $InnerContainer/KeyContainer/KeyLineEdit
func _get_delete_button()->Button:
	return $InnerContainer/KeyContainer/DeleteButton

func _ready() -> void:
	super()
	if Engine.is_editor_hint(): return
	#title_label = key_lable
	type_option_button.get_options_func = get_target_type_options
	has_aoe_check_box.pressed.connect(on_has_effect_pressed)
	#key_line_edit.focus_exited.connect(on_key_change)
	#delete_button.pressed.connect(on_delete)
	pass
	

func get_key_to_input_mapping()->Dictionary:
	return {
		"TargetType":$InnerContainer/TypeContainer/TypeOptionButton,
		"LineOfSight": $InnerContainer/HasAreaContainer/LOSCheckBox,
		"EffectsAllies": $InnerContainer/CheckBoxesContainer/AlliesCheckBox,
		"EffectsEnemies": $InnerContainer/CheckBoxesContainer/EnemiesCheckBox
	}

func load_data(object_key:String, data:Dictionary):
	$InnerContainer/KeyContainer/KeyLineEdit.text = object_key
	super(object_key, data)
	area_subedit_container.clear()
	var target_area = data.get("TargetArea", [])
	area_subedit_container.add_editable_area("TRG", target_area, true)
	var area_effect = data.get("EffectArea", "[]")
	if area_effect and not (area_effect == "[]" or area_effect == ""):
		area_subedit_container.add_editable_area("AOE", data['EffectArea'], false)
		set_has_effect(true)
	else:
		set_has_effect(false)
	area_subedit_container.set_editing_area("Targ")

func build_save_data():
	var data = super()
	data['TargetArea'] = area_subedit_container.build_area_data("TRG")
	if has_aoe_check_box.button_pressed:
		data['EffectArea'] = area_subedit_container.build_area_data("AOE")
	return data
	

#func lose_focus_if_has():
	#if key_line_edit.has_focus():
		#key_line_edit.release_focus()

#func clear():
	#super()
	#key_line_edit.text = ""
	#area_subedit_container.clear()



func on_has_effect_pressed():
	set_has_effect(has_aoe_check_box.button_pressed)
	pass

func set_has_effect(val:bool):
	if val:
		effect_check_boxes_container.visible = true
		if !area_subedit_container._editing_areas.keys().has("AOE"):
			area_subedit_container.add_editable_area("AOE", [], true)
		if not has_aoe_check_box.button_pressed:
			has_aoe_check_box.button_pressed = true
	else:
		effect_check_boxes_container.visible = false
		area_subedit_container.set_editing_area("TRG")
		area_subedit_container.remove_editable_area("AOE")
		if has_aoe_check_box.button_pressed:
			has_aoe_check_box.button_pressed = false

#func on_key_change():
	## Key didn't change
	#if key_line_edit.text == _object_key:
		#printerr("Key didn't change")
		#return
	#printerr("Key changed")
	#var new_key = key_line_edit.text
	#_parent_target_subeditor.on_entry_key_changed(_object_key, new_key)
	#self._object_key = new_key
	

func get_vfx_options():
	return MainRootNode.vfx_libray._vfx_datas.keys()

func get_target_type_options()->Array:
	return TargetParameters.TargetTypes.keys()
