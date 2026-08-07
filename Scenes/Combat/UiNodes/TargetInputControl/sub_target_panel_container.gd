class_name SubTargetPanelContainer
extends PanelContainer

signal option_selected(option_value)

@export var premade_button:Button
@export var buttons_container:BoxContainer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	premade_button.hide()

func set_options(options:Dictionary):
	for child in buttons_container.get_children():
		if child == premade_button:
			continue
		child.queue_free()
	for option_key in options.keys():
		var new_button = premade_button.duplicate()
		new_button.text = options[option_key]['Text']
		new_button.pressed.connect(_on_button_pressed.bind(options[option_key]['Value']))
		buttons_container.add_child(new_button)
		new_button.show()
	self.size = Vector2.ZERO
	self.show()

func _on_button_pressed(option_value):
	option_selected.emit(option_value)
	for child in buttons_container.get_children():
		if child == premade_button:
			continue
		child.queue_free()
	self.hide()
