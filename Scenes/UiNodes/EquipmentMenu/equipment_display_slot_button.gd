class_name EquipmentDisplaySlotButton
extends TextureButton

@export var background:Texture2D
@export var highlight_background:Texture2D
@export var default_icon_texture:Texture2D
@export var icon_texture_rect:TextureRect

func _ready() -> void:
	if !icon_texture_rect.texture:
		icon_texture_rect.texture = default_icon_texture

func set_item(item:BaseEquipmentItem):
	icon_texture_rect.texture = item.get_large_icon()
	
func clear_item():
	icon_texture_rect.texture = default_icon_texture

func highlight(val:bool):
	if val:
		self.texture_normal = highlight_background
	else:
		self.texture_normal = background

func is_mouse_over()->bool:
	return Rect2(Vector2i.ZERO, self.size).has_point( get_local_mouse_position())
