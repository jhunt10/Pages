class_name TriggerEditEntryContainer
extends HBoxContainer


@onready var label:Label = $Label
@onready var button:Button = $Button
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	button.pressed.connect(self.queue_free)

func set_label(text:String):
	if !label:
		label = $Label
	label.text = text
