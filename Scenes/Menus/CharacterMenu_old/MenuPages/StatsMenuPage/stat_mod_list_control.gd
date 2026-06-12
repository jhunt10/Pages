class_name StatModListControl
extends Control

@export var container:VBoxContainer
@export var name_label:Label
@export var mods_label:Label


func set_mod_list(stat_name:String, list:Array):
	name_label.text = "  "+stat_name+"  "
	if list.size() > 0:
		for val in list:
			var new_label = mods_label.duplicate()
			new_label.text = val
			container.add_child(new_label)
			new_label.show()
	else:
		mods_label.hide()
