class_name CharacterMenu
extends Control

const LOGGING = false
const DRAG_DEAD_ZONE = 10

signal closed

@export var name_panel:CharacterNamePanelContainer
@export var stats_panel:StatsPanelContainer
@export var actor_sprite:BaseActorNode
@export var equipment_control:CharacterMenu_EquipmentControl
@export var title_slot_button:EquipmentSlotButton
@export var tab_container:TabContainer
@export var page_tab:CharacterMenu_PagesTab
@export var bag_tab:CharacterMenu_SuppliesTab
@export var stats_tab:CharacterMenu_StatsTab
@export var carrier_control:CarrierControl


@export var inventory_container:InventoryMenuPageControl

@export var close_button:Button
@export var previous_character_button:Button
@export var next_character_button:Button
@export var details_card_spawn_point:Control
@export var mouse_control:CharacterMenuMouseControl
@export var inventory_option_button:OptionButton
@export var skill_tree_control:SkillTreePageControl
@export var skill_tree_menu:SkillTreeMenu

@export var animation_player:AnimationPlayer

var _current_details_card:ItemDetailsCard

var delay_loading_inventory=true
var delay_loading_inventory__first_process=false

var current_party_actor_index = 0
var _actor:BaseActor

var _mouse_over_context:String
var _mouse_over_index_data
var _selected_context
var _selected_index_data
var _selected_item:BaseItem
var _pressed_item:BaseItem = null
var _dragging:bool = false
var _button_down_pos
var _drag_dead_zone = 10

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	close_button.pressed.connect(_on_close)
	previous_character_button.pressed.connect(_on_previous_actor_pressed)
	next_character_button.pressed.connect(_on_next_actor_pressed)
	tab_container.tab_changed.connect(_on_tab_change)
	equipment_control.parent_menu = self
	page_tab.parent_menu = self
	bag_tab.parent_menu = self
	
	if inventory_container:
		inventory_option_button.item_selected.connect(_on_right_page_option_select)
		inventory_container.parent_menu = self
		inventory_container.item_button_down.connect(on_item_button_down)
		inventory_container.item_button_up.connect(on_item_button_up)
		inventory_container.mouse_enter_item.connect(on_mouse_enter_slot)
		inventory_container.mouse_exit_item.connect(on_mouse_exit_slot)
	
	page_tab.item_button_down.connect(on_item_button_down)
	page_tab.item_button_up.connect(on_item_button_up)
	page_tab.mouse_enter_item.connect(on_mouse_enter_slot)
	page_tab.mouse_exit_item.connect(on_mouse_exit_slot)
	
	bag_tab.item_button_down.connect(on_item_button_down)
	bag_tab.item_button_up.connect(on_item_button_up)
	bag_tab.mouse_enter_item.connect(on_mouse_enter_slot)
	bag_tab.mouse_exit_item.connect(on_mouse_exit_slot)
	
	title_slot_button.button.pressed.connect(_on_title_button_pressed)
	equipment_control.item_button_down.connect(on_item_button_down)
	equipment_control.item_button_up.connect(on_item_button_up)
	equipment_control.mouse_enter_item.connect(on_mouse_enter_slot)
	equipment_control.mouse_exit_item.connect(on_mouse_exit_slot)
	
	name_panel.xp_bar.level_up_button_pressed.connect(_on_right_page_option_select.bind(3))
	
	
	skill_tree_menu.node_button_down.connect(on_item_button_down)
	skill_tree_menu.node_button_up.connect(on_item_button_up)
	skill_tree_menu.skill_menu_closed.connect(close_skill_menu)
	var first_actor = StoryState.get_party_actor_by_index(current_party_actor_index)
	set_actor(first_actor)

func set_actor(actor:BaseActor):
	if _actor:
		_actor.stats_changed.disconnect(_sync)
		_actor.equipment_changed.disconnect(_sync)
		_actor.bag_items_changed.disconnect(_sync)
		_actor.page_list_changed.disconnect(_sync)
		
	_actor = actor
	_actor.stats_changed.connect(_sync)
	_actor.equipment_changed.connect(_sync)
	_actor.bag_items_changed.connect(_sync)
	_actor.page_list_changed.connect(_sync)
	_sync()
	#skill_tree_control.set_actor(_actor)
	skill_tree_menu.set_actor(_actor)

var _last_right_page_index = 0
func _on_right_page_option_select(index:int):
	if index < 3:
		var option = inventory_option_button.get_item_text(index)
		inventory_container.set_character_menu_context(option)
		inventory_container.show()
		#skill_tree_control.hide()
		#skill_tree_menu.hide()
		if skill_tree_menu.visible:
			animation_player.play("close_skill_menu")
		if inventory_option_button.selected != index:
			inventory_option_button.selected = index
	if index == 3:
		inventory_option_button.selected = _last_right_page_index
		#inventory_container.hide()
		#skill_tree_control.show()
		#skill_tree_menu.show()
		if skill_tree_menu._actor != _actor:
			skill_tree_menu.set_actor(_actor)
		skill_tree_menu.sync(true)
		if not skill_tree_menu.visible:
			animation_player.play("open_skill_menu")
	_last_right_page_index = index

