class_name ShopItemButton
extends Control

@export var item_background:TextureRect
@export var item_icon:TextureRect
@export var item_label:Control
@export var button:Button

func set_item(item:BaseItem):
	item_label.text = item.details.display_name
	item_background.texture = item.get_rarity_background()
	item_icon.texture = item.get_small_icon()
