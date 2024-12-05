class_name PagePageControl
extends Control

var event_context = "Pages"
signal item_button_down(context, item_key, index)
signal item_button_up(context, item_key, index)
signal mouse_enter_item(context, item_key, index)
signal mouse_exit_item(context, item_key, index)

@export var name_label:Label
@export var book_icon:TextureRect
@export var premade_sub_container:SubBookContainer
@export var sub_container:FlowContainer
@export var slot_width:int 
@export var scroll_dots:HTabsControls

var _actor:BaseActor
var _sub_containers:Dictionary = {}
var sub_book_pages:Array = []
var max_hight = 278

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	premade_sub_container.visible = false
	scroll_dots.selected_index_changed.connect(show_page)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func set_actor(actor:BaseActor):
	_actor = actor
	var ques = _actor.equipment.get_equipt_items_of_slot_type("Que")
	if !ques or ques.size() == 0:
		name_label.text = "No Book!"
		return
	elif ques.size() > 1:
		name_label.text = "2 Books?"
		return
	var que:BaseQueEquipment = ques[0]
	name_label.text = que.details.display_name
	book_icon.texture = que.get_large_icon()
	actor.pages.pages_changed.connect(build_sub_container)
	build_sub_container()

func build_sub_container():
	for page in sub_book_pages:
		for container in page:
			for child in container.get_children():
				child.queue_free()
			container.queue_free()
	sub_book_pages.clear()
	_sub_containers.clear()
	
	var current_hight = 0
	var current_width = 0
	var current_page_index = 0
	sub_book_pages.clear()
	sub_book_pages.append([])
	
	var tags = _actor.pages._page_tagged_slots
	for tag in tags.keys():
		var slots = tags[tag]
		var sub = _create_sub_container(tag, slots)
		
		var estimated_hight = sub.estimate_hight()
		
		if current_width > 0 and current_width + slots.size() <= 4:
			current_width += slots.size()
			sub_book_pages[current_page_index].append(sub)
			continue
			
		if current_hight + estimated_hight > max_hight:
			sub_book_pages.append([])
			current_page_index += 1
			current_width = 0
			current_hight = estimated_hight
		else:
			current_hight += estimated_hight
			if slots.size() < 4:
				current_width += slots.size()
		sub_book_pages[current_page_index].append(sub)
	show_page(0)
	var page_count = sub_book_pages.size()
	scroll_dots.dot_count = sub_book_pages.size()
	if page_count < 2:
		scroll_dots.hide()
	else:
		scroll_dots.show()

func show_page(index):
	for sub_index in range(sub_book_pages.size()):
		var subs = sub_book_pages[sub_index]
		for sub in subs:
			sub.visible = sub_index == index
			print("Setting Page %s Sub Hidde: %s | %s " % [sub_index, sub, sub.visible])
		
func _create_sub_container(tag, slots)->SubBookContainer:
	var new_sub:SubBookContainer = premade_sub_container.duplicate()
	new_sub.set_sub_book_data(tag, slots)
	sub_container.add_child(new_sub)
	_sub_containers[tag] = new_sub
	new_sub.page_item_button_down.connect(_on_page_item_button_down)
	new_sub.page_item_button_up.connect(_on_page_item_button_up)
	new_sub.mouse_enter_item.connect(_on_mouse_enter_item_button)
	new_sub.mouse_exit_item.connect(_on_mouse_exit_item_button)
	return new_sub

func clear_highlights():
	for sub in _sub_containers.values():
		sub.clear_highlights()

func highlight_slot(index_data):
	var sub = _sub_containers.get(index_data.get("Tag"))
	if sub:
		sub.highlight_slot(index_data.get("Index"))


func _on_page_item_button_down(tag, index, offset):
	var pages = _actor.pages.get_pages_per_page_tags().get(tag, [])
	if pages.size() > index:
		var page = pages[index]
		if page:
			item_button_down.emit(event_context, page, {"Tag":tag, "Index":index, "Offset": offset})
		else:
			item_button_down.emit(event_context, null, {"Tag":tag, "Index":index, "Offset": offset})

func _on_page_item_button_up(tag, index):
	var pages = _actor.pages.get_pages_per_page_tags().get(tag, [])
	if pages.size() > index:
		var page = pages[index]
		if page:
			item_button_up.emit(event_context, page, {"Tag":tag, "Index":index})
		else:
			item_button_down.emit(event_context, null, {"Tag":tag, "Index":index})

func _on_mouse_enter_item_button(tag, index):
	var items = _actor.items.get_item_ids_per_item_tags().get(tag, [])
	if items.size() > index:
		var item = items[index]
		if item:
			mouse_enter_item.emit(event_context, item, {"Tag":tag, "Index":index})
			return
	mouse_enter_item.emit(event_context, null, {"Tag":tag, "Index":index})

func _on_mouse_exit_item_button(tag, index):
	var items = _actor.items.get_item_ids_per_item_tags().get(tag, [])
	if items.size() > index:
		var item = items[index]
		if item:
			mouse_exit_item.emit(event_context, item, {"Tag":tag, "Index":index})
			return
	mouse_exit_item.emit(event_context, null, {"Tag":tag, "Index":index})
			

func can_place_item_in_slot(item:BaseItem, index_data:Dictionary):
	print("Try set item %s to %s" % [item, index_data])
	if item is BasePageItem:
		var page = item as BasePageItem
		if _actor.pages.can_place_page_in_slot(page, index_data["Tag"], index_data["Index"]):
			print("Can Place")
			return true
		else:
			print("Can't Place")
	print("Item Not Page Item")
	return false

func remove_item_from_slot(item:BaseItem, index_data:Dictionary):
	if item is BasePageItem:
		var page = item as BasePageItem
		_actor.pages.remove_page(page.Id)

func try_place_item_in_slot(item:BaseItem, index_data:Dictionary):
	if item is BasePageItem:
		var page = item as BasePageItem
		return _actor.pages.try_place_page_in_slot(page, index_data["Tag"], index_data["Index"])
	return false

func try_move_item_to_slot(item, from_index_data, to_index_data):
	if item is BasePageItem:
		var page = item as BasePageItem
		_actor.pages.remove_page(page.Id)
		if not _actor.pages.try_place_page_in_slot(page, to_index_data["Tag"], to_index_data["Index"]):
			_actor.pages.try_place_page_in_slot(page, from_index_data["Tag"], from_index_data["Index"])
			return false
	return false
