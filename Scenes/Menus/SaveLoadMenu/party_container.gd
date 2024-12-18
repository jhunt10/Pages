class_name PartyContainer
extends HBoxContainer

@export var names_container:Container
@export var spacer_container:Container
@export var level_container:Container

var _premade_name_label:Label
var _premade_spacer:Control
var _premade_level_label:Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_premade_name_label = names_container.get_child(0)
	_premade_spacer = spacer_container.get_child(0)
	_premade_level_label = level_container.get_child(0)
	
	_premade_name_label.hide()
	_premade_spacer.hide()
	_premade_level_label.hide()
	pass # Replace with function body.

func clear():
	for child in names_container.get_children():
		if child != _premade_name_label:
			child.queue_free()
	for child in spacer_container.get_children():
		if child != _premade_spacer:
			child.queue_free()
	for child in level_container.get_children():
		if child != _premade_level_label:
			child.queue_free()

func add_row(name:String, level:int):
	var new_name = _premade_name_label.duplicate()
	new_name.text = name
	names_container.add_child(new_name)
	new_name.show()
	var new_spacer = _premade_spacer.duplicate()
	spacer_container.add_child(new_spacer)
	new_spacer.show()
	var new_level = _premade_level_label.duplicate()
	new_level.text = "lv "+str(level)
	level_container.add_child(new_level)
	new_level.show()
	pass
