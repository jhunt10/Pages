class_name SuppliesItemSlotButton
extends BaseCharacterMenu_ItemSlotButton

var _item_id:String
@export var highlight:TextureRect
@export var background:NinePatchRect
@export var label:Label

@export var bg_texture_single:Texture2D
@export var bg_texture_top:Texture2D
@export var bg_texture_middle:Texture2D
@export var bg_texture_bottom:Texture2D

func set_item(actor:BaseActor, holder:BaseItemHolder, item:BaseItem):
	super(actor, holder, item)
	if item:
		label.text = item.get_display_name()

func set_background_type(background_type:String):
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
