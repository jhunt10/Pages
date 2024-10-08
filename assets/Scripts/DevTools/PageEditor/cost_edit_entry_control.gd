class_name CostEditEntryControl
extends HBoxContainer

@onready var delete_button:Button = $Button
@onready var line_edit:LineEdit = $LineEdit
@onready var spin_box:SpinBox = $SpinBox

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	delete_button.pressed.connect(queue_free)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func get_cost_key():
	return line_edit.text
	
func get_cost_value():
	return spin_box.value
