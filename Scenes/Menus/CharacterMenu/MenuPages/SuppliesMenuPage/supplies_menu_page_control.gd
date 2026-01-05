class_name BagPageControl
extends BaseCharacterSubMenu

@export var name_label:Label
@export var bag_icon:TextureRect
@export var premade_sub_container:SubBagContainer
@export var sub_container:VBoxContainer
@export var scroll_bar:CustScrollBar
var _current_bag_item_id
var _sub_containers:Dictionary

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	premade_sub_container.visible = false
	pass # Replace with function body.

func get_item_holder()->BaseItemHolder:
	if parent_menu and parent_menu._actor:
		return _actor.items
	return null

func sync():
	super()
	if !_actor:
		return
	var bag:BaseBagEquipment = _actor.equipment.get_bag_equipment()
	if bag:
		if bag.Id == _current_bag_item_id:
			return
			_current_bag_item_id = bag.Id
		name_label.text = bag.get_display_name()
		bag_icon.texture = bag.get_large_icon()
	else:
		_current_bag_item_id = null
	


func build_item_slots():
	item_slot_buttons.clear()
	for sub in _sub_containers.values():
		sub.queue_free()
	_sub_containers.clear()
	var item_set_data = _actor.items.slot_sets_data
	for slot_set_data in item_set_data:
		var sub = _create_sub_container(slot_set_data)
		for button in sub._buttons.values():
			item_slot_buttons.append(button)

func _create_sub_container(slot_set_data)->SubBagContainer:
	var new_sub:SubBagContainer = premade_sub_container.duplicate()
	new_sub.set_sub_bag_data(_actor.items, slot_set_data)
	new_sub.item_button_down.connect(_on_item_button_down)
	new_sub.item_button_up.connect(_on_item_button_up)
	new_sub.mouse_enter_item.connect(_on_mouse_enter_item_button)
	new_sub.mouse_exit_item.connect(_on_mouse_exit_item_button)
	sub_container.add_child(new_sub)
	new_sub.visible = true
	_sub_containers[slot_set_data['Key']] = new_sub
	return new_sub

func remove_item_from_slot(item:BaseItem, _index:int):
	ItemHelper.try_transfer_item_from_holder_to_inventory(item, _actor.items)

func try_move_item_to_slot(_item:BaseItem, from_index:int, to_index:int):
	ItemHelper.swap_item_holder_slots(_actor.items, from_index, to_index)

func can_place_item_in_slot(item:BaseItem, index:int):
	if item is BasePageItem:
		var page = item as BasePageItem
		if _actor.items.can_set_item_in_slot(page, index, true):
			print("Can Place")
			return true
		else:
			print("Can't Place")
	print("Item Not Page Item")
	return false

func try_place_item_in_slot(item:BaseItem, index:int):
	var res = ItemHelper.try_transfer_item_from_inventory_to_holder(item, _actor.items, index, true)
	if res == '':
		return true
	return false
