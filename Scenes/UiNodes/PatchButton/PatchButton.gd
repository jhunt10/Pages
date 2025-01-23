@tool
class_name PatchButton
extends Control

signal pressed

@export var label:Label
@export var background:NinePatchRect
@export var button:Button

@export var text:String:
	set(val):
		text = val
		if label:
			label.text = text
@export var default_texture:Texture2D:
	set(val):
		default_texture = val
		if background:
			background.texture = default_texture
@export var pressed_texture:Texture2D

func _ready() -> void:
	button.button_down.connect(_on_button_down)
	button.button_up.connect(_on_button_up)

func _on_button_down():
	background.texture = pressed_texture

func _on_button_up():
	background.texture = default_texture
	pressed.emit()
