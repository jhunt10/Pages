class_name SaveLoadMenu
extends Control

const NEW_SAVE_KEY = "@@NEW_SAVE@@"

@export var scale_control:Control
@export var close_button:Button
@export var scroll_bar:CustScrollBar
@export var menu_title_label:Label
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

@export var message_box:SaveLoadMessageBox
@export var save_popup:SaveAsBox
@export var save_button:Button
@export var save_button_label:Label
@export var save_button_highlight:NinePatchRect

@export var save_mode:bool:
	set(val):
		save_mode = val

var save_slots:Dictionary = {}
var _cached_save_meta_data:Dictionary
var _selected_save_name
static var _last_save_load_name
var _saving_data

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	premade_save_slot.visible = false
	if save_mode:
		set_saving_data(StoryState.Instance)
		print("Open Menu in Save Mode")
		save_slot_new.show()
		save_slots[NEW_SAVE_KEY] = save_slot_new
		save_slot_new.button.pressed.connect(_on_slot_pressed.bind(NEW_SAVE_KEY))
		menu_title_label.text = "Save Game"
		save_button_label.text = "Save"
	else:
		print("Open Menu in Load Mode")
		save_slot_new.hide()
		menu_title_label.text = "Load Game"
		save_button_label.text = "Load"
		
	save_popup.hide()
	message_box.hide()
	clear_displayed_save_data()
	read_existing_saves()
	if _last_save_load_name != null:
		_on_slot_pressed(_last_save_load_name)
	elif save_mode:
		_on_slot_pressed(NEW_SAVE_KEY)
	close_button.pressed.connect(on_close_menu)
	save_button.mouse_entered.connect(save_button_highlight.show)
	save_button.mouse_exited.connect(save_button_highlight.hide)
	save_button.pressed.connect(_on_save_button)
	save_popup.on_confirmed.connect(_on_save_as_confirmed)
	message_box.message_done.connect(_on_message_box_done)
	pass # Replace with function body.

func on_close_menu():
	self.queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func set_saving_data(story_state:StoryState):
	_saving_data = SaveLoadHandler._build_save_meta_data("New Save", story_state)
	_cached_save_meta_data[NEW_SAVE_KEY] = _saving_data
	set_displayed_save_data("New Save", _saving_data)

func _on_message_box_done():
	if message_box.message_label.text == "Saving Game...":
		message_box.show_message("Game Saved!", 0.5)
	elif message_box.message_label.text == "Game Saved!":
		self.queue_free()

func _on_save_as_confirmed(save_name):
	message_box.show_message("Saving Game...", 0.5)
	_last_save_load_name = save_name
	SaveLoadHandler.write_save_data(save_name, StoryState.Instance)
	pass

func _on_save_button():
	if save_mode: # Saving Game
		var save_name = _selected_save_name
		if _selected_save_name == NEW_SAVE_KEY:
			save_name = suggest_new_save_name()
		save_popup.name_input.text = save_name
		save_popup.show()
	else: # Loading Game
		if !_selected_save_name:
			return
		var data = _cached_save_meta_data.get(_selected_save_name, {})
		var save_id = data['SaveId']
		SaveLoadHandler.load_save_data(save_id)
		_last_save_load_name = _selected_save_name
		self.queue_free()

func read_existing_saves():
	for child in slots_container.get_children():
		if child is SaveSlotContainer and child != premade_save_slot and child != save_slot_new:
			child.queue_free()
	save_slots.clear()
	_cached_save_meta_data = SaveLoadHandler.read_saves_meta_data()
	if save_mode:
		save_slots[NEW_SAVE_KEY] = save_slot_new
		_cached_save_meta_data[NEW_SAVE_KEY] = _saving_data
	for save_name in _cached_save_meta_data.keys():
		if save_name == NEW_SAVE_KEY:
			continue
		create_save_slot_container(save_name, _cached_save_meta_data[save_name])
	scroll_bar.calc_bar_size()

func create_save_slot_container(save_name:String, save_data:Dictionary):
	var save_date = save_data.get("SaveDate", "")
	
	var new_slot:SaveSlotContainer = premade_save_slot.duplicate()
	new_slot.date_time_label.text = save_date
	new_slot.name_label.text = save_name
	new_slot.mouse_entered.connect(_on_mouse_enter_slot.bind(save_name))
	new_slot.mouse_exited.connect(_on_mouse_exit_slot.bind(save_name))
	new_slot.button.pressed.connect(_on_slot_pressed.bind(save_name))
	new_slot.show()
	save_slots[save_name] = new_slot
	slots_container.add_child(new_slot)

func _on_mouse_enter_slot(save_name):
	if _selected_save_name == null:
		var slot:SaveSlotContainer = save_slots[save_name]
		slot.highlight.show()
		var data = _cached_save_meta_data.get(save_name, {})
		set_displayed_save_data(save_name, data)

func _on_mouse_exit_slot(save_name):
	if _selected_save_name != save_name:
		var slot:SaveSlotContainer = save_slots[save_name]
		slot.highlight.hide()
		if not _selected_save_name:
			clear_displayed_save_data()

func _on_slot_pressed(save_name):
	if _selected_save_name != null:
		var old_slot:SaveSlotContainer = save_slots[_selected_save_name]
		old_slot.highlight.hide()
	_selected_save_name = save_name
	if not save_slots.has(save_name):
		return
	var slot:SaveSlotContainer = save_slots[save_name]
	slot.highlight.show()
	var data = _cached_save_meta_data.get(save_name, {})
	set_displayed_save_data(save_name, data)

func set_displayed_save_data(save_name:String, data):
	sel_save_name_label.text = data.get("SaveName", save_name)
	sel_save_date_label.text = data.get("SaveDate", "")
	sel_save_loaction_label.text = data.get("Location", "")
	sel_runtime_label.text = str(data.get("RunTime", 0))
	sel_party_container.clear()
	var party = data.get("Party", {})
	for key in party.keys():
		sel_party_container.add_row(key, party[key])
	sel_pretty_pic.show()
	sel_save_details_container.show()
	if save_mode:
		if save_name != NEW_SAVE_KEY:
			save_button_label.text = "Overwrite"
		else:
			save_button_label.text = "Save"

func clear_displayed_save_data():
	var data = _cached_save_meta_data.get(save_mode, {})
	sel_save_name_label.text = ""
	sel_save_date_label.text = ""
	sel_save_loaction_label.text = ""
	sel_runtime_label.text = ""
	sel_party_container.clear()
	sel_pretty_pic.hide()
	sel_save_details_container.hide()

func suggest_new_save_name()->String:
	var base_name = "Save"
	if _last_save_load_name:
		base_name = _last_save_load_name
	var new_name = base_name
	var index = 1
	while _cached_save_meta_data.keys().has(new_name):
		new_name = base_name+" " +str(index)
		index += 1
		if index >= 100:
			return "WHY SO MANY SAVES?"
	return new_name
