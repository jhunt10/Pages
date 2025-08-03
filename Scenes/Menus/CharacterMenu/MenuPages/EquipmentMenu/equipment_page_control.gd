class_name EquipmentPageControl
extends BaseCharacterSubMenu

@export var name_label:Label
@export var level_label:Label
@export var actor_node:BaseActorNode
@export var stat_box:StatBoxControl
@export var animation_player:AnimationPlayer
@export var exp_bar:ExpBarControl
@export var tags_box:RichTextLabel

@export var phy_attack_label:StatLabelContainer
@export var mag_attack_label:StatLabelContainer
@export var armor_label:StatLabelContainer
@export var ward_label:StatLabelContainer

var slot_button_mapping:Dictionary:
	get: return {
		"PageBook:0": $EquipmentSlotsControl/RightEquipSlots/PageBook_EquipmentSlotButton,
		"SupplyBag:0": $EquipmentSlotsControl/RightEquipSlots/SupplyBag_EquipmentSlotButton,
		"Hands:0": $EquipmentSlotsControl/LeftEquipSlots/Hand_EquipmentSlotButton,
		"Hands:1": $EquipmentSlotsControl/RightEquipSlots/Hand2_EquipmentSlotButton,
		"Apparel:Head:0": $EquipmentSlotsControl/LeftEquipSlots/Head_EquipmentSlotButton,
		"Apparel:Body:0": $EquipmentSlotsControl/LeftEquipSlots/Body_EquipmentSlotButton,
		"Apparel:Feet:0": $EquipmentSlotsControl/LeftEquipSlots/Legs_EquipmentSlotButton,
		"Trinket:0": $EquipmentSlotsControl/RightEquipSlots/Trinket_EquipmentSlotButton,
		"false_slot": $EquipmentSlotsControl/RightEquipSlots/FalseSlot_EquipmentSlotButton,
	}

var off_hand_index:int=-1

#func set_actor(actor:BaseActor):
	#if _actor and actor != _actor:
		#_actor.equipment_changed.disconnect(set_tags)
	#_actor = actor
	#name_label.text = actor.get_name()
	#level_label.text = str(actor.stats.get_stat(StatHelper.Level, 0))
	#equipment_slots_container.set_actor(actor)
	#stat_box.set_actor(actor)
	#exp_bar.set_actor(actor)
	#_actor.equipment_changed.connect(set_tags)
	#set_tags()

func get_item_holder()->BaseItemHolder:
	if _actor:
		return _actor.equipment
	return null

func build_item_slots():
	item_slot_buttons.clear()
	var equipment_holder:EquipmentHolder = get_item_holder()
	if !equipment_holder:
		return
	off_hand_index = -1
	for index in range(equipment_holder.get_max_item_count()):
		var slot_set_key = equipment_holder.get_slot_set_key_for_index(index)
		var slot_set_sub_index = equipment_holder.get_slot_sub_index_for_index(index)
		if slot_set_key == "Hands" and slot_set_sub_index == 1:
			off_hand_index = index
		var button_key = slot_set_key + ":" + str(slot_set_sub_index)
		if not slot_button_mapping.keys().has(button_key):
			printerr("EquipmentMenuPage: Unknown Slot Key: '%s'." % [button_key])
			button_key = "false_slot"
		var slot_button:EquipmentSlotButton = slot_button_mapping[button_key]
		slot_button.enable_slot()
		slot_button.set_slot_set_key(slot_set_key, off_hand_index == index)
		item_slot_buttons.append(slot_button)
	
	# Disable slots that weren't found
	for key in slot_button_mapping.keys():
		if key == "false_slot":
			continue
		var slot_button:EquipmentSlotButton = slot_button_mapping[key]
		if not item_slot_buttons.has(slot_button):
			slot_button.disable_slot()

func sync():
	super()
	if _actor:
		actor_node.set_actor(_actor)
		name_label.text = _actor.get_name()
		level_label.text = str(_actor.stats.get_stat(StatHelper.Level, 0))
		#stat_box.set_actor(_actor)
		exp_bar.set_actor(_actor)
		phy_attack_label.set_stat_values(_actor)
		mag_attack_label.set_stat_values(_actor)
		armor_label.set_stat_values(_actor)
		ward_label.set_stat_values(_actor)
		tags_box.text = ", ".join(_actor.get_tags())

#
#func set_tags():
	#tags_box.text = ", ".join(_actor.get_tags())
	
#
#func clear_highlights():
	#equipment_slots_container.clear_highlights()
#
#func highlight_slot(index):
	#equipment_slots_container.highlight_slot(index)


func can_place_item_in_slot(item:BaseItem, index:int):
	if item is BaseEquipmentItem:
		return _actor.equipment.can_set_item_in_slot(item, index)
	return false
func remove_item_from_slot(item:BaseItem, index:int):
	ItemHelper.try_transfer_item_from_holder_to_inventory(item, _actor.equipment)

func try_place_item_in_slot(item:BaseItem, index:int):
	var res = ItemHelper.try_transfer_item_from_inventory_to_holder(item, _actor.equipment, index, true)
	if res == '':
		return true
	return false

func try_move_item_to_slot(item:BaseItem, from_index:int, to_index:int):
	ItemHelper.swap_item_holder_slots(_actor.equipment, from_index, to_index)

func play_pagebook_warning_animation():
	animation_player.play("pagebook_warning")
