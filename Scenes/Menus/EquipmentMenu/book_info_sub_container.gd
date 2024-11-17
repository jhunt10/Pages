class_name BookInfoSubContainer
extends HBoxContainer

@export var ppr_label:Label
@export var page_count_label:Label

func set_item(item:BaseQueEquipment):
	ppr_label.text = str(item.get_pages_per_round())
	page_count_label.text = str(item.get_max_page_count())
