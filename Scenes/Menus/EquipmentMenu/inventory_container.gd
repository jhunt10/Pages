@tool
class_name InventoryContainer
extends BackPatchContainer

signal item_button_down(item:BaseItem, button:InventoryItemButton)
signal item_button_hover(item:BaseItem)
signal item_button_hover_end
signal item_button_clicked(item:BaseItem)

@export var tab_bar:TabBar
@export var items_container:FlowContainer
@export var premade_item_button:InventoryItemButton
@export var filter_option_button:LoadedOptionButton

var _mouse_in_button:InventoryItemButton
var _item_buttons:Dictionary = {}
var _hover_delay:float = 0.3
var _hover_timer:float
var _click_delay:float = 0.4
var _click_timer:float

var greater_filters:Dictionary = {
	'All': ['Equipment', 'Armor', 'Weapon', 'Consumable'],
	'Equipment': ['Head', 'Body', 'Feet', 'Book', 'Bag', 'Trinket', 'Offhand', 'Weapon'],
	'Consumable': ['Potion', 'Bomb'],
}

func _ready() -> void:
	super()
	if Engine.is_editor_hint(): return
	if !PlayerInventory.Instance.inventory_changed.is_connected(on_player_inventory_changed):
		PlayerInventory.Instance.inventory_changed.connect(on_player_inventory_changed)
	premade_item_button.visible = false
	tab_bar.tab_changed.connect(_on_tab_bar_select)
	filter_option_button.get_options_func = get_greater_filter_options
	filter_option_button.item_selected.connect(on_greater_filter_selected)
	if !ItemLibrary.Instance:
		ItemLibrary.new()
	build_item_list()
	filter_option_button.load_options()
	filter_option_button.select(0)
	on_greater_filter_selected(0)

func _process(delta: float) -> void:
	super(delta)
	if Engine.is_editor_hint(): return
	#if _mouse_in_button and _hover_timer > 0:
		#_hover_timer -= delta
		#if _hover_timer < 0:
			#var item = ItemLibrary.get_item(_mouse_in_button._item_id)
			#if item:
				#item_button_hover.emit(item)
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
	var greater_filter = filter_option_button.get_current_option_text()
	var tab_filter = tab_bar.get_tab_title(tab_bar.current_tab)
	build_item_list()
	filter_items_with_tag(tab_filter)

func _on_item_button_down(button:InventoryItemButton):
	var item = button.get_item()
	item_button_down.emit(item, button)
	_click_timer = _click_delay
func _on_item_button_up(button:InventoryItemButton):
	if _click_timer > 0:
		var item = button.get_item()
		item_button_clicked.emit(item)
	_click_timer = 0
	

func _mouse_enter_button(button:InventoryItemButton):
	_mouse_in_button = button
	_hover_timer = _hover_delay
func _mouse_exit_button(button:InventoryItemButton):
	_mouse_in_button = null
	_hover_timer = -1
	item_button_hover_end.emit()

func _on_tab_bar_select(index:int):
	var tab_name = tab_bar.get_tab_title(index)
	if tab_name == "All":
		filter_items_with_tag('')
	else:
		filter_items_with_tag(tab_name)
	pass

func filter_items_with_tag(tag:String):
	var greater_filter = filter_option_button.get_current_option_text()
	for button:InventoryItemButton in _item_buttons.values():
		var item = button.get_item()
		var tags = item.get_item_tags()
		if greater_filter != 'All' and not tags.has(greater_filter):
			button.visible = false
			continue
			
		if tag == '' or tag == 'All':
			button.visible = true
		elif tags.has(tag):
			button.visible = true
		else:
			button.visible = false

func set_greater_filter(key:String):
	filter_option_button.load_options(key)
	var filter_option = filter_option_button.get_current_option_text()
	if filter_option != key:
		return
	var tabs_list = greater_filters[filter_option]
	tab_bar.clear_tabs()
	tab_bar.add_tab('All')
	for t in tabs_list:
		tab_bar.add_tab(t)
	tab_bar.current_tab = 0
	filter_items_with_tag('')

func get_greater_filter_options()->Array:
	return greater_filters.keys()

func on_greater_filter_selected(index:int):
	var filter_option = filter_option_button.get_item_text(index)
	var tabs_list = greater_filters[filter_option]
	tab_bar.clear_tabs()
	tab_bar.add_tab('All')
	for t in tabs_list:
		tab_bar.add_tab(t)
	tab_bar.current_tab = 0
	filter_items_with_tag('')
	
