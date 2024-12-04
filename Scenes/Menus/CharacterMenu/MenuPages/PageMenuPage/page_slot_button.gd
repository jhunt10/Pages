class_name PageSlotButton
extends TextureRect

var item_key:String
@export var icon:TextureRect
@export var button:Button

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func set_key(key):
	if key:
		var item = ActionLibrary.get_action(key)
		var icon_texture = item.get_large_page_icon()
		icon.texture = icon_texture
	
	
