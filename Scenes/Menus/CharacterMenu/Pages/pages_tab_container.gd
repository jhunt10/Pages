class_name CharacterMenu_PagesTab
extends BaseCharacterSubMenu

@export var premade_page_set:PageSlotSetContainer
@export var sets_container:VBoxContainer
@export var premade_page_button:PageSlotButton

var _sub_containers:Dictionary = {}
var sub_book_pages:Array = []

func _ready() -> void:
	super()
	premade_page_set.hide()

func get_item_holder()->BaseItemHolder:
	if _actor:
		return _actor.pages
	return null

func sync():
	super()

func build_item_slots():
	for container in _sub_containers.values():
		container.queue_free()
	_sub_containers.clear()
	item_slot_buttons.clear()
	
	#var title_page:BasePageItem = _actor.pages.get_item_in_slot(0)
	#if title_page:
		#title_label.text = title_page.get_display_name()
	#item_slot_buttons.append(title_page_button)
	
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
		elif slot_key == "BasePassives" or slot_key == 'BaseActions':
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
