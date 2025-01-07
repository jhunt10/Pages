class_name DottedPopUpControl
extends Control

signal pressed

enum LineTypes {Fancy, Dotted, Solid}


@export var dotted_outline_texture:Texture2D
@export var solid_outline_texture:Texture2D
@export var fancy_outline_texture:Texture2D
@export var fancy_outline_shadowed_texture:Texture2D

@export var outline_patch:NinePatchRect
@export var shadow_rect_left:ColorRect
@export var shadow_rect_right:ColorRect
@export var shadow_rect_top:ColorRect
@export var shadow_rect_bot:ColorRect
@export var click_label:Label

@export var button:Button

@export var darken_screen:bool
@export var show_outline:bool

@export var line_type:LineTypes:
	set(val):
		line_type = val
		if !outline_patch:
			return
		
		if line_type == LineTypes.Fancy:
			if show_outline:
				outline_patch.texture = fancy_outline_texture
				outline_patch.patch_margin_top = 36
				outline_patch.patch_margin_bottom = 36
				outline_patch.patch_margin_left = 36
				outline_patch.patch_margin_right = 36
			else:
				outline_patch.texture = fancy_outline_shadowed_texture
		elif line_type == LineTypes.Dotted:
				outline_patch.texture = dotted_outline_texture
				outline_patch.patch_margin_top = 8
				outline_patch.patch_margin_bottom = 8
				outline_patch.patch_margin_left = 8
				outline_patch.patch_margin_right = 8
		elif line_type == LineTypes.Solid:
				outline_patch.texture = solid_outline_texture
				outline_patch.patch_margin_top = 8
				outline_patch.patch_margin_bottom = 8
				outline_patch.patch_margin_left = 8
				outline_patch.patch_margin_right = 8

func _ready() -> void:
	button.pressed.connect(self.pressed.emit)
	if darken_screen:
		outline_patch.texture = fancy_outline_shadowed_texture
		shadow_rect_left.show()
		shadow_rect_right.show()
		shadow_rect_top.show()
		shadow_rect_bot.show()
	else:
		outline_patch.texture = fancy_outline_texture
		shadow_rect_left.hide()
		shadow_rect_right.hide()
		shadow_rect_top.hide()
		shadow_rect_bot.hide()
	line_type = line_type
		
func set_dialog_block(block_data):
	darken_screen = block_data.get("DarkenScreen", false)
	if not block_data.get("ShowOutLine", true):
		outline_patch.texture = null
	
	var type_str = block_data.get("LineType", "")
	var type = LineTypes.get(type_str)
	if type == null:
		type = LineTypes.Fancy
	line_type = type
	
	if block_data.has("Color"):
		var color = block_data['Color']
		outline_patch.self_modulate = Color(color[0], color[1], color[2], color[3])
	
	if block_data.get("ShowClick", false):
		click_label.show()
	else:
		click_label.hide()
	
