class_name MoveInputContainer
extends HBoxContainer

@export var start_disabled:bool = false
		

@onready var x_input:SpinBox = $XInput
@onready var y_input:SpinBox = $YInput
@onready var turn_input:OptionButton = $RotInput

var disabled:bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_disabled(start_disabled)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func set_disabled(val:bool):
	disabled = val
	if disabled:
		x_input.editable = false
		x_input.set_value_no_signal(0)
		y_input.editable = false
		y_input.set_value_no_signal(0)
		turn_input.select(0)
		turn_input.disabled = true
	else:
		x_input.editable = true
		y_input.editable = true
		turn_input.disabled = false

func set_value(val):
	if val is String:
		val = JSON.parse_string(val)
	if val is Array:
		if val.size() >= 1:
			x_input.set_value_no_signal(val[0])
		if val.size() >= 2:
			x_input.set_value_no_signal(val[1])
		if val.size() == 3:
			turn_input.select((val[2]+4)%4)
		if val.size() == 4:
			turn_input.select(int(val[3]+4)%4)
	
func get_val():
	return str([x_input.value, y_input.value, 0, turn_input.selected])
	
func lose_focus_if_has():
	if x_input.has_focus():
		x_input.release_focus()
	var line_edit = x_input.get_line_edit()
	if line_edit.has_focus():
		x_input.apply()
		line_edit.release_focus()
		
	if y_input.has_focus():
		y_input.release_focus()
	line_edit = y_input.get_line_edit()
	if line_edit.has_focus():
		y_input.apply()
		line_edit.release_focus()
