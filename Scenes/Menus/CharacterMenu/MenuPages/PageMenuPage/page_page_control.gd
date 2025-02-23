class_name PagePageControl
extends Control

var event_context = "Pages"
signal item_button_down(context, item_key, index)
signal item_button_up(context, item_key, index)
signal mouse_enter_item(context, item_key, index)
signal mouse_exit_item(context, item_key, index)

@export var title_label:FitScaleLabel
@export var title_icon:TextureRect
@export var title_page_button:PageSlotButton

@export var premade_page_set:PageSlotSetContainer
@export var sets_container:VBoxContainer
@export var premade_page_button:PageSlotButton
#@export var premade_sub_container:SubBookContainer
#@export var sub_container:FlowContainer
@export var slot_width:int 
@export var scroll_dots:HTabsControls

#var _current_que_item_id
var _actor:BaseActor
var _sub_containers:Dictionary = {}
var sub_book_pages:Array = []
var max_hight = 278
var _buttons:Array = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#premade_sub_container.visible = false
	premade_page_set.hide()
	title_label._size_dirty = true
	scroll_dots.selected_index_changed.connect(show_page)
	scroll_dots.selected_index = 0
	
	title_page_button.button.button_down.connect(_on_item_button_down.bind(0))
	title_page_button.button.button_up.connect(_on_item_button_up.bind(0))
	title_page_button.button.mouse_entered.connect(_on_mouse_enter_item_button.bind(0))
	title_page_button.button.mouse_exited.connect(_on_mouse_exit_item_button.bind(0))
	
	self.visibility_changed.connect(on_show)
	pass # Replace with function body.

func on_show():
	title_label._size_dirty = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func set_actor(actor:BaseActor):
	if _actor and _actor != actor:
		_actor.equipment_changed.disconnect(actor_equipment_changed)
		_actor.pages.items_changed.disconnect(build_sub_containers)
	if actor != _actor:
		actor.equipment_changed.connect(actor_equipment_changed)
		actor.pages.items_changed.connect(build_sub_containers)
	_actor = actor
	actor_equipment_changed()

func actor_equipment_changed():
	#var ques = _actor.equipment.get_equipt_items_of_slot_type("Que")
	#if !ques or ques.size() == 0:
		#tit.text = "No Book!"
		#book_icon.texture = null
		#_current_que_item_id = null
		#return
	#elif ques.size() > 1:
		#name_label.text = "2 Books?"
		#book_icon.texture = null
		#_current_que_item_id = null
		#return
	#var que:BaseQueEquipment = ques[0]
	#if que.Id == _current_que_item_id:
		#return
	#_current_que_item_id = que.Id
	#name_label.text = que.details.display_name
	#book_icon.texture = que.get_large_icon()
	build_sub_containers()

func build_sub_containers():
	for container in _sub_containers.values():
		container.queue_free()
	_sub_containers.clear()
	_buttons.clear()
	
	var title_page:BasePageItem = _actor.pages.get_item_in_slot(0)
	if title_page:
		title_label.text = title_page.details.display_name
		title_page_button.set_key(_actor, title_page.Id)
	_buttons.append(title_page_button)
	
	var slot_set:PageSlotSetContainer = null
	var last_display_name = ''
	var raw_index = 1
	for slot_set_data in _actor.pages.slot_sets_data:
		var slot_key = slot_set_data['Key']
		if slot_key == "TitlePage":
			continue
		var display_name = slot_set_data['DisplayName']
		if slot_set == null or last_display_name != display_name:
			slot_set = premade_page_set.duplicate()
			slot_set.title_label.text = slot_set_data['DisplayName']
			if slot_set_data['DisplayName'] == '':
				slot_set.title_label.hide()
			slot_set.buttons_container.get_child(0).queue_free()
			self.sets_container.add_child(slot_set)
			slot_set.show()
		_sub_containers[slot_key] = slot_set
		for index in range(slot_set_data['Count']):
			var new_button:PageSlotButton = premade_page_button.duplicate()
			new_button.name = "PageSlotButton"+str(raw_index)
			new_button.set_key(_actor, _actor.pages.get_item_id_in_slot(raw_index))
			new_button.button.button_down.connect(_on_item_button_down.bind(raw_index))
			new_button.button.button_up.connect(_on_item_button_up.bind(raw_index))
			new_button.button.mouse_entered.connect(_on_mouse_enter_item_button.bind(raw_index))
			new_button.button.mouse_exited.connect(_on_mouse_exit_item_button.bind(raw_index))
			slot_set.buttons_container.add_child(new_button)
			new_button.is_clipped = slot_key == "Passive"
			new_button.show()
			_buttons.append(new_button)
			raw_index += 1
