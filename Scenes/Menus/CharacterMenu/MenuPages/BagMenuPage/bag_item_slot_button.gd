class_name BagItemSlotButton
extends NinePatchRect

var item_key:String
@export var item_icon:TextureRect
@export var label:Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func set_key(key):
	if item_key:
		item_key = key
		var item = ItemLibrary.get_item(item_key)
		if item:
			item_key = item._key
			item_icon.texture = item.get_large_icon()
			label.text = item.details.display_name
