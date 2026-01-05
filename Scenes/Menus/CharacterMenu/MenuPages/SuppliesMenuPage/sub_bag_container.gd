class_name SubBagContainer
extends VBoxContainer

signal item_button_down(index, offset)
signal item_button_up(index)
signal mouse_enter_item(index)
signal mouse_exit_item(index)

@export var title_label:Label
var _slot_set_key:String
var _buttons:Dictionary = {}

func set_sub_bag_data(holder:BaseItemHolder, slot_set_data:Dictionary):
	_slot_set_key = slot_set_data['Key']
	title_label.text = slot_set_data.get("DisplayName")
	var index_offset = slot_set_data['IndexOffset']
	var slot_count = slot_set_data['Count']
	for index in range(slot_count):
		var raw_index = index_offset + index
		var new_button = load("res://Scenes/Menus/CharacterMenu/MenuPages/SuppliesMenuPage/supplies_menu_item_slot_button.tscn").instantiate()
		#new_button.button.button_down.connect(on_slot_button_down.bind(raw_index))
		#new_button.button.button_up.connect(on_slot_button_up.bind(raw_index))
		#new_button.button.mouse_entered.connect(on_slot_button_mouse_enter.bind(raw_index))
		#new_button.button.mouse_exited.connect(on_slot_button_mouse_exit.bind(raw_index))
		var backgrund_type = "Single"
		if slot_count > 1:
			if index == 0: backgrund_type = "Top"
			elif index == slot_count -1: backgrund_type = "Bottom"
			else: backgrund_type = "Middle"
		new_button.set_background_type(backgrund_type)
		self.add_child(new_button)
		_buttons[raw_index] = new_button
		new_button.visible = true

func clear_highlights():
	for button in _buttons.values():
		button.hide_highlight()

func highlight_slot(index):
	if _buttons.keys().has(index):
		_buttons[index].show_highlight()
#
			#
#func on_slot_button_down(index:int):
	#var button = _buttons[index]
	#var offset = button.get_local_mouse_position()
	#item_button_down.emit(index, offset)
	#
#func on_slot_button_up(index:int):
	#item_button_up.emit(index)
#
#func on_slot_button_mouse_enter(index:int):
	#mouse_enter_item.emit(index)
	#
#func on_slot_button_mouse_exit(index:int):
	#mouse_exit_item.emit(index)
