class_name SaveMenu_ConfirmBox
extends PanelContainer

@export var message_label:FitScaleLabel
@export var confirm_button:Button
@export var cancel_button:Button

func _ready() -> void:
	cancel_button.pressed.connect(hide)
