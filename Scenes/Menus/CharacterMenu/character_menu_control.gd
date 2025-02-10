class_name CharacterMenuControl
extends Control

const LOGGING = false

static var Instance:CharacterMenuControl

@export var inventory_tabs_control:ItemFilterTabsControl
@export var details_card_spawn_point:Control
@export var equipment_page:EquipmentPageControl
@export var page_page:PagePageControl
@export var bag_page:BagPageControl
@export var stats_page:StatsPageControl

@export var scale_control:Control
@export var inventory_container:InventoryContainer
@export var actor_tabs_control:ActorSelector
@export var close_button:Button
@export var tab_equipment_button:Button
@export var tab_pages_button:Button
@export var tab_bag_button:Button
@export var tab_inventory_button:Button
@export var tab_stats_button:Button
@export var inventory_tab_rect:TextureRect
@export var stats_tab_rect:TextureRect
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
	Instance = self
	close_button.pressed.connect(close_menu)
	tab_equipment_button.pressed.connect(on_tab_pressed.bind("Equipment"))
	tab_pages_button.pressed.connect(on_tab_pressed.bind("Pages"))
	tab_bag_button.pressed.connect(on_tab_pressed.bind("Bag"))
	tab_inventory_button.pressed.connect(on_tab_pressed.bind("Inventory"))
	tab_stats_button.pressed.connect(on_tab_pressed.bind("Stats"))
	
	equipment_page.item_button_down.connect(on_item_button_down)
	equipment_page.item_button_up.connect(on_item_button_up)
	equipment_page.mouse_enter_item.connect(on_mouse_enter_slot)
	equipment_page.mouse_exit_item.connect(on_mouse_exit_slot)
	#
	inventory_container.item_button_down.connect(on_item_button_down)
	inventory_container.item_button_up.connect(on_item_button_up)
	inventory_container.mouse_enter_item.connect(on_mouse_enter_slot)
	inventory_container.mouse_exit_item.connect(on_mouse_exit_slot)
	
	page_page.item_button_down.connect(on_item_button_down)
	page_page.item_button_up.connect(on_item_button_up)
	page_page.mouse_enter_item.connect(on_mouse_enter_slot)
	page_page.mouse_exit_item.connect(on_mouse_exit_slot)
	#
	bag_page.item_button_down.connect(on_item_button_down)
	bag_page.item_button_up.connect(on_item_button_up)
	bag_page.mouse_enter_item.connect(on_mouse_enter_slot)
	bag_page.mouse_exit_item.connect(on_mouse_exit_slot)
	stop_dragging()
	on_tab_pressed("Inventory")
	on_tab_pressed("Pages")
	inventory_tabs_control.on_tab_selected.connect(on_inv_filter_selected)
	inventory_tabs_control.on_tab_unselected.connect(on_inv_filter_unselected)
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
	var start_time = Time.get_unix_time_from_system()
	print("Starting Set Actor: %s" % Time.get_datetime_string_from_unix_time(start_time))
	_actor = actor
	equipment_page.set_actor(actor)
	page_page.set_actor(actor)
	bag_page.set_actor(actor)
	stats_page.set_actor(actor)
	actor_tabs_control.set_selected_actor(actor)
	var finish_time = Time.get_unix_time_from_system()
	var time_diff = finish_time - start_time
	print("Finished Set Actor: %s" % Time.get_datetime_string_from_unix_time(finish_time))
	print("RunTime: %s" % Time.get_time_string_from_unix_time(time_diff))

func close_menu():
	var page_que = _actor.equipment.get_que_equipment()
	if not page_que:
		equipment_page.play_pagebook_warning_animation()
	else:
		self.queue_free()
		Instance = null
	

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
	_current_details_card.vertical = true
	_current_details_card.hide_done.connect(on_details_card_freed)
	_current_details_card.set_item(_actor, item)
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
		mouse_control.set_drag_item(_selected_item)
		#mouse_control.drag_item_icon.texture = _selected_item.get_large_icon()
		mouse_control.position = _button_down_pos - mouse_control.offset
		mouse_control.show()
		if LOGGING: print("StartDragging: SelectedItem: %s" % [_selected_item.Id])

