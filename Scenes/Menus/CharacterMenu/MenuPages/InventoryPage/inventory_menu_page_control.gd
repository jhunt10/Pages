#@tool
class_name InventoryMenuPageControl
extends BaseCharacterSubMenu

var event_context = "Inventory"
var selection_context:String = "Pages"
#signal item_button_down(context, item_key, index, offset)
#signal item_button_up(context, item_key, index)
#signal mouse_enter_item(context, item_key, index)
#signal mouse_exit_item(context, item_key, index)

#signal item_button_down(item:BaseItem, button:InventoryItemButton)
#signal item_button_hover(item:BaseItem)
#signal item_button_hover_end
#signal item_button_clicked(item:BaseItem)
@export var min_button_size:Vector2i
@export var max_button_size:Vector2i
@export var loading_message_container:Container
#@export var tab_bar:TabBar
@export var scroll_container:ScrollContainer
@export var items_container:Container
@export var scroll_bar:CustScrollBar
@export var inventory_box_highlight:NinePatchRect
@export var filter_option_button:LoadedOptionButton

@export var premade_inventory_sub_group:InventorySubGroupContainer
@export var premade_item_button:InventoryItemButton

var _mouse_in_button:InventoryItemButton
var _item_buttons:Dictionary = {}
var _item_groups:Dictionary = {}
var _hover_delay:float = 0.3
var _hover_timer:float
var _click_delay:float = 0.4
var _click_timer:float

var _forced_filters:Array=[]
var _menu_context:String='Page'
var _sub_filters:Array = []

var _cached_size

var delayed_build:bool = false

var rebuild_on_next_scync = true

func _ready() -> void:
	#filter_option_button.get_options_func = get_filter_options
	#filter_option_button.item_selected.connect(_on_sub_filter_selected)
	#filter_option_button.load_options("All")
	
	if !ItemLibrary.Instance:
		ItemLibrary.new()
	if !PlayerInventory.Instance.inventory_changed.is_connected(on_player_inventory_changed):
		PlayerInventory.Instance.inventory_changed.connect(on_player_inventory_changed)
	if premade_item_button:
		premade_item_button.visible = false
	if premade_inventory_sub_group:
		premade_inventory_sub_group.hide()
	inventory_box_highlight.hide()
	scroll_container.mouse_entered.connect(on_mouse_enter_inventory_box)
	scroll_container.mouse_exited.connect(on_mouse_exit_inventory_box)

var tick_count = 10

func _process(delta: float) -> void:
	#if tick_count == 0:
		#build_item_slots()
		#delayed_build = false
		#tick_count = -1
	#else:
		#tick_count -= 1
	#if self.size != _cached_size:
		#calc_button_size()
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
			(child as InventoryItemButton).custom_minimum_size = Vector2(real_button_width, real_button_width + 16)

func on_player_inventory_changed():
	rebuild_on_next_scync = true
	#var greater_filter = filter_option_button.get_current_option_text()
	#var tab_filter = tab_bar.get_tab_title(tab_bar.current_tab)
	#build_item_slots()
	#_refilter()
	#filter_items_with_tag(tab_filter)

func sync():
	if rebuild_on_next_scync:
		build_item_slots()
	#super()
	_refilter()

func build_item_slots():
	for item_id in _item_buttons.keys():
		if not PlayerInventory.has_item_id(item_id):
			_item_buttons[item_id].hide()
			#_item_buttons.erase(item_id)
		#elif _item_buttons[item_id].get_parent() == items_container:
			#items_container.remove_child(_item_buttons[item_id])
	
	for item:BaseItem in PlayerInventory.get_sorted_items():
		if not should_item_be_visible(item, ''):
			continue
		var sub_group_key = _get_sub_group_key(item)
		var button = _get_or_create_button(item)
		var group = _get_or_create_sub_group_container(sub_group_key)
		if not group.get_inner_container().get_children().has(button):
			group.add_item_button(button)
		#items_container.add_child(button)
		
		#if item.can_stack:
		button.set_count(PlayerInventory.get_item_stack_count(item.ItemKey))
		
		button.visible =  true#should_item_be_visible(item, '')
		
	for sub_group_key in _item_groups.keys():
		items_container.remove_child(_item_groups[sub_group_key])
	for sub_group_key in get_sorted_sub_group_keys():
		if _item_groups.keys().has(sub_group_key):
			items_container.add_child(_item_groups[sub_group_key])
	#await get_tree().process_frame
	scroll_bar.calc_bar_size()
	loading_message_container.hide()
	_refilter()
	rebuild_on_next_scync = false

func get_sorted_sub_group_keys()->Array:
	var out_list = _item_groups.keys()
	out_list.sort_custom(sort_subacts_ascending)
	return out_list

# True when a comes before b
func sort_subacts_ascending(a:String, b:String):
	var a_score = 0
	var b_score = 0
	
	if a.contains("Title Page"):
		a_score += 1000
	if b.contains("Title Page"):
		b_score += 1000
		
	if a.contains("TitleLocked"):
		a_score -= 200
	if b.contains("TitleLocked"):
		b_score -= 200
	
	if a.contains("Shared"):
		a_score -= 100
	if b.contains("Shared"):
		b_score -= 100
	
	if a.contains("Passive"):
		a_score -= 10
	if b.contains("Passive"):
		b_score -= 10
	
	if a_score != b_score:
		return a_score < b_score
	if a < b:
		return true
	return false

