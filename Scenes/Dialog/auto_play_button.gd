class_name AutoDialogControlButton
extends DialogControlButton

signal toggled(on:bool)

@export var check_box_rect:TextureRect
@export var checked_texture:Texture2D
@export var unchecked_texture:Texture2D

@export var is_on:bool:
	set(val):
		is_on = val
		if check_box_rect:
			if is_on: check_box_rect.texture = checked_texture
			else:check_box_rect.texture = unchecked_texture

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	button.pressed.connect(_on_button_press)
	if is_on: check_box_rect.texture = checked_texture
	else:check_box_rect.texture = unchecked_texture
		

func _on_button_press():
	is_on = !is_on
	toggled.emit(is_on)
