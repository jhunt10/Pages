class_name ActorDeploymentControl
extends Control
signal cancled

@export var close_button:TextureButton
@export var cancel_button:Button

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	close_button.pressed.connect(on_canceled_button)
	cancel_button.pressed.connect(on_canceled_button)
	pass # Replace with function body.

func on_canceled_button():
	cancled.emit()
