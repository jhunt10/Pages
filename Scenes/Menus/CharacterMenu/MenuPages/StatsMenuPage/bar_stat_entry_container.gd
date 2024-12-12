class_name BarStatEntryContainer
extends HBoxContainer

@export var icon:TextureRect
@export var name_label:Label
@export var max_val_label:Label
@export var regen_val_label:Label

func set_stat_vals(color:Color, name:String, max_val:int, regen:int):
	icon.modulate = color
	name_label.text = name
	max_val_label.text = str(max_val)
	regen_val_label.text = str(regen)