func close_skill_menu():
	animation_player.play("close_skill_menu")
	

func _sync():
	name_panel.sync(_actor)
	stats_panel.sync(_actor)
	actor_sprite.set_actor(_actor)
	carrier_control.sync(_actor)
	equipment_control.sync()
	page_tab.sync()
	bag_tab.sync()
	stats_tab.sync()
	inventory_container.sync()

func _process(_delta: float) -> void:
	# Delay loading Inventory
	if delay_loading_inventory:
		if not delay_loading_inventory__first_process:
			delay_loading_inventory__first_process = true
		else:
			delay_loading_inventory = false
			inventory_container.build_item_slots()
	
	# Start dragging if mouse moved enough
	if not _dragging and _button_down_pos:
		var mouse_pos = self.get_local_mouse_position()
		if mouse_pos.distance_to(_button_down_pos) > _drag_dead_zone:
			start_dragging()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and _current_details_card:
		var mouse_event:InputEventMouseButton = event as InputEventMouseButton
		var mouse_pos = mouse_event.global_position
		if not mouse_event.pressed and not _current_details_card.get_global_rect().has_point(mouse_pos):
			_current_details_card.que_hide()

func _on_close():
	self.queue_free()
	closed.emit()

func _on_tab_change(index:int):
	if inventory_option_button.selected != 3:
		inventory_option_button.select(index)
	match index:
		0:
			inventory_container.set_character_menu_context("Page")
		1:
			inventory_container.set_character_menu_context("Supplies")
		2:
			inventory_container.set_character_menu_context("Equipment")

func _on_next_actor_pressed():
	current_party_actor_index = (current_party_actor_index + 1) % StoryState.list_party_actors().size()
	var next_actor = StoryState.get_party_actor_by_index(current_party_actor_index)
	set_actor(next_actor)

func _on_previous_actor_pressed():
	var party_size = StoryState.list_party_actors().size()
	current_party_actor_index = (party_size + current_party_actor_index - 1) % party_size
	var next_actor = StoryState.get_party_actor_by_index(current_party_actor_index)
	set_actor(next_actor)

func _on_title_button_pressed():
	var title = _actor.get_title_page()
	create_details_card(title, no_call, "", true)

func no_call():
	pass

func context_to_page_control(context)->BaseCharacterSubMenu:
	if context == "Equipment":
		return equipment_control
	if context == "Pages":
		return page_tab
	if context == "Supplies":
		return bag_tab
	if context == "Inventory":
		return inventory_container
	return null

func create_details_card(
		item:BaseItem, 
		on_confirm:Callable,
		confirm_button_text:String="Confirm",  
		disable_confirm:bool=false
		)->ItemDetailsCard:
	var old_detail_card
	if _current_details_card:
		old_detail_card = _current_details_card
		# Same Item is already beging displayed
		if old_detail_card.item_id == item.Id:
			return old_detail_card
			
			
		old_detail_card.hide_done.disconnect(_on_details_card_freed)
		if old_detail_card.state != ItemDetailsCard.States.Hidden:
			old_detail_card.start_hide()
	
	if !item:
		return null
	_current_details_card = null
	_current_details_card = load("res://Scenes/Menus/CharacterMenu_old/MenuPages/ItemDetailsCard/item_details_card.tscn").instantiate()
	details_card_spawn_point.add_child(_current_details_card)
	if old_detail_card:
		details_card_spawn_point.remove_child(old_detail_card)
		details_card_spawn_point.add_child(old_detail_card)
	_current_details_card.vertical = true
	_current_details_card.hide_done.connect(_on_details_card_freed)
	_current_details_card.set_detail_card_item(_actor, item, confirm_button_text, disable_confirm)
	_current_details_card.item_confirmed.connect(on_confirm)
	_current_details_card.start_show()
	return _current_details_card

func _on_details_card_freed():
	pass
	
func get_context_for_item(item:BaseItem)->BaseCharacterSubMenu:
		if item is BaseEquipmentItem:
			return equipment_control
		elif item is BasePageItem:
			return page_tab
		elif item is BaseSupplyItem:
			return bag_tab
		return null

func _on_details_card_confirmed(item:BaseItem, context):
	# From Inventory to a holder
	if context == 'Inventory':
		var target_context = get_context_for_item(item)
		if not target_context:
			return
		var target_holder:BaseItemHolder = target_context.get_item_holder()
		if not target_holder:
			return
		var allow_replace = item is BaseEquipmentItem
		var target_index = target_holder.get_first_valid_slot_for_item(item, allow_replace)
		if target_index >= 0:
			target_context.try_place_item_in_slot(item, target_index)
			
	else:
		var control = context_to_page_control(context)
		var holder = control.get_item_holder()
		if not holder:
			return
		if holder.has_item(item):
			var index = holder.get_raw_slot_index_of_item(item)
			control.remove_item_from_slot(item, index)
		
	_current_details_card.start_hide()

