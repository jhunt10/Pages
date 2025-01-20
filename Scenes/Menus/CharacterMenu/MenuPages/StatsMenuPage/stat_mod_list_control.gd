class_name StatModListControl
extends Control

@export var container:VBoxContainer
@export var label:Label


func set_mod_list(list:Array):
	for val in list:
		var new_label = label.duplicate()
		new_label.text = val
		container.add_child(new_label)
		new_label.show()
