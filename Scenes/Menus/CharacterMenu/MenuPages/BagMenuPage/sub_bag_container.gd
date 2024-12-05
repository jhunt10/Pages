class_name SubBagContainer
extends VBoxContainer

signal item_button_down(tag, index, offset)
signal item_button_up(tag, index)
signal mouse_enter_item(tag, index)
signal mouse_exit_item(tag, index)

@export var title_label:Label
var _tag:String
var _buttons:Array = []
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func set_sub_bag_data(tag, slots):
	_tag = tag
	title_label.text = tag
	for i in range(slots.size()):
		var new_button = load("res://Scenes/Menus/CharacterMenu/MenuPages/BagMenuPage/bag_item_slot_button.tscn").instantiate()
		new_button.button.button_down.connect(on_slot_button_down.bind(i))
		new_button.button.button_up.connect(on_slot_button_up.bind(i))
		new_button.button.mouse_entered.connect(on_slot_button_mouse_enter.bind(i))
		new_button.button.mouse_exited.connect(on_slot_button_mouse_exit.bind(i))
		var backgrund_type = "Single"
		if slots.size() > 1:
			if i == 0: backgrund_type = "Top"
			elif i == slots.size() -1: backgrund_type = "Bottom"
			else: backgrund_type = "Middle"
		new_button.set_key(slots[i], backgrund_type)
		self.add_child(new_button)
		_buttons.append(new_button)
		new_button.visible = true

func clear_highlights():
	for button in _buttons:
		button.hide_highlight()

func highlight_slot(index):
	if index >= 0 and index < _buttons.size():
		_buttons[index].show_highlight()

			
func on_slot_button_down(index:int):
	var button = _buttons[index]
	var offset = button.get_local_mouse_position()
	item_button_down.emit(_tag, index, offset)
func on_slot_button_up(index:int):
	item_button_up.emit(_tag, index)

func on_slot_button_mouse_enter(index:int):
	mouse_enter_item.emit(_tag, index)
func on_slot_button_mouse_exit(index:int):
	mouse_exit_item.emit(_tag, index)
