@tool
class_name EquipmentMenuContainer
extends BackPatchContainer

@export var mouse_over_control:EquipmentMenuMouseControl
@export var equipment_display_container:EquipmentDisplayContainer
@export var inventory_container:InventoryContainer

var _actor:BaseActor
var _dragging_item:BaseEquipmentItem
var _drag_icon_offset:Vector2 = Vector2.ZERO

func _ready() -> void:
	super()
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
	mouse_over_control.position = get_local_mouse_position() - _drag_icon_offset
	if _dragging_item and !Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		dragging_item_released()

func set_hover_item(item):
	mouse_over_control.set_hover_item(item)

func clear_hover_item():
	mouse_over_control.clear_message()

func set_actor(actor:BaseActor):
	_actor = actor
	equipment_display_container.set_actor(_actor)

func clear_drag_item():
	_dragging_item = null
	mouse_over_control.set_dragging_item(null)
	equipment_display_container.clear_highlights()

func set_dragging_item(item:BaseItem, button:InventoryItemButton):
	_dragging_item = item
	mouse_over_control.set_dragging_item(item)
	mouse_over_control.drag_item_control.position = Vector2.ZERO - button.get_local_mouse_position()
	equipment_display_container.highlight_slot(_dragging_item.get_equip_slot())

func dragging_item_released():
	var mouse_over_slot = equipment_display_container.get_mouse_over_slot()
	if  mouse_over_slot != null and _dragging_item and _dragging_item.get_equip_slot() == mouse_over_slot:
		_actor.equipment._set_equipment(mouse_over_slot, _dragging_item)
		equipment_display_container.set_actor(_actor)
	clear_drag_item()

func on_item_clicked(item:BaseItem):
	var slot = (item as BaseEquipmentItem).get_equip_slot()
	_actor.equipment._set_equipment(slot, item)
	equipment_display_container.set_actor(_actor)

func on_equipt_slot_clicked(slot:BaseEquipmentItem.EquipmentSlots):
	if _actor.equipment.has_item_in_slot(slot):
		_actor.equipment.clear_slot(slot)
		equipment_display_container.set_actor(_actor)
		
