class_name ItemSelection_Button
extends Control

@export var label:Label
@export var icon:TextureRect
@export var button:Button
@export var highlight:TextureRect

func _ready() -> void:
	if highlight:
		highlight.hide()
		button.mouse_entered.connect(highlight.show)
		button.mouse_exited.connect(highlight.hide)

func disable():
	self.modulate.a = 0.5
	self.button.hide()
