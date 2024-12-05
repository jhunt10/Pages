class_name CharacterMenuControl
extends Control

@export var details_card_spawn_point:Control
@export var equipment_page:EquipmentPageControl
@export var page_page:PagePageControl
@export var bag_page:BagPageControl

@export var scale_control:Control
@export var inventory_container:InventoryContainer
@export var close_button:Button
@export var tab_equipment_button:Button
@export var tab_pages_button:Button
@export var tab_bag_button:Button
@export var mouse_control:CharacterMenuMouseControl

var _actor:BaseActor
var _left_page_context
var _mouse_over_context:String
var _mouse_over_index_data
var _selected_context
var _selected_item:BaseItem
var _selected_index_data
var _current_details_card:ItemDetailsCard

var _dragging:bool = false
var _button_down_pos
var _drag_dead_zone = 10

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	close_button.pressed.connect(close_menu)
	tab_equipment_button.pressed.connect(on_tab_pressed.bind("Equipment"))
	tab_pages_button.pressed.connect(on_tab_pressed.bind("Pages"))
	tab_bag_button.pressed.connect(on_tab_pressed.bind("Bag"))
	
	equipment_page.item_button_down.connect(on_item_button_down)
	equipment_page.item_button_up.connect(on_item_button_up)
	equipment_page.mouse_enter_item.connect(on_mouse_enter_slot)
	equipment_page.mouse_exit_item.connect(on_mouse_exit_slot)
	
	inventory_container.item_button_down.connect(on_item_button_down)
	inventory_container.item_button_up.connect(on_item_button_up)
	inventory_container.mouse_enter_item.connect(on_mouse_enter_slot)
	inventory_container.mouse_exit_item.connect(on_mouse_exit_slot)
	
	page_page.item_button_down.connect(on_item_button_down)
	page_page.item_button_up.connect(on_item_button_up)
	page_page.mouse_enter_item.connect(on_mouse_enter_slot)
	page_page.mouse_exit_item.connect(on_mouse_exit_slot)
	
	bag_page.item_button_down.connect(on_item_button_down)
	bag_page.item_button_up.connect(on_item_button_up)
	bag_page.mouse_enter_item.connect(on_mouse_enter_slot)
	bag_page.mouse_exit_item.connect(on_mouse_exit_slot)
	stop_dragging()
	on_tab_pressed("Equipment")
	#if _actor == null:
		#ActorLibrary.new()
		#var test = ActorLibrary.get_actor("TestActor_ID")
		#set_actor(test)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not _dragging and _button_down_pos:
		var mouse_pos = scale_control.get_local_mouse_position()
		if mouse_pos.distance_to(_button_down_pos) > _drag_dead_zone:
			start_dragging()
	pass

#func _input(event: InputEvent) -> void:
	#if _dragging and event is InputEventMouseButton:
		#if event.is_released():
			#stop_dragging()

func set_actor(actor:BaseActor):
	_actor = actor
	equipment_page.set_actor(actor)
	page_page.set_actor(actor)
	bag_page.set_actor(actor)

func close_menu():
	ActorLibrary.save_actors()
	self.queue_free()

func on_details_card_freed():
	_current_details_card.queue_free()
	_current_details_card = null

func create_details_card(item:BaseItem):
	if _current_details_card:
		if _current_details_card.item_id == item.Id:
			_current_details_card.show()
			return
		_current_details_card.hide_done.disconnect(on_details_card_freed)
		_current_details_card.start_hide()
	_current_details_card = load("res://Scenes/Menus/CharacterMenu/MenuPages/ItemDetailsCard/item_details_card.tscn").instantiate()
	details_card_spawn_point.add_child(_current_details_card)
	_current_details_card.action_button_pressed.connect(on_details_card_button_pressed)
	_current_details_card.hide_done.connect(on_details_card_freed)
	_current_details_card.set_item(item)
	_current_details_card.start_show()

func context_to_page_control(context):
	if context == "Equipment":
		return equipment_page
	if context == "Pages":
		return page_page
	if context == "Bag":
		return bag_page
	return null

func start_dragging():
	if _selected_item:
		_dragging = true
		mouse_control.drag_item_icon.texture = _selected_item.get_large_icon()
		mouse_control.position = _button_down_pos - mouse_control.offset
		mouse_control.show()
		print("StartDragging")

