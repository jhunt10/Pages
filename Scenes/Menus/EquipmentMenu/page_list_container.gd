@tool
class_name PageListContainer
extends BackPatchContainer

signal page_slot_pressed(index:int)

@export var equipment_menu_container:EquipmentMenuContainer
@export var page_menu_button:Button
@export var premade_page_slot_button:PageQueSlotButton
@export var page_slots_container:HBoxContainer

var _actor:BaseActor

func _ready() -> void:
	#super()
	if Engine.is_editor_hint(): return
	premade_page_slot_button.visible = false
	page_menu_button.pressed.connect(equipment_menu_container.open_page_que_menu)

func set_actor(actor:BaseActor):
	if _actor and _actor.pages.pages_changed.is_connected(_sync_pages):
		_actor.pages.pages_changed.disconnect(_sync_pages)
	_actor = actor
	_actor.pages.pages_changed.connect(_sync_pages)
	_sync_pages()

func _sync_pages():
	for child in page_slots_container.get_children():
		child.queue_free()
	var action_key_list:Array = _actor.get_action_list()
	var max_page_count = _actor.pages.get_max_page_count()
	for index in range(max_page_count):
		var page:BaseAction = null
		if index < action_key_list.size() and action_key_list[index]:
			page = ActionLibrary.get_action(action_key_list[index])
		_create_slots(index, page)
	pass

func _create_slots(index:int, page:BaseAction):
	var new_slot:PageQueSlotButton = premade_page_slot_button.duplicate()
	page_slots_container.add_child(new_slot)
	new_slot.visible = true
	if page:
		new_slot.set_page(page)
	new_slot.pressed.connect(on_page_slot_pressed.bind(index))

func on_page_slot_pressed(index:int):
	page_slot_pressed.emit(index)
