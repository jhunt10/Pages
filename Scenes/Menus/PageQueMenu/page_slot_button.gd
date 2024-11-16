class_name PageQueSlotButton
extends TextureButton

@export var icon_rect:TextureRect

var _action_key:String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if !icon_rect:
		icon_rect =  $IconRect
	pass # Replace with function body.

func set_page(page:BaseAction, actor:BaseActor):
	if !icon_rect:
		icon_rect =  $IconRect
	_action_key = page.ActionKey
	icon_rect.texture = page.get_small_page_icon(actor)

func get_page()->BaseAction:
	return ActionLibrary.get_action(_action_key)
