class_name LevelUp_AttributeContainer
extends HBoxContainer

@export var minus_button:TextureButton
@export var plus_button:TextureButton
@export var value_lable:Label

var base_stat_value:int
var current_value:int:
	set(val):
		current_value = val
var goto_value:int:
	set(val):
		goto_value = val

func set_values(base:int, current:int):
	base_stat_value = base
	current_value = current
	goto_value = current

func _ready() -> void:
	plus_button.pressed.connect(_add_point)
	minus_button.pressed.connect(_remove_point)

func _add_point():
	goto_value += 1

func _remove_point():
	goto_value -= 1
