class_name EquipmentDisplayContainer
extends Control

@export var actor_node:ActorNode
@export var armor_lable:Label
@export var ward_label:Label
@export var phyatk_label:Label
@export var magatk_label:Label
signal equipt_slot_pressed(slot:int)

var _actor:BaseActor
var _display_dir:int = 2

var slot_displays:Array:
	get: return [
		$RightEquipSlots/BookSlotButton,
		$RightEquipSlots/BagSlotButton,
		$LeftEquipSlots/HeadSlotButton,
		$LeftEquipSlots/BodySlotButton,
		$LeftEquipSlots/FeetSlotButton,
		$RightEquipSlots/TrinketSlotButton,
		$LeftEquipSlots/MainHandSlotButton,
		$RightEquipSlots/OffHandSlotButton,
	]

func _ready() -> void:
	for slot:int in range(slot_displays.size()):
		var slot_display:EquipmentDisplaySlotButton = slot_displays[slot]
		slot_display.pressed.connect(_on_slot_pressed.bind(slot))

func set_actor(actor:BaseActor):
	if actor == _actor:
		_sync()
		return
	if _actor:
		if _actor.equipment_changed.is_connected(_sync):
			_actor.equipment_changed.disconnect(_sync)
	_actor = actor
	actor_node.set_actor(actor)
	_actor.equipment_changed.connect(_sync)
	_sync()

func _sync():
	armor_lable.text = str(_actor.equipment.get_total_equipment_armor())
	ward_label.text = str(_actor.equipment.get_total_equipment_ward())
	for index:int in range(slot_displays.size()):
		var slot_display:EquipmentDisplaySlotButton = slot_displays[index]
		var slot_type = _actor.equipment.get_slot_equipment_type(index)
		slot_display.set_slot_type(slot_type)
		if _actor.equipment.has_equipment_in_slot(index):
			var item:BaseEquipmentItem = _actor.equipment.get_equipment_in_slot(index)
			slot_display.set_item(item)
		else:
			slot_display.clear_item()
	magatk_label.text = str(_actor.stats.get_base_magic_attack())
	phyatk_label.text = str(_actor.stats.get_base_phyical_attack())

func _on_slot_pressed(index:int):
	var slot_display:EquipmentDisplaySlotButton = slot_displays[index]
	equipt_slot_pressed.emit(index)

func clear_highlights():
	for slot_display:EquipmentDisplaySlotButton in slot_displays:
		slot_display.highlight(false)

func highlight_slots_of_type(slot_type:String):
	for slot_display:EquipmentDisplaySlotButton in slot_displays:
		slot_display.highlight(slot_display.slot_type == slot_type)

func get_mouse_over_slot_index()->int:
	for index:int in range(slot_displays.size()):
		var slot_display:EquipmentDisplaySlotButton = slot_displays[index]
		if slot_display.is_mouse_over():
			return index
	return -1
