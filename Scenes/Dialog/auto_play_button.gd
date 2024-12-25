class_name AutoPlayButton
extends Control

signal toggled(on:bool)

@export var is_on:bool:
	set(val):
		is_on = val
		if is_on: check_box_rect.texture = checked_texture
		else:check_box_rect.texture = unchecked_texture
@export var button:Button
@export var check_box_rect:TextureRect
@export var checked_texture:Texture2D
@export var unchecked_texture:Texture2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	button.pressed.connect(_on_button_press)

func _on_button_press():
	is_on = !is_on
	toggled.emit(is_on)
