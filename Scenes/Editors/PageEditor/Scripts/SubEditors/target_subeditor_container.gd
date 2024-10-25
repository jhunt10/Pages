@tool
class_name TargetSubEditorContainer
extends BaseListSubEditorConatiner

@export var options_button:LoadedOptionButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	if Engine.is_editor_hint(): return
	#add_button.pressed.connect(on_add_button_pressed)
	options_button.get_options_func = get_target_options
	options_button.item_selected.connect(on_option_selected)
	#target_edit_entry_container._parent_target_subeditor = self

func get_target_options()->Array:
	return get_key_to_input_mapping().keys()
	
	
func on_option_selected(index:int):
	var key = options_button.get_current_option_text()
	set_editing_entry(key)

func create_new_entry(key:String, data:Dictionary):
	var new_key = super(key, data)
	set_editing_entry(new_key)

func set_editing_entry(key:String):
	var entries = get_key_to_input_mapping() 
	for entry_key in entries.keys():
		entries[entry_key].visible = entry_key == key
	options_button.load_options(key)
	

func on_entry_key_change(old_key:String, new_key:String):
	super(old_key, new_key)
	if options_button.get_current_option_text() == old_key:
		options_button.load_options(new_key)
	
#func clear():
	#_loaded_data.clear()
	#
#
#func has_change():
	##TODO
	#return false
#
#func load_data(object_key:String, data:Dictionary):
	#_loaded_data = data.duplicate(true)
	#if data.size() > 0:
		#load_entry(data.keys()[0])
#
#func load_entry(key:String):
	#var data = _loaded_data.get(key, {})
	#target_edit_entry_container.load_data(key, data)
	#options_button.load_options(key)
#

#func lose_focus_if_has():
	#super()
	#target_edit_entry_container.lose_focus_if_has()
		
#
#func on_entry_key_changed(old_key, new_key):
	#var current_data = _loaded_data.get(old_key, {})
	#_loaded_data.erase(old_key)
	#if new_key != "":
		#_loaded_data[new_key] = current_data
	#options_button.load_options(new_key)
#
#func delete_key(key):
	#_loaded_data.erase(key)
	#if options_button.get_current_option_text() == key:
		#options_button.load_options("")
#
#func on_add_button_pressed():
	#load_entry("")
