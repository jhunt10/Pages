class_name PageSlotSetContainer
extends VBoxContainer

#signal item_button_down(index, offset)
#signal item_button_up(index)
#signal mouse_enter_item(index)
#signal mouse_exit_item(index)

@export var title_label:Label
@export var buttons_container:FlowContainer

##@export var background_tilemap:TileMapLayer
#var page_slots_containers:Array = []
#var _slot_set_key:String
#var _buttons:Dictionary = {}
#
## Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#pass # Replace with function body.
#
#
## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass
#
#func estimate_hight()->float:
	#return title_label.size.y + (page_slots_containers.size() * 64)
#
#func set_slot_set_data(actor:BaseActor, page_holder:PageHolder, slot_set_data:Dictionary):
	#_slot_set_key = slot_set_data['Key']
	#title_label.text = slot_set_data['DisplayName']
	#var index_offset = slot_set_data['IndexOffset']
	#var slot_count = slot_set_data['Count']
	#for sub_index in range(slot_count):
		#var raw_index = sub_index + index_offset
		#var new_button = load("res://Scenes/Menus/CharacterMenu/MenuPages/PageMenuPage/page_slot_button.tscn").instantiate()
		#new_button.button.button_down.connect(on_slot_button_down.bind(raw_index))
		#new_button.button.button_up.connect(on_slot_button_up.bind(raw_index))
		#new_button.button.mouse_entered.connect(on_slot_button_mouse_enter.bind(raw_index))
		#new_button.button.mouse_exited.connect(on_slot_button_mouse_exit.bind(raw_index))
		#buttons_container.add_child(new_button)
		#new_button.name = "PageSlot" + str(sub_index)
		#new_button.is_clipped = _slot_set_key == "Passive"
		#_buttons[raw_index] = new_button
		#
		#var item_id = page_holder.get_item_id_in_slot(raw_index)
		#if item_id:
			#new_button.set_key(actor, item_id)
#
#func clear_highlights():
	#for button in _buttons.values():
		#button.hide_highlight()
#
#func highlight_slot(index):
	#if _buttons.keys().has(index):
		#_buttons[index].show_highlight()
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
