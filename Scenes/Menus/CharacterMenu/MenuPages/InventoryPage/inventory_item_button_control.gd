class_name InventoryItemButton
extends Control

@export var item_icon_rect:TextureRect
@export var equipt_icon:TextureRect
@export var count_label:Label
@export var button:Button
@export var name_label:FitScaleLabel
@export var background:TextureRect
				

@export var mundane_background:Texture2D
@export var common_background:Texture2D
@export var rare_background:Texture2D
@export var legend_background:Texture2D
var _item_id:String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if !item_icon_rect:
		item_icon_rect =  $ItemIconRect
		equipt_icon = $EquiptIcon
		count_label = $CountLabel
	pass # Replace with function body.

func set_item(item:BaseItem, count:int=0):
	if !item_icon_rect:
		item_icon_rect =  $ItemIconRect
		background =  $Background
		equipt_icon = $EquiptIcon
		count_label = $CountLabel
	if !name_label:
		name_label = $NinePatchRect/FitScaleLabel
	_item_id = item.Id
	name_label.text = item.get_display_name()
	item_icon_rect.texture = item.get_large_icon()
	equipt_icon.visible = false
	background.texture = item.get_rarity_background()
	set_count(count)

func on_equipt_change():
	var item = ItemLibrary.get_item(_item_id)
	equipt_icon.visible = (item as BaseEquipmentItem).get_equipt_to_actor_id() != ''

func get_item()->BaseItem:
	return ItemLibrary.get_item(_item_id)

func set_count(count:int):
	if count <= 1:
		count_label.visible = false
		return
	if !count_label:
		count_label = $CountLabel
	var old_size = count_label.size
	count_label.text = str(count)
	#count_label.get_child(1).text = str(count)
	#count_label.reset_size()
	#var new_size = count_label.size
	#count_label.position.x += old_size.x - new_size.x 
	count_label.visible = true
