class_name BaseCharacterMenu_ItemSlotButton
extends Node

@export var button:Button
@export var highlight_background_rect:TextureRect
@export var item_icon_rect:TextureRect
@export var default_icon_rect:TextureRect

@export var valid_state_icon:TextureRect
@export var valid_state_label:Label
@export var valid_state_button:Button


var parent_sub_menu:BaseCharacterSubMenu
var item_id:String = ""

func _ready() -> void:
	pass

func set_item(actor:BaseActor, holder:BaseItemHolder, item:BaseItem):
	if item == null:
		item_icon_rect.hide()
		if valid_state_icon:
			valid_state_icon.hide()
		default_icon_rect.show()
		item_id = ''
		return
	
	item_id = item.Id
	item_icon_rect.texture = item.get_large_icon()
	item_icon_rect.show()
	default_icon_rect.hide()
	
	if valid_state_icon:
		if valid_state_button and not valid_state_button.mouse_entered.is_connected(show_valid_state_label):
			valid_state_button.mouse_entered.connect(show_valid_state_label)
			valid_state_button.mouse_exited.connect(hide_valid_state_label)
		
		var valid_state = holder.get_valid_state_of_item(item)
		if valid_state == BaseItemHolder.ValidStates.Valid:
			valid_state_icon.hide()
		else:
			valid_state_icon.show()
			
			if valid_state == BaseItemHolder.ValidStates.Unacceptable:
				valid_state_label.text = "Invalid Item Slot"
			else:
				var cant_use_reason = item.get_cant_use_reasons(actor)
				var cant_use_string = ItemHelper.cant_equip_reasons_to_string(cant_use_reason)
				valid_state_label.text = cant_use_string


func show_highlight():
	if highlight_background_rect:
		highlight_background_rect.show()
func hide_highlight():
	if highlight_background_rect:
		highlight_background_rect.hide()

func show_valid_state_label():
	if valid_state_label:
		valid_state_label.show()
func hide_valid_state_label():
	if valid_state_label:
		valid_state_label.hide()
