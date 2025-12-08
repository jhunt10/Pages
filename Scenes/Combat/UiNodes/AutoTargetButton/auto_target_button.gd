@tool
class_name AutoTargetButton
extends TextureButton

signal auto_target_toggled(auto_target)

@export var auto_manual_icon:TextureRect
@export var auto_texture:Texture2D
@export var manual_texture:Texture2D

@export var auto_target_enabled:bool:
	set(val):
		if val:
			auto_target_enabled = true
			if auto_manual_icon and auto_texture:
				auto_manual_icon.texture = auto_texture
		else:
			auto_target_enabled = false
			if auto_manual_icon and manual_texture:
				auto_manual_icon.texture = manual_texture
func _ready() -> void:
	self.auto_target_enabled = CombatRootControl.Instance.auto_targeting_enabled

func _pressed():
	auto_target_enabled = !auto_target_enabled
	auto_target_toggled.emit(auto_target_enabled)
	CombatRootControl.Instance.auto_targeting_enabled = auto_target_enabled
