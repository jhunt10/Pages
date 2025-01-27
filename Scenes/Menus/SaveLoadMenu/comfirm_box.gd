class_name SaveMenu_ConfirmBox
extends NinePatchRect

@export var message_label:FitScaleLabel
@export var confirm_button:TextureButton
@export var cancel_button:TextureButton

func _ready() -> void:
	cancel_button.pressed.connect(hide)
