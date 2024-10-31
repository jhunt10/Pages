class_name EquipmentDisplaySlotButton
extends TextureButton

@export var background:Texture2D
@export var highlight_background:Texture2D
@export var default_icon_texture:Texture2D
@export var icon_texture_rect:TextureRect

var default_icons_paths:Dictionary = {
	"Head": "res://assets/Sprites/UI/CharacterEdit/HeadSlot.png",
	"Body": "res://assets/Sprites/UI/CharacterEdit/BodySlot.png",
	"Feet": "res://assets/Sprites/UI/CharacterEdit/BootSlot.png",
	"Que": "res://assets/Sprites/UI/CharacterEdit/BookSlot.png",
	"Bag": "res://assets/Sprites/UI/CharacterEdit/BagSlot.png",
	"Trinket": "res://assets/Sprites/UI/CharacterEdit/TrinketSlot.png",
	"Weapon": "res://assets/Sprites/UI/CharacterEdit/MainHandSlot.png",
	"Shield": "res://assets/Sprites/UI/CharacterEdit/OffHandSlot.png"
}
var slot_type:String
var current_item_id:String = ''

func _ready() -> void:
	if !icon_texture_rect.texture:
		icon_texture_rect.texture = default_icon_texture

func set_slot_type(type:String):
	slot_type = type
	if default_icons_paths.keys().has(type):
		default_icon_texture = load(default_icons_paths[type])
	if current_item_id == '':
		icon_texture_rect.texture = default_icon_texture
		

func set_item(item:BaseEquipmentItem):
	icon_texture_rect.texture = item.get_large_icon()
	current_item_id = item.Id
	
func clear_item():
	icon_texture_rect.texture = default_icon_texture

func highlight(val:bool):
	if val:
		self.texture_normal = highlight_background
	else:
		self.texture_normal = background

func is_mouse_over()->bool:
	return Rect2(Vector2i.ZERO, self.size).has_point( get_local_mouse_position())
