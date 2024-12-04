class_name BagItemSlotButton_Old
extends Button

var item_id:String

var item_icon:TextureRect:
	get: return $HBoxContainer/TextureRect
var label:Label:
	get: return $HBoxContainer/Label

func set_item(item:BaseItem):
	item_id = item.Id
	item_icon.texture = item.get_small_icon()
	label.text = item.details.display_name
