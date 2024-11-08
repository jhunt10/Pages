@tool
class_name EquipmentMenuContainer
extends BackPatchContainer

@export var mouse_over_control:EquipmentMenuMouseControl
@export var stats_display_container:StatsDisplayContainer
@export var equipment_display_container:EquipmentDisplayContainer
@export var inventory_container:InventoryContainer
@export var page_list_container:PageListContainer

var _allow_editing:bool = true
var _actor:BaseActor
var _dragging_item:BaseEquipmentItem
var _drag_icon_offset:Vector2 = Vector2.ZERO

var page_que_menu:PageQueMenuContainer

func _ready() -> void:
	super()
	if Engine.is_editor_hint(): return
	inventory_container.item_button_down.connect(set_dragging_item)
	if !ActorLibrary.Instance:
		ActionLibrary.new()
	var actor = ActorLibrary.get_actor("TestActor_ID")
	set_actor(actor)
	inventory_container.item_button_hover.connect(set_hover_item)
	inventory_container.item_button_hover_end.connect(clear_hover_item)
	inventory_container.item_button_clicked.connect(on_item_clicked)
	equipment_display_container.equipt_slot_pressed.connect(on_equipt_slot_clicked)

func _process(delta: float) -> void:
	super(delta)
	if Engine.is_editor_hint(): return
	mouse_over_control.position = get_local_mouse_position() - _drag_icon_offset
	if _dragging_item and !Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		dragging_item_released()

func _input(event: InputEvent) -> void:
	if Engine.is_editor_hint(): return
	if event is InputEventKey and (event as InputEventKey).keycode == KEY_ESCAPE and (event as InputEventKey).is_released():
		self.close_menu()

func close_menu():
	if page_que_menu:
		page_que_menu.close_menu()
		page_que_menu = null
	else:
		ActorLibrary.save_actors()
		ItemLibrary.save_items()
		self.queue_free()

func open_page_que_menu():
	if page_que_menu == null:
		page_que_menu = MainRootNode.Instance.open_page_menu(_actor)
	else:
		page_que_menu.set_actor(_actor)

func set_hover_item(item):
	mouse_over_control.set_hover_item(item)

func clear_hover_item():
	mouse_over_control.clear_message()

func set_actor(actor:BaseActor):
	_actor = actor
	equipment_display_container.set_actor(_actor)
	stats_display_container.set_actor(_actor)
	page_list_container.set_actor(_actor)

func clear_drag_item():
	_dragging_item = null
	mouse_over_control.set_dragging_item(null)
	equipment_display_container.clear_highlights()

func set_dragging_item(item:BaseItem, button:InventoryItemButton):
	_dragging_item = item
	mouse_over_control.set_dragging_item(item)
	mouse_over_control.drag_item_control.position = Vector2.ZERO - button.get_local_mouse_position()
	equipment_display_container.highlight_slots_of_type(_dragging_item.get_equipment_slot_type())

func dragging_item_released():
	var mouse_over_slot_index = equipment_display_container.get_mouse_over_slot_index()
	if mouse_over_slot_index < 0:
		clear_drag_item()
		return
	var slot_type = _actor.equipment.get_slot_equipment_type(mouse_over_slot_index)
	if _dragging_item.get_equipment_slot_type() == slot_type:
		_actor.equipment.equip_item_to_slot(mouse_over_slot_index, _dragging_item)
		set_actor(_actor)
	clear_drag_item()

func on_item_clicked(item:BaseItem):
	var equipment = (item as BaseEquipmentItem)
	if !equipment:
		return
	if equipment.get_equipt_to_actor_id() == _actor.Id:
		print("Is Equipt, clearing")
		equipment.clear_equipt_actor()
	else:
		print("Not Equipt, trying")
		_actor.equipment.try_equip_item(item, true)
	set_actor(_actor)

func on_equipt_slot_clicked(slot_index:int):
	if _actor.equipment.has_equipment_in_slot(slot_index):
		_actor.equipment.clear_slot(slot_index)
		set_actor(_actor)
