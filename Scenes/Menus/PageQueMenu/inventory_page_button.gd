class_name InventoryPageButton
extends TextureButton

@export var icon_rect:TextureRect

var _item_key:String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if !icon_rect:
		icon_rect =  $IconRect
	pass # Replace with function body.

func set_page(page:BasePageItem):
	if !icon_rect:
		icon_rect =  $IconRect
	_item_key = page.ItemKey
	icon_rect.texture = page.get_large_page_icon()

func get_page()->PageItemAction:
	return ItemLibrary.get_item(_item_key)
