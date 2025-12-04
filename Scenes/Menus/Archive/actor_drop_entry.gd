class_name ActorDropEntry
extends HBoxContainer

@export var icon_background:TextureRect
@export var icon_rect:TextureRect
@onready var title_label:FitScaleLabel = $FitScaleLabel

var _item_key:String

func _ready() -> void:
	if _item_key.begins_with("Money"):
		title_label.text = _item_key.split(":")[1] + " Money"
		icon_rect.texture = ItemHelper.get_money_small_icon() 
	elif _item_key:
		if title_label:
			title_label.text = ItemLibrary.Instance.get_display_name_of_def(_item_key)
		icon_background.texture = ItemHelper.get_rarity_background_for_item_key(_item_key)
		var icon = ItemLibrary.Instance.get_small_icon_of_def(_item_key)
		icon_rect.texture = icon

func set_item(item_key:String):
	_item_key = item_key
