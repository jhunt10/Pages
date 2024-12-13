class_name BagItemSlotButton
extends Control

var _item_id:String
@export var highlight:TextureRect
@export var background:NinePatchRect
@export var item_icon:TextureRect
@export var label:Label
@export var button:Button
@export var bg_texture_single:Texture2D
@export var bg_texture_top:Texture2D
@export var bg_texture_middle:Texture2D
@export var bg_texture_bottom:Texture2D
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	highlight.hide()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func set_item_id(item_id, background_type):
	if item_id:
		_item_id = item_id
		var item = ItemLibrary.get_item(_item_id)
		if item:
			item_icon.texture = item.get_small_icon()
			label.text = item.details.display_name
	if background_type == "Single":
		background.texture = bg_texture_single
	if background_type == "Top":
		background.texture = bg_texture_top
	if background_type == "Bottom":
		background.texture = bg_texture_bottom
	if background_type == "Middle":
		background.texture = bg_texture_middle

func show_highlight():
	highlight.show()

func hide_highlight():
	highlight.hide()
