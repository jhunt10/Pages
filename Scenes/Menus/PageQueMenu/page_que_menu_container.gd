@tool
class_name PageQueMenuContainer
extends BackPatchContainer

@export var close_button:Button
@export var page_que_slots_container:PageQueSlotsContainer
@export var details_container:PageDetailsContainer
@export var page_inventory_container:PageInventoryContainer
@export var mouse_over_control:PageMenuMouseControl

var _dragging_page:PageItemAction
var _drag_icon_offset:Vector2 = Vector2.ZERO

var _actor:BaseActor

func _ready() -> void:
	super()
	if Engine.is_editor_hint(): return
	close_button.pressed.connect(close_menu)
	page_inventory_container.page_button_enter.connect(on_page_inventory_button_entered)
	page_que_slots_container.page_slot_pressed.connect(on_page_slot_pressed)
	page_inventory_container.page_button_clicked.connect(on_page_inventory_button_pressed)
	page_inventory_container.page_button_down.connect(set_dragging_page)

func _process(delta: float) -> void:
	super(delta)
	if Engine.is_editor_hint(): return
	mouse_over_control.position = get_local_mouse_position() - _drag_icon_offset
	if _dragging_page and !Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		dragging_item_released()

func set_actor(actor:BaseActor):
	if _actor:
		_actor.pages.pages_changed.disconnect(on_action_list_change)
	_actor = actor
	page_que_slots_container.set_actor(_actor)
	page_inventory_container.set_actor(_actor)
	_actor.pages.pages_changed.connect(on_action_list_change)

func close_menu():
	self.queue_free()

func on_action_list_change():
	page_que_slots_container.set_actor(_actor)

func clear_drag_item():
	_dragging_page = null
	mouse_over_control.set_dragging_page(null)
	#page_que_slots_container.clear_highlights()

func set_dragging_page(page:PageItemAction, button:InventoryPageButton):
	_dragging_page = page
	details_container.set_page(_dragging_page)
	mouse_over_control.set_dragging_page(_dragging_page)
	mouse_over_control.drag_page_control.position = Vector2(-16,-16)

func dragging_item_released():
	var arr = page_que_slots_container.get_mouse_over_page_tags_and_index()
	var mouse_over_tags = arr[0]
	var mouse_over_index = arr[1]
	if mouse_over_index < 0:
		clear_drag_item()
		return
	_actor.pages.set_page_for_slot(mouse_over_tags, mouse_over_index, _dragging_page)
	clear_drag_item()


func on_page_slot_pressed(page_tags:String, index:int):
	_actor.pages.set_page_for_slot(page_tags,index,null)

func on_page_inventory_button_entered(page:PageItemAction):
	if !_dragging_page:
		details_container.set_page(page)

func on_page_inventory_button_pressed(page:PageItemAction):
	print("Inventory Page Button Pressed:  " + page.ActionKey)
	if _actor.pages.has_page(page.ActionKey):
		_actor.pages.remove_page(page.ActionKey)
	else:
		_actor.pages.try_add_page(page)
	#var has_index = _actor.pages._page_slots.find(page.ActionKey)
	#if has_index >= 0:
		#print("Cleaing Index: " + str(has_index))
		#_actor.pages.set_page_for_slot("Any", has_index, null)
	#else:
		#var open_slot = _actor.pages._page_slots.find(null)
		#print("Open Index: " + str(open_slot))
		#if open_slot >= 0:
			#_actor.pages.set_page_for_slot("Any", open_slot, page)
