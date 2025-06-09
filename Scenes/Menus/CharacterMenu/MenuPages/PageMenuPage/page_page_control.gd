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

@export var action_input_preview:ActionInputPreviewContainer
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

var _current_dot_index:int = 0
var _dot_index_to_set_containers:Dictionary = {}

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
	action_input_preview.set_actor(_actor)
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
	#name_label.text = que.get_display_name()
	#book_icon.texture = que.get_large_icon()
	build_sub_containers()

func build_sub_containers():
	for container in _sub_containers.values():
		container.queue_free()
	_sub_containers.clear()
	_buttons.clear()
	
	var title_page:BasePageItem = _actor.pages.get_item_in_slot(0)
	if title_page:
		title_label.text = title_page.get_display_name()
		title_page_button.set_key(_actor, title_page.Id)
	_buttons.append(title_page_button)
	
	#premade_page_set.hide()
	var slot_sets_container_hight = 241#sets_container.size.y
	
	var slot_set:PageSlotSetContainer = null
	var last_display_name = ''
	var raw_index = 1
	var slot_set_datas = _actor.pages.slot_sets_data
	var has_extra_slots = slot_set_datas.size() > 3
	for slot_set_data in _actor.pages.slot_sets_data:
		var slot_key = slot_set_data['Key']
		if slot_key == "TitlePage":
			continue
		var display_name = slot_set_data['DisplayName']
		# Skip labels if it's just bases and no extra sets yet
		if has_extra_slots:
			if slot_key == 'BaseActions' or slot_key == "BasePassives":
				if last_display_name == '':
					display_name = ''
		elif slot_key == "BasePassives":
			display_name = ''
				
		var req_tags = slot_set_data.get("FilterData", {}).get("RequiredTags", [])
		if req_tags is String:
			req_tags = [req_tags]
			
		if slot_set == null or last_display_name != display_name or  slot_set_datas.size() == 3:
			slot_set = premade_page_set.duplicate()
			slot_set.title_label.text = display_name
			if display_name == '':
				slot_set.title_label.hide()
			slot_set.buttons_container.get_child(0).queue_free()
			self.sets_container.add_child(slot_set)
			slot_set.show()
			
		last_display_name = display_name
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
			new_button.is_clipped = req_tags.has("Passive")
			new_button.show()
			_buttons.append(new_button)
			raw_index += 1
	var dot_index = 0
	var total_hight = 0
	_dot_index_to_set_containers.clear()
	for sub_container:PageSlotSetContainer in self.sets_container.get_children():
		if sub_container.is_queued_for_deletion():
			continue
		var has_label = sub_container.title_label.visible
		var button_count = sub_container.buttons_container.get_child_count() - 1 #Premade
		var button_rows = ceili(float(button_count) / 4.0)
		var hight = button_rows * 64
		if has_label: hight += 30
		if hight + total_hight > slot_sets_container_hight:
			dot_index += 1
		if dot_index > 0:
			sub_container.hide()
		if not _dot_index_to_set_containers.has(dot_index):
			_dot_index_to_set_containers[dot_index] = []
		_dot_index_to_set_containers[dot_index].append(sub_container)
		total_hight += hight
	scroll_dots.dot_count = dot_index + 1
	_current_dot_index = -1
	show_page(0)
	if scroll_dots.dot_count < 2:
		scroll_dots.hide()
	else:
		scroll_dots.show()
		
func show_page(dot_index):
	if _current_dot_index == dot_index:
		return
	if _dot_index_to_set_containers.has(dot_index):
		if _dot_index_to_set_containers.has(_current_dot_index):
			for sub_container:PageSlotSetContainer in _dot_index_to_set_containers[_current_dot_index]:
				sub_container.hide()
		for sub_container:PageSlotSetContainer in _dot_index_to_set_containers[dot_index]:
			sub_container.show()
		_current_dot_index = dot_index
		
	
		
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
