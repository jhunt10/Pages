@tool
class_name InventoryContainer
extends Control

var event_context = "Inventory"
signal item_button_down(context, item_key, index, offset)
signal item_button_up(context, item_key, index)
signal mouse_enter_item(context, item_key, index)
signal mouse_exit_item(context, item_key, index)

#signal item_button_down(item:BaseItem, button:InventoryItemButton)
#signal item_button_hover(item:BaseItem)
#signal item_button_hover_end
#signal item_button_clicked(item:BaseItem)
@export var min_button_size:Vector2i
@export var max_button_size:Vector2i
#@export var tab_bar:TabBar
@export var scroll_container:ScrollContainer
@export var items_container:FlowContainer
@export var premade_item_button:InventoryItemButton
@export var scroll_bar:CustScrollBar
@export var inventory_box_highlight:NinePatchRect
@export var filter_option_button:LoadedOptionButton

var _mouse_in_button:InventoryItemButton
var _item_buttons:Dictionary = {}
var _hover_delay:float = 0.3
var _hover_timer:float
var _click_delay:float = 0.4
var _click_timer:float

var _forced_filters:Array=[]
var _sub_filters:Array = []

var _cached_size

func _ready() -> void:
	if Engine.is_editor_hint(): return
	filter_option_button.get_options_func = get_filter_options
	filter_option_button.item_selected.connect(_on_sub_filter_selected)
	filter_option_button.load_options("All")
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
	if self.size != _cached_size:
		calc_button_size()
	if Engine.is_editor_hint(): return
	if _click_timer > 0:
		_click_timer -= delta

func calc_button_size():
	_cached_size = self.size
	var container_width = items_container.size.x
	var seperator = 0
	var button_width = (seperator/2) + 64
	var est_button_count = floori((container_width - seperator) / button_width)
	var left_over = container_width - (64 * est_button_count)
	var sep_size = floori(left_over / (est_button_count-1))
	sep_size = min(6, sep_size)
	items_container.add_theme_constant_override("h_separation", sep_size)
	items_container.add_theme_constant_override("v_separation", sep_size)
	
	var seperator_total_width = (est_button_count-1) * sep_size
	var real_button_width = (container_width - seperator_total_width) / est_button_count
	print("Width: %s | Est Cnt: %s | Button Size: %s" % [container_width, est_button_count, real_button_width])
	for child in items_container.get_children():
		if child is InventoryItemButton:
			(child as InventoryItemButton).custom_minimum_size = Vector2(real_button_width, real_button_width)

func build_item_list():
	for item_id in _item_buttons.keys():
		if not PlayerInventory.has_item_id(item_id):
			_item_buttons[item_id].queue_free()
			_item_buttons.erase(item_id)
		elif _item_buttons[item_id].get_parent() == items_container:
			items_container.remove_child(_item_buttons[item_id])
	
	for item:BaseItem in PlayerInventory.get_sorted_items():
		var button = _item_buttons.get(item.Id)
		if !button:
			button = _build_button(item)
		items_container.add_child(button)
		if item.can_stack:
			button.set_item(item, PlayerInventory.get_item_stack_count(item.ItemKey))
		button.visible = should_item_be_visible(item)

func _build_button(item:BaseItem)->InventoryItemButton:
	var new_button:InventoryItemButton = premade_item_button.duplicate()
	var count = 0
	if item.can_stack:
		count = PlayerInventory.get_item_stack_count(item.ItemKey)
	new_button.set_item(item, count)
	new_button.button.button_down.connect(_on_item_button_down.bind(new_button))
	new_button.button.button_up.connect(_on_item_button_up.bind(new_button))
	new_button.button.mouse_entered.connect(_mouse_enter_button.bind(new_button))
	new_button.button.mouse_exited.connect(_mouse_exit_button.bind(new_button))
	_item_buttons[item.Id] = new_button
	return new_button

func on_player_inventory_changed():
	#var greater_filter = filter_option_button.get_current_option_text()
	#var tab_filter = tab_bar.get_tab_title(tab_bar.current_tab)
	build_item_list()
	#_refilter()
	#filter_items_with_tag(tab_filter)

func _on_item_button_down(button:InventoryItemButton):
	var offset = button.get_local_mouse_position()
	item_button_down.emit(event_context, button._item_id, -1, offset)
	
func _on_item_button_up(button:InventoryItemButton):
	var item = button.get_item()
	var offset = button.get_local_mouse_position()
	item_button_up.emit(event_context, button._item_id, -1)

func _mouse_enter_button(button:InventoryItemButton):
	mouse_enter_item.emit(event_context, button._item_id, -1)
func _mouse_exit_button(button:InventoryItemButton):
	mouse_exit_item.emit(event_context, button._item_id, -1)

func on_mouse_enter_inventory_box():
	inventory_box_highlight.show()
	mouse_enter_item.emit(event_context, null, {"InventoryBox":true})

func on_mouse_exit_inventory_box():
	inventory_box_highlight.hide()
	mouse_exit_item.emit(event_context, null, {"InventoryBox":true})

func clear_forced_filters(refilter:bool=true):
	_sub_filters.clear()
	_forced_filters.clear()
	if refilter:
		filter_option_button.load_options("All")
		_refilter()

func add_forced_filter(tag, refilter:bool=true):
	if !_forced_filters.has(tag):
		_forced_filters.append(tag)
		var valid_filters = get_filter_options()
		for sub in _sub_filters:
			if not valid_filters.has(sub):
				_sub_filters.erase(sub)
		var current_filter = filter_option_button.get_current_option_text()
		if current_filter != 'All' and not valid_filters.has(current_filter):
			filter_option_button.load_options("All")
		if refilter:
			_refilter()

func _refilter():
	for button:InventoryItemButton in _item_buttons.values():
		var item = button.get_item()
		button.visible = should_item_be_visible(item)
	await get_tree().process_frame
	scroll_bar.calc_bar_size()
	#filter_option_button.load_options()

func should_item_be_visible(item:BaseItem):
	var tags = item.get_item_tags()
	for f_filter in _forced_filters:
		if not tags.has(f_filter):
			return false
	if _sub_filters.size() == 0:
		return true
	var at_least_one_sub = false
	for s_filter in _sub_filters:
		if tags.has(s_filter):
			at_least_one_sub = true
	return at_least_one_sub

func _on_sub_filter_selected(index:int):
	var filter = filter_option_button.get_current_option_text()
	_sub_filters = []
	if filter != "All":
		_sub_filters.append(filter)
	_refilter()

func add_sub_filter(val:String):
	if !_sub_filters:
		_sub_filters = []
	if not _sub_filters.has(val):
		_sub_filters.append(val)
	_refilter()

func remvoe_sub_filter(val:String):
	if !_sub_filters:
		_sub_filters = []
	if _sub_filters.has(val):
		_sub_filters.erase(val)
	_refilter()

func get_filter_options()->Array:
	if _forced_filters.has("Equipment"):
		return ["All", "Que", "Bag", "Head", "Body", "Feet", "Trinket", "MainHand", "OffHand"]
	if _forced_filters.has("Page"):
		return ["All", "ClassPage", "Movement", "Tactic", "Spell"]
	if _forced_filters.has("Consumable"):
		return ["All", "Potion", "Bomb"]
	return []
