class_name PageMenuPageControl
extends BaseCharacterSubMenu

@export var title_label:Label
@export var title_page_button:PageSlotButton

@export var action_input_preview:ActionInputPreviewContainer
@export var premade_page_set:PageSlotSetContainer
@export var sets_container:VBoxContainer
@export var premade_page_button:PageSlotButton
@export var slot_width:int 
@export var scroll_bar:CustScrollBar


@export var name_label:Label
@export var level_label:Label
@export var exp_bar:ExpBarControl

var _sub_containers:Dictionary = {}
var sub_book_pages:Array = []
var max_hight = 278

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#premade_sub_container.visible = false
	premade_page_set.hide()
	#title_label._size_dirty = true

func get_item_holder()->BaseItemHolder:
	if _actor:
		return _actor.pages
	return null

func show_menu_page():
	super()
	scroll_bar.calc_bar_size()

func sync():
	if _actor:
		name_label.text = _actor.get_display_name()
		level_label.text = str(_actor.stats.get_stat(StatHelper.Level, 0))
		exp_bar.set_actor(_actor)
	super()

func build_item_slots():
	for container in _sub_containers.values():
		container.queue_free()
	_sub_containers.clear()
	item_slot_buttons.clear()
	
	var title_page:BasePageItem = _actor.pages.get_item_in_slot(0)
	if title_page:
		title_label.text = title_page.get_display_name()
	item_slot_buttons.append(title_page_button)
	
	var slot_set:PageSlotSetContainer = null
	var last_display_name = ''
	var raw_index = 1
	var slot_set_datas = _actor.pages.slot_sets_data
	var set_names = []
	for slot_set_data in slot_set_datas:
		if not set_names.has(slot_set_data.get("DisplayName", "")):
			set_names.append(slot_set_data.get("DisplayName", ""))
	var has_extra_slots = false# set_names.size() > 3
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
			slot_set.buttons_container.add_child(new_button)
			new_button.is_clipped = req_tags.has("Passive")
			new_button.show()
			item_slot_buttons.append(new_button)
			raw_index += 1

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

func remove_item_from_slot(item:BaseItem, _index:int):
	ItemHelper.try_transfer_item_from_holder_to_inventory(item, _actor.pages)

func try_place_item_in_slot(item:BaseItem, index:int):
	var res = ItemHelper.try_transfer_item_from_inventory_to_holder(item, _actor.pages, index, true)
	if res == '':
		return true
	return false

func try_move_item_to_slot(_item:BaseItem, from_index:int, to_index:int):
	ItemHelper.swap_item_holder_slots(_actor.items, from_index, to_index)
