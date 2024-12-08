class_name EquipmentPageControl
extends Control

var event_context = "Equipment"
signal item_button_down(context, item_key, index, offset)
signal item_button_up(context, item_key, index)
signal mouse_enter_item(context, item_key, index)
signal mouse_exit_item(context, item_key, index)

@export var name_label:Label
@export var level_label:Label
@export var equipment_slots_container:EquipmentDisplayContainer
@export var stat_box:StatBoxControl
var _actor:BaseActor

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	equipment_slots_container.item_button_down.connect(_on_item_button_down)
	equipment_slots_container.item_button_up.connect(_on_item_button_up)
	equipment_slots_container.mouse_enter_item.connect(_on_mouse_enter_item)
	equipment_slots_container.mouse_exit_item.connect(_on_mouse_exit_item)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func set_actor(actor:BaseActor):
	_actor = actor
	name_label.text = actor.details.display_name
	level_label.text = str(actor.stats.level)
	equipment_slots_container.set_actor(actor)
	stat_box.set_actor(actor)

func clear_highlights():
	equipment_slots_container.clear_highlights()

func highlight_slot(index):
	equipment_slots_container.highlight_slot(index)

func _on_item_button_down(item_key, index, offset):
	item_button_down.emit(event_context, item_key, index, offset)
func _on_item_button_up(item_key, index):
	item_button_up.emit(event_context, item_key, index)
func _on_mouse_enter_item(item_key, index):
	mouse_enter_item.emit(event_context, item_key, index)
func _on_mouse_exit_item(item_key, index):
	mouse_exit_item.emit(event_context, item_key, index)

func can_place_item_in_slot(item:BaseItem, index:int):
	if item is BaseEquipmentItem:
		return _actor.equipment.can_equip_item(item)
		var page = item as BasePageItem
		if _actor.pages.can_set_item_in_slot(page, index, true):
			print("Can Place")
			return true
		else:
			print("Can't Place")
	print("Item Not Page Item")
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
