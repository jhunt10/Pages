class_name SaveLoadMenu
extends Control

@export var menu_title_label:Label
@export var save_load_button_label:Label
@export var premade_save_slot:SaveSlotContainer
@export var save_slot_new:SaveSlotContainer
@export var slots_container:VBoxContainer

@export var sel_save_name_label:Label
@export var sel_pretty_pic:TextureRect
@export var sel_save_details_container:Container
@export var sel_save_date_label:Label
@export var sel_save_loaction_label:Label
@export var sel_runtime_label:Label
@export var sel_party_container:PartyContainer

@export var save_mode:bool:
	set(val):
		if save_slot_new:
			if val: # Saving
				save_slot_new.show()
				menu_title_label.text = "Save Game"
				save_load_button_label.text = "Save"
			else:
				save_slot_new.hide()
				menu_title_label.text = "Load Game"
				save_load_button_label.text = "Load"
		save_mode = val

var save_slots:Dictionary = {}
var _cached_save_meta_data:Dictionary
var _selected_save_name

var _saving_data

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	premade_save_slot.visible = false
	read_existing_saves()
	save_mode = save_mode
	set_saving_data(null)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func set_saving_data(something):
	_saving_data = {
		"Location": "Another Place",
		"RunTime": 2000,
		"SaveDate": Time.get_datetime_string_from_system(false, true)
	}
	set_displayed_save_data("Saving...", _saving_data)

func read_existing_saves():
	for child in slots_container.get_children():
		if child is SaveSlotContainer and child != premade_save_slot:
			child.queue_free()
	save_slots.clear()
	_cached_save_meta_data = SaveLoadHandler.read_saves_meta_data()
	for save_name in _cached_save_meta_data.keys():
		create_save_slot_container(save_name, _cached_save_meta_data[save_name])

func create_save_slot_container(save_name:String, save_data:Dictionary):
	var save_date = save_data.get("SaveDate", "")
	
	var new_slot:SaveSlotContainer = premade_save_slot.duplicate()
	new_slot.date_time_label.text = save_date
	new_slot.name_label.text = save_name
	new_slot.mouse_entered.connect(on_mouse_enter_slot.bind(save_name))
	new_slot.mouse_exited.connect(on_mouse_exit_slot.bind(save_name))
	new_slot.button.pressed.connect(on_slot_pressed.bind(save_name))
	new_slot.show()
	save_slots[save_name] = new_slot
	slots_container.add_child(new_slot)

func on_mouse_enter_slot(save_name):
	var data = _cached_save_meta_data.get(save_name, {})
	set_displayed_save_data(save_name, data)

func on_mouse_exit_slot(save_name):
	if _saving_data:
		set_displayed_save_data("Saving...", _saving_data)
	else:
		clear_displayed_save_data() 
	pass

func on_slot_pressed(save_name):
	_selected_save_name = save_name
	pass

func set_displayed_save_data(save_name:String, data):
	sel_save_name_label.text = save_name
	sel_save_date_label.text = data.get("SaveDate", "")
	sel_save_loaction_label.text = data.get("Location", "")
	sel_runtime_label.text = str(data.get("RunTime", 0))
	sel_party_container.clear()
	var party = data.get("Party", {})
	for key in party.keys():
		sel_party_container.add_row(key, party[key])
	sel_pretty_pic.show()
	sel_save_details_container.show()

func clear_displayed_save_data():
	var data = _cached_save_meta_data.get(save_mode, {})
	sel_save_name_label.text = ""
	sel_save_date_label.text = ""
	sel_save_loaction_label.text = ""
	sel_runtime_label.text = ""
	sel_party_container.clear()
	sel_pretty_pic.hide()
	sel_save_details_container.hide()
		
