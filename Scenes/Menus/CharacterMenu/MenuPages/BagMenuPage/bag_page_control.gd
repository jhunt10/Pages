class_name BagPageControl
extends Control

var event_context = "Bag"
signal item_button_down(context, item_key, index, offset)
signal item_button_up(context, item_key, index)
signal mouse_enter_item(context, item_key, index)
signal mouse_exit_item(context, item_key, index)

@export var name_label:Label
@export var bag_icon:TextureRect
@export var premade_sub_container:SubBagContainer
@export var sub_container:VBoxContainer
@export var scroll_bar:CustScrollBar
var _current_bag_item_id
var _actor:BaseActor
var _sub_containers:Dictionary

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	premade_sub_container.visible = false
	self.visibility_changed.connect(_sync)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func set_actor(actor:BaseActor):
	if _actor and _actor != actor:
		_actor.items.items_changed.disconnect(_sync)
		_actor.equipment_changed.disconnect(_sync)
	if actor != _actor:
		actor.items.items_changed.connect(_sync)
		actor.equipment_changed.connect(_sync)
	_actor = actor
	_sync()

func _sync():
	if not self.is_visible_in_tree():
		return
	if not _actor:
		return
	#var bag = _actor.equipment.get_equipt_items_of_slot_type("Bag")
	#if !ques or ques.size() == 0:
		#name_label.text = "No Bag!"
		#bag_icon.texture = null
		#_current_bag_item_id = null
		#return
	#elif ques.size() > 1:
		#name_label.text = "2 Bags?"
		#bag_icon.texture = null
		#_current_bag_item_id = null
		#return
	var bag:BaseBagEquipment = _actor.equipment.get_bag_equipment()
	if bag:
		if bag.Id == _current_bag_item_id:
			return
			_current_bag_item_id = bag.Id
		name_label.text = bag.get_display_name()
		bag_icon.texture = bag.get_large_icon()
	else:
		_current_bag_item_id = null
	build_sub_containers()
	


func build_sub_containers():
	for sub in _sub_containers.values():
		sub.queue_free()
	_sub_containers.clear()
	var item_set_data = _actor.items.slot_sets_data
	for slot_set_data in item_set_data:
		var sub = _create_sub_container(slot_set_data)
	#scroll_bar.calc_bar_size()
	#scroll_bar.set_scroll_bar_percent(0)

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

func _on_item_button_down(index:int, offset:Vector2):
	var item_id = _actor.items.get_item_id_in_slot(index)
	item_button_down.emit(event_context, item_id, index, Vector2i(32, 32))

func _on_item_button_up(index:int):
	var item_id = _actor.items.get_item_id_in_slot(index)
	item_button_up.emit(event_context, item_id, index)

func _on_mouse_enter_item_button(index:int):
	var item_id = _actor.items.get_item_id_in_slot(index)
	mouse_enter_item.emit(event_context, item_id, index)

func _on_mouse_exit_item_button(index:int):
	var item_id = _actor.items.get_item_id_in_slot(index)
	mouse_exit_item.emit(event_context, item_id, index)

func clear_highlights():
	for sub in _sub_containers.values():
		sub.clear_highlights()

func highlight_slot(index:int):
	var slot_set_key = _actor.items.get_slot_set_key_for_index(index)
	var sub = _sub_containers.get(slot_set_key)
	if sub:
		sub.highlight_slot(index)

func remove_item_from_slot(item:BaseItem, index:int):
	ItemHelper.try_transfer_item_from_holder_to_inventory(item, _actor.items)

func try_move_item_to_slot(item:BaseItem, from_index:int, to_index:int):
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
