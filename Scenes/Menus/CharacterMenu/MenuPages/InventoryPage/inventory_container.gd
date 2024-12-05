#@tool
class_name InventoryContainer
extends Control

var event_context = "Inventory"
signal item_button_down(context, item_key, index)
signal item_button_up(context, item_key, index)
signal mouse_enter_item(context, item_key, index)
signal mouse_exit_item(context, item_key, index)

#signal item_button_down(item:BaseItem, button:InventoryItemButton)
#signal item_button_hover(item:BaseItem)
#signal item_button_hover_end
#signal item_button_clicked(item:BaseItem)

#@export var tab_bar:TabBar
@export var scroll_container:ScrollContainer
@export var items_container:FlowContainer
@export var premade_item_button:InventoryItemButton
@export var scroll_bar:CustScrollBar
@export var inventory_box_highlight:NinePatchRect
#@export var filter_option_button:LoadedOptionButton

var _mouse_in_button:InventoryItemButton
var _item_buttons:Dictionary = {}
var _hover_delay:float = 0.3
var _hover_timer:float
var _click_delay:float = 0.4
var _click_timer:float

var _forced_filters:Array=[]

func _ready() -> void:
	#super()
	if Engine.is_editor_hint(): return
	if !PlayerInventory.Instance.inventory_changed.is_connected(on_player_inventory_changed):
		PlayerInventory.Instance.inventory_changed.connect(on_player_inventory_changed)
	if premade_item_button:
		premade_item_button.visible = false
		if !ItemLibrary.Instance:
			ItemLibrary.new()
		build_item_list()
	inventory_box_highlight.hide()
	scroll_container.mouse_entered.connect(on_mouse_enter_inventory_box)
	scroll_container.mouse_exited.connect(on_mouse_exit_inventory_box)

func _process(delta: float) -> void:
	if _click_timer > 0:
		_click_timer -= delta

func build_item_list():
	for button in _item_buttons.values():
		button.queue_free()
	_item_buttons.clear()
	
	for item in PlayerInventory.list_held_item_stacks():
		_build_button(item)

func _build_button(item:BaseItem):
	var new_button:InventoryItemButton = premade_item_button.duplicate()
	items_container.add_child(new_button)
	var count = 0
	if item.can_stack:
		count = PlayerInventory.get_item_stack_count(item.ItemKey)
	new_button.set_item(item, count)
	_item_buttons[item.Id] = new_button
	new_button.visible = true
	new_button.button_down.connect(_on_item_button_down.bind(new_button))
	new_button.button_up.connect(_on_item_button_up.bind(new_button))
	new_button.mouse_entered.connect(_mouse_enter_button.bind(new_button))
	new_button.mouse_exited.connect(_mouse_exit_button.bind(new_button))

func on_player_inventory_changed():
	#var greater_filter = filter_option_button.get_current_option_text()
	#var tab_filter = tab_bar.get_tab_title(tab_bar.current_tab)
	build_item_list()
	#filter_items_with_tag(tab_filter)

func _on_item_button_down(button:InventoryItemButton):
	var offset = button.get_local_mouse_position()
	item_button_down.emit(event_context, button._item_id, {"Offset":offset})
	
func _on_item_button_up(button:InventoryItemButton):
	var item = button.get_item()
	var offset = button.get_local_mouse_position()
	item_button_up.emit(event_context, button._item_id, {"Offset":offset})
	

func _mouse_enter_button(button:InventoryItemButton):
	mouse_enter_item.emit(event_context, button._item_id, {})
func _mouse_exit_button(button:InventoryItemButton):
	mouse_exit_item.emit(event_context, button._item_id, {})

func on_mouse_enter_inventory_box():
	inventory_box_highlight.show()
	mouse_enter_item.emit(event_context, null, {"InventoryBox":true})

func on_mouse_exit_inventory_box():
	inventory_box_highlight.hide()
	mouse_exit_item.emit(event_context, null, {"InventoryBox":true})

func clear_forced_filters(refilter:bool=true):
	_forced_filters.clear()
	if refilter:
		_refilter()

func add_forced_filter(tag, refilter:bool=true):
	if !_forced_filters.has(tag):
		_forced_filters.append(tag)
		if refilter:
			_refilter()

func _refilter():
	for button:InventoryItemButton in _item_buttons.values():
		var item = button.get_item()
		var tags = item.get_item_tags()
		#if greater_filter != 'All' and not tags.has(greater_filter):
			#button.visible = false
			#continue
		var show = true
		for f_filter in _forced_filters:
			if not tags.has(f_filter):
				show = false
				break
		
		button.visible = show
	await get_tree().process_frame
	scroll_bar.calc_bar_size()
