class_name StatBarControl
extends Control

@onready var full_bar:NinePatchRect = $FullBarRect
@onready var value_bar:NinePatchRect = $ValueRect
@onready var label:Label = $Label

var max_value:int = 10
var current_value:int = 5

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_values(80,100)
	pass # Replace with function body.

func set_values(cur_val:int, max_val:int):
	max_value = max_val
	current_value = cur_val
	if current_value > 0:
		var full_width = full_bar.size.x
		var cur_width = full_width * current_value / max_value
		value_bar.size.x = cur_width
		value_bar.visible = true
	else:
		value_bar.visible = false
		
	label.text = str(current_value) + " / " + str(max_value)
