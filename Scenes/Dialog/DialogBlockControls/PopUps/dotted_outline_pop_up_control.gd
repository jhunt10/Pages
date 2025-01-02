class_name DottedPopUpControl
extends Control

signal pressed

@export var outline_texture:Texture2D
@export var outline_shadowed_texture:Texture2D

@export var outline_patch:NinePatchRect
@export var shadow_rect_left:ColorRect
@export var shadow_rect_right:ColorRect
@export var shadow_rect_top:ColorRect
@export var shadow_rect_bot:ColorRect

@export var button:Button

@export var darken_screen:bool

func _ready() -> void:
	button.pressed.connect(self.pressed.emit)
	if darken_screen:
		outline_patch.texture = outline_shadowed_texture
		shadow_rect_left.show()
		shadow_rect_right.show()
		shadow_rect_top.show()
		shadow_rect_bot.show()
	else:
		outline_patch.texture = outline_texture
		shadow_rect_left.hide()
		shadow_rect_right.hide()
		shadow_rect_top.hide()
		shadow_rect_bot.hide()
		
func set_dialog_block(block_data):
	darken_screen = block_data.get("DarkenScreen", false)
