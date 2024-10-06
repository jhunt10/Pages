class_name SubActionEntryControl
extends Control

static var SUB_ACTIONS_PATH = "res://assets/Scripts/Actions/SubActions/"

signal index_changed

@onready var index_input:SpinBox = $VBoxContainer/ScriptInput/FrameInput
@onready var script_drop_options:OptionButton = $VBoxContainer/ScriptInput/ScriptButton
@onready var props_container:VBoxContainer = $VBoxContainer/PropsContainer
@onready var premade_option_prop_input:SubActionPropInputControl = $VBoxContainer/PropsContainer/SubActionPropertyControl

var prop_inputs:Dictionary = {}
var real_script:String = ''
var subaction_data:Dictionary = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	script_drop_options.item_selected.connect(script_selected)
	var sub_scripts = get_sub_actions_scripts()
	for script in sub_scripts:
		script_drop_options.add_item(script)
	premade_option_prop_input.visible = false
	index_input.get_line_edit().focus_exited.connect(on_index_lose_focus)

func on_index_lose_focus():
	index_changed.emit()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func lose_focus_if_has():
	if index_input.has_focus():
		index_input.release_focus()
	var line_edit = index_input.get_line_edit()
	if line_edit.has_focus():
		index_input.apply()
		line_edit.release_focus()
	for prop in prop_inputs.values():
		prop.lose_focus_if_has()
	
func load_subaction_data(frame:int, data:Dictionary):
	subaction_data = data
	index_input.set_value_no_signal(frame)
	if data.keys().has("SubActionScript"):
		real_script = subaction_data['SubActionScript']
		var short_script = real_script.trim_prefix(SUB_ACTIONS_PATH).trim_prefix("SubAct_").trim_suffix(".gd")
		for n in range(script_drop_options.item_count):
			if script_drop_options.get_item_text(n) == short_script:
				script_drop_options.select(n)
		_build_props_for_script(real_script)

func save_page_data():
	var dict = {}
	dict['SubActionScript'] = real_script
	for prop_i:SubActionPropInputControl in prop_inputs.values():
		var val = prop_i.get_prop_value()
		if val:
			dict[prop_i.get_prop_name()] = val
	return dict

func script_selected(index:int):
	var script_name = script_drop_options.get_item_text(index)
	_build_props_for_script(SUB_ACTIONS_PATH + "SubAct_" + script_name + ".gd")

func _build_props_for_script(script_name):
	real_script = script_name
	var script:BaseSubAction = load(real_script).new()
	var required_props =  script.get_required_props()
	for child in prop_inputs.values():
		child.queue_free()
	prop_inputs.clear()
	for prop_name in required_props.keys():
		create_prop_input(prop_name, required_props[prop_name])
	for extr_prop_key in subaction_data.keys():
		if required_props.has(extr_prop_key):
			continue
		if extr_prop_key == "SubActionScript":
			continue
		create_prop_input(extr_prop_key, BaseSubAction.SubActionPropType.StringVal, true)
		

func create_prop_input(prop_name:String, prop_type, is_unknown:bool=false):
	var new_prop:SubActionPropInputControl = premade_option_prop_input.duplicate()
	props_container.add_child(new_prop)
	new_prop.visible = true
	prop_inputs[prop_name] = new_prop
	var prop_value = subaction_data.get(prop_name, null)
	new_prop.set_prop(prop_name, prop_type, prop_value, is_unknown)
	
func _damage_input_focused(prop_name, force_option:String=''):
	var prop_input = prop_inputs.get(prop_name, null)
	var option_button:OptionButton = prop_input.get_child(1)
	var current_option = force_option
	if current_option == '' and option_button.selected >= 0:
		current_option = option_button.get_item_text(option_button.selected)
	# Reload and rebuild options
	option_button.clear()
	var selected_index = -1
	if prop_input:
		var damage_keys = PageEditControl.Instance.get_damage_datas().keys()
		if damage_keys.size() != 0:
			for damage_key in damage_keys:
				option_button.add_item(damage_key)
				if damage_key == current_option:
					selected_index = option_button.item_count - 1
		else:
			option_button.add_item("No Damage Datas")
			selected_index = 0
	option_button.select(selected_index)
	
func _target_input_focused(prop_name, force_option:String=''):
	var prop_input = prop_inputs.get(prop_name, null)
	var option_button:OptionButton = prop_input.get_child(1)
	var current_option = force_option
	if current_option == '' and option_button.selected >= 0:
		current_option = option_button.get_item_text(option_button.selected)
	# Reload and rebuild options
	option_button.clear()
	var selected_index = -1
	if prop_input:
		var keys = PageEditControl.Instance.get_target_params().keys()
		if keys.size() != 0:
			for key in keys:
				option_button.add_item(key)
				if key == current_option:
					selected_index = option_button.item_count - 1
		else:
			option_button.add_item("No Target Params")
			selected_index = 0
	option_button.select(selected_index)

static func get_sub_actions_scripts():
	var list = []
	if MainRootNode.action_libary.loaded:
		_search_for_actions(SUB_ACTIONS_PATH, list)
	else:
		printerr("SubActionEntryControl.get_sub_actions_scripts: Actions not loaded")
	return list

static func _search_for_actions(path, list):
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file:String = dir.get_next()
		while file != "":
			var full_path = path+file
			if dir.current_is_dir(): _search_for_actions(full_path, list)
			elif file.begins_with("SubAct_") and file.ends_with(".gd"): 
				list.append(file.trim_prefix("SubAct_").trim_suffix(".gd"))
			file = dir.get_next()
