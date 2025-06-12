@tool
class_name PageQueSlotsContainer
extends BackPatchContainer

signal page_slot_pressed(page_tags:String, index:int)

@export var premade_page_tag_slots_entry:PageTagSlotsEntry
@export var premade_page_slot_button:PageQueSlotButton
@export var page_tag_slots_entries_container:Container

var _actor:BaseActor

func _ready() -> void:
	#super()
	if Engine.is_editor_hint(): return
	premade_page_slot_button.visible = false
	premade_page_tag_slots_entry.visible = false

func set_actor(actor:BaseActor):
	for child in page_tag_slots_entries_container.get_children():
		child.queue_free()
	_actor = actor
	var action_key_list:Array = actor.get_action_key_list()
	var pages = actor.pages.get_pages_per_page_tags()
	for page_tags in pages.keys():
		_create_new_page_tags_entry(page_tags, pages[page_tags])
	pass

func _create_new_page_tags_entry(page_tags:String, pages:Array):
	var new_slot_entry:PageTagSlotsEntry = premade_page_tag_slots_entry.duplicate()
	new_slot_entry.visible = true
	new_slot_entry.title.text = page_tags
	for index in range(pages.size()):
		var page:PageItemAction = null
		if pages[index]:
			page = ItemLibrary.get_item(pages[index])
		var new_slot = _create_page_slots(page_tags, index,page)
		new_slot_entry.page_slots_container.add_child(new_slot)
	page_tag_slots_entries_container.add_child(new_slot_entry)

func _create_page_slots(page_tags:String, index:int, page:PageItemAction):
	var new_slot:PageQueSlotButton = premade_page_slot_button.duplicate()
	new_slot.visible = true
	if page:
		new_slot.set_page(page, _actor)
	new_slot.pressed.connect(on_page_slot_pressed.bind(page_tags, index))
	return new_slot

func on_page_slot_pressed(page_tags:String, index:int):
	page_slot_pressed.emit(page_tags, index)

func get_mouse_over_page_tags_and_index()->Array:
	var mouse_pos = get_global_mouse_position()
	if !page_tag_slots_entries_container.get_global_rect().has_point(mouse_pos):
		return ["", -1]
	for page_tag_entry:PageTagSlotsEntry in page_tag_slots_entries_container.get_children():
		var rect = page_tag_entry.get_global_rect()
		if rect.has_point(mouse_pos):
			var page_tags = page_tag_entry.title.text
			var index = 0
			for slot:PageQueSlotButton in  page_tag_entry.page_slots_container.get_children():
				if slot.get_global_rect().has_point(mouse_pos):
					return [page_tags, index]
				else: 
					index += 1
	return ["", -1]
	
