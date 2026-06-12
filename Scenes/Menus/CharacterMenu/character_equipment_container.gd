class_name CharacterMenu_EquipmentControl
extends BaseCharacterSubMenu

@export var title_button:EquipmentSlotButton
@export var book_button:EquipmentSlotButton
@export var bag_button:EquipmentSlotButton
@export var trinket_button:EquipmentSlotButton
@export var main_hand_button:EquipmentSlotButton
@export var off_hand_button:EquipmentSlotButton

func get_item_holder()->BaseItemHolder:
	if _actor:
		return _actor.equipment
	return null

func _ready() -> void:
	pass
	#title_button.button_down.connect(_on_slot_down.bind(0))
	#book_button.button_down.connect(_on_slot_down.bind(1))
	#bag_button.button_down.connect(_on_slot_down.bind(2))
	#trinket_button.button_down.connect(_on_slot_down.bind(3))
	#main_hand_button.button_down.connect(_on_slot_down.bind(4))
	#off_hand_button.button_down.connect(_on_slot_down.bind(5))


func build_item_slots():
	item_slot_buttons = [book_button, bag_button, main_hand_button, off_hand_button, trinket_button]

func sync():
	item_slot_buttons = [book_button, bag_button, main_hand_button, off_hand_button, trinket_button]
	super()
	var title_page = _actor.get_title_page()
	title_button.set_item(_actor, null, title_page)
	if _actor.equipment.is_two_handing():
		var primary = _actor.equipment.get_primary_weapon()
		if primary:
			off_hand_button.set_item(_actor, _actor.equipment, primary)
	#var page_book = _actor.equipment.get_que_equipment()
	#book_button.set_item(_actor, _actor.equipment, page_book)
	#var bag = _actor.equipment.get_bag_equipment()
	#bag_button.set_item(_actor, _actor.equipment, bag)
	#var main_hand = _actor.equipment.get_primary_weapon()
	#main_hand_button.set_item(_actor, _actor.equipment, main_hand)
	#var off_hand = _actor.equipment.get_offhand_weapon()
	#off_hand_button.set_item(_actor, _actor.equipment, off_hand)

#func _on_slot_down(index:int):
	#var pressed_item:BaseItem = null
	#match index:
		#0: pressed_item = _actor.get_title_page()
		#1: pressed_item = _actor.equipment.get_que_equipment()
		#2: pressed_item = _actor.equipment.get_bag_equipment()
		## 3: Trinket
		#4: pressed_item = _actor.equipment.get_primary_weapon()
		#5: pressed_item = _actor.equipment.get_offhand_weapon()
	#if pressed_item:
		#item_pressed.emit(pressed_item)


func can_place_item_in_slot(item:BaseItem, index:int):
	if item is BaseEquipmentItem:
		return _actor.equipment.can_set_item_in_slot(item, index)
	return false
func remove_item_from_slot(item:BaseItem, index:int):
	if index == 0:
		#play_pagebook_warning_animation()
		return
	ItemHelper.try_transfer_item_from_holder_to_inventory(item, _actor.equipment)

func try_place_item_in_slot(item:BaseItem, index:int):
	var res = ItemHelper.try_transfer_item_from_inventory_to_holder(item, _actor.equipment, index, true)
	if res == '':
		return true
	return false

func try_move_item_to_slot(_item:BaseItem, from_index:int, to_index:int):
	ItemHelper.swap_item_holder_slots(_actor.equipment, from_index, to_index)
