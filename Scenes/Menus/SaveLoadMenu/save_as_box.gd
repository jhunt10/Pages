class_name SaveAsBox
extends NinePatchRect

signal on_confirmed(save_name:String)

@export var name_input:LineEdit
@export var save_button:TextureButton
@export var back_button:TextureButton


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	back_button.pressed.connect(self.queue_free)
	save_button.pressed.connect(on_save)

func on_save():
	on_confirmed.emit(name_input.text)
	self.hide()
