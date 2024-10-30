@tool
class_name InventoryContainer
extends BackPatchContainer

signal item_button_down(item:BaseItem, button:InventoryItemButton)
signal item_button_hover(item:BaseItem)
signal item_button_hover_end
signal item_button_clicked(item:BaseItem)

@export var items_container:FlowContainer
@export var premade_item_button:InventoryItemButton

var _mouse_in_button:InventoryItemButton
var _item_buttons:Dictionary = {}
var _hover_delay:float = 0.3
var _hover_timer:float
var _click_delay:float = 0.2
var _click_timer:float

func _ready() -> void:
	premade_item_button.visible = false
	if !ItemLibrary.Instance:
		ItemLibrary.new()
	build_item_list()

func _process(delta: float) -> void:
	if _mouse_in_button and _hover_timer > 0:
		_hover_timer -= delta
		if _hover_timer < 0:
			var item = ItemLibrary.get_item(_mouse_in_button._item_id)
			if item:
				item_button_hover.emit(item)
	if _click_timer > 0:
		_click_timer -= delta

func build_item_list():
	for button in _item_buttons.values():
		button.queue_free()
	_item_buttons.clear()
	
	for item in ItemLibrary.list_all_items():
		_build_button(item)

func _build_button(item:BaseItem):
	var new_button:InventoryItemButton = premade_item_button.duplicate()
	items_container.add_child(new_button)
	new_button.set_item(item)
	_item_buttons[item.Id] = new_button
	new_button.visible = true
	new_button.button_down.connect(_on_item_button_down.bind(new_button))
	new_button.button_up.connect(_on_item_button_up.bind(new_button))
	new_button.mouse_entered.connect(_mouse_enter_button.bind(new_button))
	new_button.mouse_exited.connect(_mouse_exit_button.bind(new_button))

func _on_item_button_down(button:InventoryItemButton):
	var item = ItemLibrary.get_item(button._item_id)
	item_button_down.emit(item, button)
	_click_timer = _click_delay
func _on_item_button_up(button:InventoryItemButton):
	if _click_timer > 0:
		var item = ItemLibrary.get_item(button._item_id)
		item_button_clicked.emit(item)
	_click_timer = 0
	

func _mouse_enter_button(button:InventoryItemButton):
	_mouse_in_button = button
	_hover_timer = _hover_delay
func _mouse_exit_button(button:InventoryItemButton):
	_mouse_in_button = null
	_hover_timer = -1
	item_button_hover_end.emit()
	