func start_dragging():
	if _selected_item:
		_dragging = true
		mouse_control.set_drag_item(_selected_item)
		#mouse_control.drag_item_icon.texture = _selected_item.get_large_icon()
		mouse_control.position = _button_down_pos - mouse_control.offset
		#var mouse_pos = get_global_mouse_position()
		mouse_control.show()
		if LOGGING: print("StartDragging: SelectedItem: %s" % [_selected_item.Id])

func start_dragging_item():
	_dragging = true
	if _pressed_item:
		mouse_control.set_drag_item(_pressed_item)
		mouse_control.position = _button_down_pos - mouse_control.offset
		mouse_control.show()
		print("StartDragging: SelectedItem: %s" % [_pressed_item.Id])

func stop_dragging():
	_dragging = false
	_pressed_item = null
	_button_down_pos = null
	mouse_control.hide()
	if LOGGING: print("\n\nStop Dragging: %s | %s" % [_selected_context, _mouse_over_context])
	# Lazy Hack
	if _mouse_over_context == "SkillTree":
		_mouse_over_context = "Inventory"
	if _selected_context == "SkillTree":
		_selected_context = "Inventory"
	 #Transfering items
	if _selected_context and _mouse_over_context:
		var source_page_control = context_to_page_control(_selected_context)
		var dest_page_control = context_to_page_control(_mouse_over_context)
		# From Left Page to Inventory - Remove Item
		if _mouse_over_context == "Inventory" and _selected_context != "Inventory":
			if LOGGING: print("Remove Item: %s" %[_selected_item.Id])
			if source_page_control:
				ItemHelper.try_transfer_item_from_holder_to_inventory(_selected_item, source_page_control.get_item_holder())
		
		if _mouse_over_index_data != null:
			# From Inventory to Left Page - Add Item
			if _mouse_over_context != "Inventory" and _selected_context == "Inventory":
				if LOGGING: print("Add Item")
				
				if dest_page_control:
					dest_page_control.try_place_item_in_slot(_selected_item, _mouse_over_index_data)
			
			# From Left Page to Left Page - Move Item
			if _mouse_over_context != "Inventory" and _selected_context == _mouse_over_context:
				if LOGGING: print("Move Item")
				if dest_page_control:
					dest_page_control.try_move_item_to_slot(_selected_item, _selected_index_data, _mouse_over_index_data)
		if source_page_control:
			source_page_control.sync()
		if dest_page_control:
			dest_page_control.sync()



func on_item_button_down(context, item_id, index, offset):
	_selected_context = context
	_button_down_pos = self.get_local_mouse_position()
	_selected_index_data = index
	#if _current_details_card and _current_details_card.item_id != item_key:
		#_current_details_card.start_hide()
	if item_id:
		_selected_item = ItemLibrary.get_item(item_id)
		mouse_control.offset = offset
	else:
		_selected_item = null
	var page_control = context_to_page_control(context)
	if page_control:
		page_control.highlight_slot(index)
	if LOGGING: print("Item Button Down: %s | %s | %s" % [context, item_id, index])

func on_item_button_up(context, item_id, index):
	_button_down_pos = null
	if _dragging:
		stop_dragging()
		_selected_context = null
		_selected_index_data = null
		return
	if context == "SkillTree":
		return
	if item_id:
		_selected_item = ItemLibrary.get_item(item_id)
		if not _selected_item:
			return
		var dest_context = get_context_for_item(_selected_item)
		var disable_confirm = false
		var is_removing = true
		var confirm_text = "Remove"
		
		if context == "Inventory":
			is_removing = false
			if dest_context == equipment_control:
				confirm_text = "Equip"
			else:
				confirm_text = "Add"
			
		# Disable removing PageBook
		if _selected_item is BaseQueEquipment and is_removing:
			disable_confirm = true
		
		# Check open slots for Pages and Supplies
		if not is_removing and dest_context != equipment_control:
			var holder = dest_context.get_item_holder()
			if holder:
				var open_index = holder.get_first_valid_slot_for_item(_selected_item)
				if open_index < 0:
					disable_confirm = true
					confirm_text = "Full"
		
		create_details_card(_selected_item, _on_details_card_confirmed.bind(context), confirm_text, disable_confirm)
		var page_control = context_to_page_control(context)
		if page_control:
			page_control.highlight_slot(index)
	if LOGGING: print("Item Button Up: %s | %s | %s" % [context, item_id, index])

func on_mouse_enter_slot(context, item_id, index):
	_mouse_over_context = context
	_mouse_over_index_data = index
	if LOGGING: print("Item Button Enter: %s | %s | %s" % [context, item_id, index])
	if _dragging:
		var control = context_to_page_control(context)
		if control:
			control.highlight_slot(index)
			
func on_mouse_exit_slot(context, item_id, index):
	_mouse_over_context = context
	_mouse_over_index_data = null
	var control = context_to_page_control(context)
	if control:
		control.clear_highlight(index)
	if LOGGING: print("Item Button Exit : %s | %s | %s" % [context, item_id, index])