#func build_sub_containers():
	#for page in sub_book_pages:
		#for container in page:
			#for child in container.get_children():
				#child.queue_free()
			#container.queue_free()
	#sub_book_pages.clear()
	#_sub_containers.clear()
	#
	#var title_page:BasePageItem = _actor.pages.get_item_in_slot(0)
	#if title_page:
		#title_label.text = title_page.details.display_name
		#title_icon.texture = title_page.get_large_icon()
	#
	#var current_hight = 0
	#var current_width = 0
	#var current_page_index = 0
	#sub_book_pages.clear()
	#sub_book_pages.append([])
	#var last_title = ""
	#var sub = null
	#for slot_set_data in _actor.pages.slot_sets_data:
		#var slot_key = slot_set_data['Key']
		#if slot_key == "TitlePage":
			#continue
		#var slot_count = slot_set_data['Count']
		#if !sub or slot_set_data['DisplayName'] != last_title:
			#sub = _create_sub_container(slot_set_data)
		#
		#var estimated_hight = sub.estimate_hight()
		#
		#if current_width > 0 and current_width + slot_count <= 4:
			#current_width += slot_count
			#sub_book_pages[current_page_index].append(sub)
			#continue
			#
		#if current_hight + estimated_hight > max_hight:
			#sub_book_pages.append([])
			#current_page_index += 1
			#current_width = 0
			#current_hight = estimated_hight
		#else:
			#current_hight += estimated_hight
			#if slot_count < 4:
				#current_width += slot_count
			#else:
				#current_width = 0
		#sub_book_pages[current_page_index].append(sub)
	#show_page(scroll_dots.selected_index)
	#var page_count = sub_book_pages.size()
	#scroll_dots.dot_count = sub_book_pages.size()
	#if page_count < 2:
		#scroll_dots.hide()
	#else:
		#scroll_dots.show()

func show_page(index):
	
	for sub_index in range(sub_book_pages.size()):
		var subs = sub_book_pages[sub_index]
		for sub in subs:
			sub.visible = sub_index == index
		
#func _create_sub_container(slot_set_data:Dictionary)->SubBookContainer:
	#var slot_key = slot_set_data['Key']
	#var new_sub:SubBookContainer = premade_sub_container.duplicate()
	#new_sub.set_slot_set_data(_actor, _actor.pages, slot_set_data)
	#sub_container.add_child(new_sub)
	#_sub_containers[slot_key] = new_sub
	#new_sub.item_button_down.connect(_on_item_button_down)
	#new_sub.item_button_up.connect(_on_item_button_up)
	#new_sub.mouse_enter_item.connect(_on_mouse_enter_item_button)
	#new_sub.mouse_exit_item.connect(_on_mouse_exit_item_button)
	#new_sub.name = "SubContainer_" + slot_key
	#return new_sub

#func create_page_slot_set(slot_set_data:Dictionary)->PageSlotSetContainer:
	#var slot_key = slot_set_data['Key'] SubBookContainer
	#var new_set:PageSlotSetContainer = premade_page_set.duplicate()
	#_sub_containers[slot_key] = new_set
	#return new_set

func clear_highlights():
	for button in _buttons:
		button.hide_highlight()

func highlight_slot(index:int):
	_buttons[index].show_highlight()
	#var tag = _actor.pages.get_slot_set_key_for_index(index)
	#var sub = _sub_containers.get(tag)
	#if sub:
		#sub.highlight_slot(index)

func _on_item_button_down(index:int):
	var item_id = _actor.pages.get_item_id_in_slot(index)
	var offset = _buttons[index].get_local_mouse_position()
	item_button_down.emit(event_context, item_id, index, offset)

func _on_item_button_up(index:int):
	var item_id = _actor.pages.get_item_id_in_slot(index)
	item_button_up.emit(event_context, item_id, index)

func _on_mouse_enter_item_button(index:int):
	var item_id = _actor.pages.get_item_id_in_slot(index)
	mouse_enter_item.emit(event_context, item_id, index)

func _on_mouse_exit_item_button(index:int):
	var item_id = _actor.pages.get_item_id_in_slot(index)
	mouse_exit_item.emit(event_context, item_id, index)


func can_place_item_in_slot(item:BaseItem, index:int):
	if item is BasePageItem:
		var page = item as BasePageItem
		if _actor.pages.can_set_item_in_slot(page, index, true):
			print("Can Place")
			return true
		else:
			print("Can't Place")
	print("Item Not Page Item")
	return false

func remove_item_from_slot(item:BaseItem, index:int):
	ItemHelper.try_transfer_item_from_holder_to_inventory(item, _actor.pages)

func try_place_item_in_slot(item:BaseItem, index:int):
	var res = ItemHelper.try_transfer_item_from_inventory_to_holder(item, _actor.pages, index, true)
	if res == '':
		return true
	return false

func try_move_item_to_slot(item:BaseItem, from_index:int, to_index:int):
	ItemHelper.swap_item_holder_slots(_actor.items, from_index, to_index)
