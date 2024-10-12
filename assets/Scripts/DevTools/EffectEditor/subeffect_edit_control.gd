class_name SubEffectEditControl
extends Control

static var EFFECT_SCRIPTS_PATH = "res://assets/Scripts/Effects/SubEffects"

@onready var add_button:Button = $VBoxContainer/HBoxContainer/Button
@onready var premade_subeffect_entry:SubEffectEntryControl = $VBoxContainer/SubEffectEntryControl
@onready var entry_container:VBoxContainer = $VBoxContainer/ScrollContainer/VBoxContainer

var _sub_effect_entries:Dictionary = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	printerr("SubEffect edit ready")
	add_button.pressed.connect(create_new_entry)
	premade_subeffect_entry.visible = false
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func lose_focus_if_has():
	for sub:SubEffectEntryControl in _sub_effect_entries.values():
			sub.lose_focus_if_has()

func create_new_entry(key:String="", data:Dictionary={}):
	var new_entry:SubEffectEntryControl = premade_subeffect_entry.duplicate()
	entry_container.add_child(new_entry)
	new_entry.visible = true
	if key == "":
		key = "SubEffect" + str(_sub_effect_entries.size())
	new_entry.load_subeffect_data(key, data)
	_sub_effect_entries[key] = new_entry

func load_effect_data(data:Dictionary={}):
	for entry in _sub_effect_entries.values():
		entry.queue_free()
	_sub_effect_entries.clear()
	if data.keys().has("SubEffects"):
		for sub_key in data['SubEffects'].keys():
			create_new_entry(sub_key, data['SubEffects'][sub_key])

func save_effect_data()->Dictionary:
	var out_dict = {}
	for entry:SubEffectEntryControl in _sub_effect_entries.values():
		var real_key = entry.key_line_edit.text
		out_dict[real_key] = entry.save_effect_data()
	return out_dict
		
		