func stop_dragging():
	_dragging = false
	_button_down_pos = null
	mouse_control.hide()
	if LOGGING: print("Stop Dragging: %s | %s" % [_selected_context, _mouse_over_context])
	# Transfering items
	if _selected_context and _mouse_over_context:
		
		# From Left Page to Inventory - Remove Item
		if _mouse_over_context == "Inventory" and _selected_context != "Inventory":
			if LOGGING: print("Remove Item: %s" %[_selected_item.Id])
			var page_control = context_to_page_control(_selected_context)
			if page_control:
				page_control.remove_item_from_slot(_selected_item, _selected_index_data)
		
		if _mouse_over_index_data != null:
			# From Inventory to Left Page - Add Item
			if _mouse_over_context != "Inventory" and _selected_context == "Inventory":
				if LOGGING: print("Add Item")
				var page_control = context_to_page_control(_mouse_over_context)
				if page_control:
					page_control.try_place_item_in_slot(_selected_item, _mouse_over_index_data)
			
			# From Left Page to Left Page - Move Item
			if _mouse_over_context != "Inventory" and _selected_context == _mouse_over_context:
				if LOGGING: print("Move Item")
				var page_control = context_to_page_control(_mouse_over_context)
				if page_control:
					page_control.try_move_item_to_slot(_selected_item, _selected_index_data, _mouse_over_index_data)
		_selected_item  
		

func clear_highlights():
	equipment_page.clear_highlights()
	page_page.clear_highlights()
	bag_page.clear_highlights()

func on_item_button_down(context, item_key, index, offset):
	clear_highlights()
	_selected_context = context
	_button_down_pos = scale_control.get_local_mouse_position()
	_selected_index_data = index
	if _current_details_card and _current_details_card.item_id != item_key:
		_current_details_card.start_hide()
	if item_key:
		_selected_item = ItemLibrary.get_item(item_key)
		mouse_control.offset = offset
	else:
		_selected_item = null
	var page_control = context_to_page_control(context)
	if page_control:
		page_control.highlight_slot(index)
	if LOGGING: print("Item Button Down: %s | %s | %s" % [context, item_key, index])

func on_item_button_up(context, item_key, index):
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
				page_control.highlight_slot(index)
	if LOGGING: print("Item Button Up: %s | %s | %s" % [context, item_key, index])

func on_mouse_enter_slot(context, item_key, index):
	_mouse_over_context = context
	_mouse_over_index_data = index
	if LOGGING: print("Item Button Enter: %s | %s | %s" % [context, item_key, index])
	if _dragging:
		var control = context_to_page_control(context)
		if control:
			control.highlight_slot(index)
			
func on_mouse_exit_slot(context, item_key, index):
	_mouse_over_context = context
	_mouse_over_index_data = null
	if _dragging:
		clear_highlights()
	if LOGGING: print("Item Button Exit : %s | %s | %s" % [context, item_key, index])

func on_inv_filter_selected(tab_name):
	inventory_container.add_sub_filter(tab_name)

func on_inv_filter_unselected(tab_name):
	inventory_container.remvoe_sub_filter(tab_name)

func on_tab_pressed(tab_name:String):
	if tab_name == "Inventory":
		inventory_container.show()
		stats_page.hide()
		inventory_tab_rect.hide()
		stats_tab_rect.show()
		inventory_tabs_control.show()
		return
	if tab_name == "Stats":
		stats_page.show()
		inventory_container.hide()
		stats_tab_rect.hide()
		inventory_tab_rect.show()
		inventory_tabs_control.hide()
		return
	
	_left_page_context = tab_name
	
	if _left_page_context == "Equipment":
		equipment_page.visible = true
		page_page.visible = false
		bag_page.visible = false
		inventory_container.clear_forced_filters(false)
		inventory_container.add_forced_filter("Equipment")
		inventory_tabs_control.set_tabs(["Que", "Bag", "Helm", "Body", "Feet", "Weapon", "OffHand", "Trinket"])
		
	if _left_page_context == "Pages":
		equipment_page.visible = false
		page_page.visible = true
		bag_page.visible = false
		inventory_container.clear_forced_filters(false)
		inventory_container.add_forced_filter("Page")
		inventory_tabs_control.set_tabs(["ClassPage", "Bar", "Movement", "Tactic", "Spell"])
		
	if _left_page_context == "Bag":
		equipment_page.visible = false
		page_page.visible = false
		bag_page.visible = true
		inventory_container.clear_forced_filters(false)
		inventory_container.add_forced_filter("Consumable")
		inventory_tabs_control.set_tabs(["Potion", "Bomb"])