func stop_dragging():
	_dragging = false
	_button_down_pos = null
	mouse_control.hide()
	print("Stop Dragging: %s | %s" % [_selected_context, _mouse_over_context])
	
	# Transfering items
	if _selected_context and _mouse_over_context:
		
		# From Left Page to Inventory - Remove Item
		if _mouse_over_context == "Inventory" and _selected_context != "Inventory":
			print("Remove Item")
			var page_control = context_to_page_control(_selected_context)
			if page_control:
				page_control.remove_item_from_slot(_selected_item, _selected_index_data)
		
		# From Inventory to Left Page - Add Item
		if _mouse_over_context != "Inventory" and _selected_context == "Inventory":
			print("Add Item")
			var page_control = context_to_page_control(_mouse_over_context)
			if page_control:
				page_control.try_place_item_in_slot(_selected_item, _mouse_over_index_data)
		
		# From Left Page to Left Page - Move Item
		if _mouse_over_context != "Inventory" and _selected_context == _mouse_over_context:
			print("Move Item")
			var page_control = context_to_page_control(_mouse_over_context)
			if page_control:
				page_control.try_move_item_to_slot(_selected_item, _selected_index_data, _mouse_over_index_data)
		

func clear_highlights():
	equipment_page.clear_highlights()
	page_page.clear_highlights()
	bag_page.clear_highlights()

func on_item_button_down(context, item_key, index_data):
	clear_highlights()
	_selected_context = context
	_button_down_pos = scale_control.get_local_mouse_position()
	_selected_index_data = index_data
	if _current_details_card and _current_details_card.item_id != item_key:
		_current_details_card.start_hide()
	if item_key:
		_selected_item = ItemLibrary.get_item(item_key)
		if index_data.has("Offset"):
			mouse_control.offset = index_data['Offset']
	var page_control = context_to_page_control(context)
	if page_control:
		page_control.highlight_slot(index_data)
	print("Item Button Down: %s | %s | %s" % [context, item_key, index_data])

func on_item_button_up(context, item_key, index_data):
	_button_down_pos = null
	clear_highlights()
	if _dragging:
		stop_dragging()
		_selected_context = null
		_selected_index_data = null
		return
	if item_key:
		_selected_item = ItemLibrary.get_item(item_key)
		if _selected_item:
			create_details_card(_selected_item)
			var page_control = context_to_page_control(context)
			if page_control:
				page_control.highlight_slot(index_data)
	print("Item Button Up: %s | %s | %s" % [context, item_key, index_data])

func on_mouse_enter_slot(context, item_key, index_data):
	_mouse_over_context = context
	_mouse_over_index_data = index_data
	print("Item Button Enter: %s | %s | %s" % [context, item_key, index_data])
	if _dragging:
		var control = context_to_page_control(context)
		if control:
			control.highlight_slot(index_data)
func on_mouse_exit_slot(context, item_key, index_data):
	_mouse_over_context = context
	_mouse_over_index_data = null
	if _dragging:
		clear_highlights()
	print("Item Button Exit : %s | %s | %s" % [context, item_key, index_data])

func on_details_card_button_pressed():
	if _selected_item:
		if _left_page_context == "Equipment" and _selected_item is BaseEquipmentItem:
			var equipment = (_selected_item as BaseEquipmentItem)
			if equipment.get_equipt_to_actor_id():
				equipment.clear_equipt_actor()
			else:
				_actor.equipment.try_equip_item(equipment,true)
		
		if _left_page_context == "Pages" and _selected_item is BasePageItem:
			var page = (_selected_item as BasePageItem)
			if _actor.pages.has_page(page.Id):
				_actor.pages.remove_page(page.Id)
			else:
				_actor.pages.try_add_page(page)
				
		if _left_page_context == "Bag" and _selected_item is BaseConsumableItem:
			var bag_item = (_selected_item as BaseConsumableItem)
			if _actor.items.has_item(bag_item.Id):
				_actor.items.remove_item(bag_item.Id)
			else:
				_actor.items.add_item_to_first_valid_slot(bag_item)
		_current_details_card.start_hide()

func on_tab_pressed(tab_name:String):
	_left_page_context = tab_name
	
	if _left_page_context == "Equipment":
		equipment_page.visible = true
		page_page.visible = false
		bag_page.visible = false
		inventory_container.clear_forced_filters(false)
		inventory_container.add_forced_filter("Equipment")
		
	if _left_page_context == "Pages":
		equipment_page.visible = false
		page_page.visible = true
		bag_page.visible = false
		inventory_container.clear_forced_filters(false)
		inventory_container.add_forced_filter("Page")
		
	if _left_page_context == "Bag":
		equipment_page.visible = false
		page_page.visible = false
		bag_page.visible = true
		inventory_container.clear_forced_filters(false)
		inventory_container.add_forced_filter("Consumable")
