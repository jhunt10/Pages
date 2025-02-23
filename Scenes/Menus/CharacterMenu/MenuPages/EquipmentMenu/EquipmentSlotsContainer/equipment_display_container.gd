class_name EquipmentDisplayContainer
extends Control

signal item_button_down(item_id, index, offset)
signal item_button_up(item_id, index)
signal mouse_enter_item(item_id, index)
signal mouse_exit_item(item_id, index)

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
		slot_display.button_down.connect(_on_item_button_down.bind(slot))
		slot_display.button_up.connect(_on_item_button_up.bind(slot))
		slot_display.mouse_entered.connect(_on_mouse_enter_item.bind(slot))
		slot_display.mouse_exited.connect(_on_mouse_exit_item.bind(slot))
	self.visibility_changed.connect(_sync)

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
	armor_lable.text = str(_actor.stats.get_stat("Armor", 0))
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
	magatk_label.text = str(_actor.stats.get_stat(StatHelper.MagAttack))
	phyatk_label.text = str(_actor.stats.get_stat(StatHelper.PhyAttack))
	actor_node.set_facing_dir(MapPos.Directions.South)

func clear_highlights():
	for slot_display:EquipmentDisplaySlotButton in slot_displays:
		slot_display.highlight(false)

func highlight_slot(index:int):
	if index >= 0 and index < slot_displays.size():
		slot_displays[index].highlight(true)

func highlight_slots_of_type(slot_type:String):
	for slot_display:EquipmentDisplaySlotButton in slot_displays:
		slot_display.highlight(slot_display.slot_type == slot_type)

func get_mouse_over_slot_index()->int:
	for index:int in range(slot_displays.size()):
		var slot_display:EquipmentDisplaySlotButton = slot_displays[index]
		if slot_display.is_mouse_over():
			return index
	return -1

func _on_item_button_down(index):
	var button = slot_displays[index]
	var offset = button.get_local_mouse_position()
	var item = _actor.equipment.get_equipment_in_slot(index)
	if item: item_button_down.emit(item.Id, index, offset)
	else: item_button_down.emit(null, index, offset)
func _on_item_button_up(index):
	var item = _actor.equipment.get_equipment_in_slot(index)
	if item: item_button_up.emit(item.Id, index)
	else: item_button_up.emit(null, index)
func _on_mouse_enter_item(index):
	var item = _actor.equipment.get_equipment_in_slot(index)
	if item: mouse_enter_item.emit(item.Id, index)
	else: mouse_enter_item.emit(null, index)
func _on_mouse_exit_item(index):
	var item = _actor.equipment.get_equipment_in_slot(index)
	if item: mouse_exit_item.emit(item.Id, index)
	else: mouse_exit_item.emit(null, index)
