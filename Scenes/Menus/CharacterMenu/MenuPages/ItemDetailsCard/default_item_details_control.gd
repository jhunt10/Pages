class_name DefaultItemDetailsControl
extends Control

@export var description_box:DescriptionBox

func set_item(item:BaseItem):
	if item:
		description_box.set_object(item._def, item, null)
