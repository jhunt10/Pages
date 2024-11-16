class_name EquipmentMenuMouseControl
extends Control

@export var weapon_mouse_over:MouseOverWeaponContainer
@export var mouse_over_message_container:BackPatchContainer
@export var mouse_over_label:Label
@export var drag_item_control:Control
@export var drag_icon_texture_rect:TextureRect

func _ready() -> void:
	mouse_over_message_container.visible = false
	weapon_mouse_over.visible = false
	drag_item_control.visible = false

func set_dragging_item(item:BaseItem):
	if !item:
		drag_item_control.visible = false
		drag_icon_texture_rect.texture = null
		return
		
	drag_item_control.visible = true
	drag_icon_texture_rect.texture = item.get_large_icon()
	if mouse_over_message_container.visible:
		clear_message()
	
func set_hover_item(item:BaseItem):
	if drag_item_control.visible:
		return
	if item is BaseWeaponEquipment:
		weapon_mouse_over.visible = true
		mouse_over_message_container.visible = false
		weapon_mouse_over.set_weapon(item as BaseWeaponEquipment)
	else:
		weapon_mouse_over.visible = false
		mouse_over_message_container.visible = true
		mouse_over_label.text = item.details.display_name + "\n" + item.details.snippet

func clear_message():
	mouse_over_message_container.visible = false
	mouse_over_label.text = ''
	weapon_mouse_over.visible = false
