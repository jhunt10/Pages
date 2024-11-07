@tool
class_name PageQueMenuContainer
extends BackPatchContainer

@export var page_que_slots_container:PageQueSlotsContainer
@export var details_container:PageDetailsContainer
@export var page_inventory_container:PageInventoryContainer

var _actor:BaseActor

func _ready() -> void:
	super()
	if Engine.is_editor_hint(): return
	page_inventory_container.page_button_enter.connect(details_container.set_page)
	page_que_slots_container.page_slot_pressed.connect(on_page_slot_pressed)
	page_inventory_container.page_button_clicked.connect(on_page_inventory_button_pressed)

func set_actor(actor:BaseActor):
	if _actor:
		_actor.Que.action_list_changed.disconnect(on_action_list_change)
	_actor = actor
	page_que_slots_container.set_actor(_actor)
	_actor.Que.action_list_changed.connect(on_action_list_change)

func close_menu():
	self.queue_free()

func on_action_list_change():
	page_que_slots_container.set_actor(_actor)

func on_page_slot_pressed(index:int):
	print("Page Que Slot Pressed: " + str(index))
	_actor.Que.set_page_for_slot(index,null)

func on_page_inventory_button_pressed(page:BaseAction):
	print("Inventory Page Button Pressed:  " + page.ActionKey)
	var has_index = _actor.Que._page_slots.find(page.ActionKey)
	if has_index >= 0:
		print("Cleaing Index: " + str(has_index))
		_actor.Que.set_page_for_slot(has_index, null)
	else:
		var open_slot = _actor.Que._page_slots.find(null)
		print("Open Index: " + str(open_slot))
		if open_slot >= 0:
			_actor.Que.set_page_for_slot(open_slot, page)
