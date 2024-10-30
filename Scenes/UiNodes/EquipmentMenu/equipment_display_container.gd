@tool
class_name EquipmentDisplayContainer
extends BackPatchContainer

@export var portait_texture_rect:TextureRect
@export var armor_lable:Label
@export var ward_label:Label
@export var phyatk_label:Label
@export var magatk_label:Label
@export var mass_label:Label
@export var speed_label:Label
@export var page_count_label:Label
@export var que_count_label:Label

signal equipt_slot_pressed(slot:BaseEquipmentItem.EquipmentSlots)

var slots_to_display:Dictionary:
	get: return {
		BaseEquipmentItem.EquipmentSlots.Head: $InnerContainer/LeftEquipSlots/HeadSlotButton,
		BaseEquipmentItem.EquipmentSlots.Body: $InnerContainer/LeftEquipSlots/BodySlotButton,
		BaseEquipmentItem.EquipmentSlots.Feet: $InnerContainer/LeftEquipSlots/FeetSlotButton,
		BaseEquipmentItem.EquipmentSlots.Que: $InnerContainer/RightEquipSlots/QueSlotButton,
		BaseEquipmentItem.EquipmentSlots.Bag: $InnerContainer/RightEquipSlots/BagSlotButton,
		BaseEquipmentItem.EquipmentSlots.Trinket: $InnerContainer/RightEquipSlots/TrinketSlotButton,
		BaseEquipmentItem.EquipmentSlots.Weapon: $InnerContainer/LeftEquipSlots/MainHandSlotButton,
		BaseEquipmentItem.EquipmentSlots.Shield: $InnerContainer/RightEquipSlots/OffHandSlotButton,
	}

func _ready() -> void:
	for slot in slots_to_display:
		var slot_display:EquipmentDisplaySlotButton = slots_to_display[slot]
		slot_display.pressed.connect(_on_slot_pressed.bind(slot))

func set_actor(actor:BaseActor):
	portait_texture_rect.texture = actor.get_default_sprite()
	armor_lable.text = str(actor.equipment.get_total_equipment_armor())
	ward_label.text = str(actor.equipment.get_total_equipment_ward())
	for slot in BaseEquipmentItem.EquipmentSlots.values():
		if actor.equipment.has_item_in_slot(slot):
			slots_to_display[slot].set_item(actor.equipment.get_item_in_slot(slot))
		else:
			slots_to_display[slot].clear_item()
	mass_label.text = str(actor.stats.get_stat("Mass"))
	speed_label.text = str(actor.stats.get_stat("Speed"))
	var que:BaseQueEquipment = actor.equipment.get_item_in_slot(BaseEquipmentItem.EquipmentSlots.Que)
	if que:
		page_count_label.text = str(que.get_max_page_count())
		page_count_label.self_modulate = Color.WHITE
		que_count_label.text = str(que.get_max_que_size())
		que_count_label.self_modulate = Color.WHITE
	else:
		page_count_label.text = "!!!"
		page_count_label.self_modulate = Color.RED
		que_count_label.text = "!!!"
		que_count_label.self_modulate = Color.RED
		

func _on_slot_pressed(slot:BaseEquipmentItem.EquipmentSlots):
	equipt_slot_pressed.emit(slot)

func clear_highlights():
	for slot_display:EquipmentDisplaySlotButton in slots_to_display.values():
		slot_display.highlight(false)

func highlight_slot(slot:BaseEquipmentItem.EquipmentSlots):
	var slot_display:EquipmentDisplaySlotButton = slots_to_display.get(slot, null)
	if slots_to_display:
		slot_display.highlight(true)

func get_mouse_over_slot():
	for slot:BaseEquipmentItem.EquipmentSlots in slots_to_display.keys():
		var slot_display:EquipmentDisplaySlotButton = slots_to_display[slot]
		if slot_display.is_mouse_over():
			return slot
	return null
