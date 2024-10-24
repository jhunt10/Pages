@tool
class_name MissileEditEntryContainer
extends BaseSubEditorContainer

@onready var key_lable:Label = $InnerContainer/KeyContainer/KeyLabel
@onready var key_line_edit:LineEdit =  $InnerContainer/KeyContainer/KeyLineEdit
@onready var damage_option_button:LoadedOptionButton = $InnerContainer/DamageSpeedContainer/DamageOptionButton
@onready var frames_per_tile_spin_box:SpinBox = $InnerContainer/DamageSpeedContainer/FramesPerTileContainer/SpeedSpinBox
@onready var missile_vfx_option_button:LoadedOptionButton = $InnerContainer/MissileVfxContainer/MissileVfxOptionButton
@onready var impact_vfx_option_button:LoadedOptionButton = $InnerContainer/ImpactVfxContainer/ImpactVfxOptionButton

func _ready() -> void:
	super()
	if Engine.is_editor_hint(): return
	title_label = key_lable
	damage_option_button.get_options_func = get_damage_options
	missile_vfx_option_button.get_options_func = get_vfx_options
	impact_vfx_option_button.get_options_func = get_vfx_options
	pass
	

func get_key_to_input_mapping()->Dictionary:
	return {
		"DamageDataKey": $InnerContainer/DamageSpeedContainer/DamageOptionButton,
		"FramesPerTile": $InnerContainer/DamageSpeedContainer/FramesPerTileContainer/SpeedSpinBox,
		"MissileVfxKey": $InnerContainer/MissileVfxContainer/MissileVfxOptionButton,
		"ImpactVfxKey": $InnerContainer/ImpactVfxContainer/ImpactVfxOptionButton
	}

func load_data(object_key:String, data:Dictionary):
	$InnerContainer/KeyContainer/KeyLineEdit.text = object_key
	super(object_key, data)

func lose_focus_if_has():
	if key_line_edit.has_focus():
		key_line_edit.release_focus()
	if frames_per_tile_spin_box.has_focus():
		frames_per_tile_spin_box.apply()
		frames_per_tile_spin_box.release_focus()
	var base_line = frames_per_tile_spin_box.get_line_edit()
	if base_line.has_focus():
		frames_per_tile_spin_box.apply()
		base_line.release_focus()

func get_vfx_options():
	return MainRootNode.vfx_libray._vfx_datas.keys()

func get_damage_options()->Array:
	return root_editor_control.get_subeditor_option_keys("DamageDatas")
