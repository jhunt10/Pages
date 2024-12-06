class_name DefaultItemDetailsControl
extends Control

@export var description_box:RichTextLabel

func set_item(item:BaseItem):
	if item:
		description_box.text = item.details.description
