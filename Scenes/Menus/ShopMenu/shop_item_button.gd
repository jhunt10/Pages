class_name ShopItemButton
extends Control

@export var item_background:TextureRect
@export var item_icon:TextureRect
@export var item_label:Control
@export var price_label:Label
@export var button:Button

func set_item(item:BaseItem):
	item_label.text = item.get_display_name() + " .................................."
	item_background.texture = item.get_rarity_background()
	item_icon.texture = item.get_small_icon()
	price_label.text = str(item.get_item_value())
