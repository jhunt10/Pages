@tool
class_name MissileEditEntryContainer
extends BaseSubEditEntryContainer

@onready var damage_option_button:LoadedOptionButton = $InnerContainer/DamageSpeedContainer/DamageOptionButton
@onready var frames_per_tile_spin_box:SpinBox = $InnerContainer/DamageSpeedContainer/FramesPerTileContainer/SpeedSpinBox
@onready var missile_vfx_option_button:LoadedOptionButton = $InnerContainer/MissileVfxContainer/MissileVfxOptionButton
@onready var impact_vfx_option_button:LoadedOptionButton = $InnerContainer/ImpactVfxContainer/ImpactVfxOptionButton

func _get_key_input()->LineEdit:
	return $InnerContainer/KeyContainer/KeyLineEdit
	return $InnerContainer/KeyContainer/KeyLineEdit
func _get_delete_button()->Button:
	return $InnerContainer/KeyContainer/DeleteButton

func _ready() -> void:
	super()
	if Engine.is_editor_hint(): return
	damage_option_button.get_options_func = get_damage_options
	missile_vfx_option_button.get_options_func = get_vfx_options
	impact_vfx_option_button.get_options_func = get_vfx_options
	root_editor_control.edit_entry_key_changed.connect(on_entry_key_change)
	pass
	

func get_key_to_input_mapping()->Dictionary:
	return {
		"DamageDataKey": $InnerContainer/DamageSpeedContainer/DamageOptionButton,
		"FramesPerTile": $InnerContainer/DamageSpeedContainer/FramesPerTileContainer/SpeedSpinBox,
		"MissileVfxKey": $InnerContainer/MissileVfxContainer/MissileVfxOptionButton,
		"ImpactVfxKey": $InnerContainer/ImpactVfxContainer/ImpactVfxOptionButton
	}

func get_vfx_options():
	return MainRootNode.vfx_libray._vfx_datas.keys()

func get_damage_options()->Array:
	return root_editor_control.get_subeditor_option_keys("DamageDatas")

func on_entry_key_change(editor_key:String, old_key:String, new_key:String):
	print("ON EntRY KEY CHANGE")
	if editor_key == "DamageDatas":
		if damage_option_button.get_current_option_text() == old_key:
			damage_option_button.load_options(new_key)
	
