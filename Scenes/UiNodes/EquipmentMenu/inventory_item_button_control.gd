class_name InventoryItemButton
extends TextureButton

@export var item_icon_rect:TextureRect
@export var equipt_icon:TextureRect

var _item_id:String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if !item_icon_rect:
		item_icon_rect =  $ItemIconRect
		equipt_icon = $EquiptIcon
	pass # Replace with function body.

func set_item(item:BaseItem):
	if !item_icon_rect:
		item_icon_rect =  $ItemIconRect
		equipt_icon = $EquiptIcon
	_item_id = item.Id
	item_icon_rect.texture = item.get_large_icon()
	if item is BaseEquipmentItem:
		equipt_icon.visible = (item as BaseEquipmentItem).get_equipt_to_actor_id() != ''
	(item as BaseEquipmentItem).equipt_actor_change.connect(on_equipt_change)

func on_equipt_change():
	var item = ItemLibrary.get_item(_item_id)
	equipt_icon.visible = (item as BaseEquipmentItem).get_equipt_to_actor_id() != ''

func get_item()->BaseItem:
	return ItemLibrary.get_item(_item_id)