func _get_sub_group_key(item:BaseItem)->String:
	var group_keys = []
	if item is BaseEquipmentItem:
		group_keys.append("Equipment")
	elif item is BasePageItem:
		if item is PageItemTitle:
			group_keys.append("Page")
			group_keys.append("Title Page")
			return ":".join(group_keys)
		else:
			group_keys.append("Page")
			var source_title = item.get_source_title()
			if source_title:
				if item.is_shareble():
					group_keys.append("Shared")
				else:
					group_keys.append("TitleLocked")
				group_keys.append(source_title)
	if item is BaseSupplyItem:
		group_keys.append("Supplies")
	var tax_leaf = item.get_taxonomy_leaf()
	if tax_leaf:
		group_keys.append(tax_leaf)
	return ":".join(group_keys)

func _get_or_create_button(item:BaseItem)->InventoryItemButton:
	if _item_buttons.keys().has(item.Id):
		return _item_buttons[item.Id]
	var new_button:InventoryItemButton = premade_item_button.duplicate()
	var count = 0
	
	#if item.can_stack:
	count = PlayerInventory.get_item_stack_count(item.ItemKey)
		
	new_button.set_item(item, count)
	new_button.button.button_down.connect(_on_inv_item_button_down.bind(new_button))
	new_button.button.button_up.connect(_on_inv_item_button_up.bind(new_button))
	new_button.button.mouse_entered.connect(_mouse_enter_button.bind(new_button))
	new_button.button.mouse_exited.connect(_mouse_exit_button.bind(new_button))
	new_button.name = "InventoryButton_" + item.ItemKey
	_item_buttons[item.Id] = new_button
	return new_button

func _get_or_create_sub_group_container(key)->InventorySubGroupContainer:
	if _item_groups.keys().has(key):
		return _item_groups[key]
	var new_group:InventorySubGroupContainer = premade_inventory_sub_group.duplicate()
	new_group.set_group_key(key)
	items_container.add_child(new_group)
	new_group.show()
	_item_groups[key] = new_group
	return new_group

func list_sub_group_containers()->Array[InventorySubGroupContainer]:
	var out_list:Array[InventorySubGroupContainer] = []
	for key in _item_groups.keys():
		var group:InventorySubGroupContainer = _item_groups[key]
		out_list.append(group)
	return out_list


func _on_inv_item_button_down(button:InventoryItemButton):
	var offset = button.get_local_mouse_position()
	item_button_down.emit(event_context, button._item_id, -1, offset)
	
func _on_inv_item_button_up(button:InventoryItemButton):
	var item = button.get_item()
	var offset = button.get_local_mouse_position()
	item_button_up.emit(event_context, button._item_id, -1)

func _mouse_enter_button(button:InventoryItemButton):
	mouse_enter_item.emit(event_context, button._item_id, -1)
func _mouse_exit_button(button:InventoryItemButton):
	mouse_exit_item.emit(event_context, button._item_id, -1)

func on_mouse_enter_inventory_box():
	inventory_box_highlight.show()
	mouse_enter_item.emit(event_context, null, -1)

func on_mouse_exit_inventory_box():
	inventory_box_highlight.hide()
	mouse_exit_item.emit(event_context, null, -1)

func clear_forced_filters(refilter:bool=true):
	_sub_filters.clear()
	_forced_filters.clear()
	if refilter:
		filter_option_button.load_options("All")
		_refilter()

# Set the current context of the character menu (Pages, Equipment, Supplies)
func set_character_menu_context(context:String, refilter:bool=true):
	_menu_context = context
	if refilter:
		_refilter()

func add_forced_filter(tags, refilter:bool=true):
	if tags is String:
		tags = [tags]
	for tag in tags:
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
	var cur_actor = CharacterMenuControl.Instance._actor
	var cur_title = ''
	if cur_actor:
		cur_title = cur_actor.get_title()
	for group_key in _item_groups.keys():
		var group:InventorySubGroupContainer = _item_groups[group_key]
		if not should_group_be_visible(group_key, group, cur_title):
			group.hide()
			continue
		var any_buttons_visible = false
		for button:InventoryItemButton in group.buttons.values():
			var item = button.get_item()
			if should_item_be_visible(item, cur_title):
				if not button.visible:
					button.show()
				any_buttons_visible = true
			else:
				button.hide()
		if any_buttons_visible:
			group.show()
		else:
			group.hide()
	await get_tree().process_frame
	scroll_bar.calc_bar_size()
	#filter_option_button.load_options()

func should_group_be_visible(group_key:String, group:InventorySubGroupContainer, cur_title:String)->bool:
	var tokens = group_key.split(":")
	if not tokens.has(_menu_context):
		return false
	if tokens.has("Page"):
		if tokens.has("TitleLocked") and (cur_title != '' and not tokens.has(cur_title)):
			return false
			
	return true

func should_item_be_visible(item:BaseItem, cur_title:String):
	var count = PlayerInventory.get_item_stack_count(item.ItemKey)
	if count == 0:
		return false
	if item is BasePageItem:
		if item.is_shareble():
			var source_title = item.get_source_title()
			if source_title == cur_title and source_title != '':
				return false
			
	var tags = item.get_tags()
	for f_filter in _forced_filters:
		if f_filter.begins_with("Not:"):
			if tags.has(f_filter.trim_prefix("Not:")):
				return false
		elif not tags.has(f_filter):
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
		return ["All", "Passive", "Action", "Movement", "Tactic", "Spell"]
	if _forced_filters.has("Consumable"):
		return ["All", "Potion", "Bomb"]
	return []
