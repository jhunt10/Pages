class_name BagPageControl
extends Control

var event_context = "Bag"
signal item_button_down(context, item_key, index)
signal item_button_up(context, item_key, index)
signal mouse_enter_item(context, item_key, index)
signal mouse_exit_item(context, item_key, index)

@export var name_label:Label
@export var bag_icon:TextureRect
@export var premade_sub_container:SubBagContainer
@export var sub_container:VBoxContainer
@export var scroll_bar:CustScrollBar
var _actor:BaseActor
var _sub_containers:Dictionary

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	premade_sub_container.visible = false
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func set_actor(actor:BaseActor):
	_actor = actor
	_actor.bag_items_changed.connect(build_sub_containers)
	var bags = actor.equipment.get_equipt_items_of_slot_type("Bag")
	if !bags or bags.size() == 0:
		name_label.text = "No Bag!"
		return
	elif bags.size() > 1:
		name_label.text = "2 Bags?"
		return
	var bag:BaseBagEquipment = bags[0]
	name_label.text = bag.details.display_name
	bag_icon.texture = bag.get_large_icon()
	build_sub_containers()

func build_sub_containers():
	for sub in _sub_containers.values():
		sub.queue_free()
	_sub_containers.clear()
	var tags = _actor.items.get_item_ids_per_item_tags()
	for tag in tags.keys():
		var slots = tags[tag]
		var sub = _create_sub_container(tag, slots)
	scroll_bar.calc_bar_size()
	scroll_bar.set_scroll_bar_percent(0)

func _create_sub_container(tag, slots)->SubBagContainer:
	var new_sub:SubBagContainer = premade_sub_container.duplicate()
	new_sub.set_sub_bag_data(tag, slots)
	new_sub.item_button_down.connect(_on_bag_item_button_down)
	new_sub.item_button_up.connect(_on_bag_item_button_up)
	new_sub.mouse_enter_item.connect(_on_mouse_enter_item_button)
	new_sub.mouse_exit_item.connect(_on_mouse_exit_item_button)
	sub_container.add_child(new_sub)
	new_sub.visible = true
	_sub_containers[tag] = new_sub
	return new_sub

func _on_bag_item_button_down(tag, index, offset):
	var items = _actor.items.get_item_ids_per_item_tags().get(tag, [])
	if items.size() > index:
		var item = items[index]
		if item:
			item_button_down.emit(event_context, item, {"Tag":tag, "Index":index, "Offset":Vector2i(32, 32)})
		else:
			item_button_down.emit(event_context, null, {"Tag":tag, "Index":index, "Offset":Vector2i(32, 32)})

func _on_bag_item_button_up(tag, index):
	var items = _actor.items.get_item_ids_per_item_tags().get(tag, [])
	if items.size() > index:
		var item = items[index]
		if item:
			item_button_up.emit(event_context, item, {"Tag":tag, "Index":index})
		else:
			item_button_down.emit(event_context, null, {"Tag":tag, "Index":index})

func _on_mouse_enter_item_button(tag, index):
	var items = _actor.items.get_item_ids_per_item_tags().get(tag, [])
	if items.size() > index:
		var item = items[index]
		if item:
			mouse_enter_item.emit(event_context, item, {"Tag":tag, "Index":index})
		else:
			mouse_enter_item.emit(event_context, null, {"Tag":tag, "Index":index})

func _on_mouse_exit_item_button(tag, index):
	var items = _actor.items.get_item_ids_per_item_tags().get(tag, [])
	if items.size() > index:
		var item = items[index]
		if item:
			mouse_exit_item.emit(event_context, item, {"Tag":tag, "Index":index})
		else:
			mouse_exit_item.emit(event_context, null, {"Tag":tag, "Index":index})

func clear_highlights():
	for sub in _sub_containers.values():
		sub.clear_highlights()

func highlight_slot(index_data):
	var sub = _sub_containers.get(index_data.get("Tag"))
	if sub:
		sub.highlight_slot(index_data.get("Index"))

func remove_item_from_slot(item:BaseItem, index_data:Dictionary):
	_actor.items.remove_item(item.Id)

func try_place_item_in_slot(item:BaseItem, index_data:Dictionary):
	_actor.items.set_item_for_slot(index_data["Tag"], index_data["Index"], item)
	#if item is BasePageItem:
		#var page = item as BasePageItem
		#return _actor.pages.try_place_page_in_slot(page, index_data["Tag"], index_data["Index"])
	#return false

func try_move_item_to_slot(item, from_index_data, to_index_data):
	_actor.items.remove_item(item.Id)
	_actor.items.set_item_for_slot(to_index_data["Tag"], to_index_data["Index"], item)
