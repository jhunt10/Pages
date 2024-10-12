class_name SubEffectEntryControl
extends Control

static var SUB_ACTIONS_PATH = "res://assets/Scripts/Effects/SubEffects/"

signal index_changed

@onready var script_drop_options:LoadedOptionButton = $VBoxContainer/ScriptInput/LoadedOptionButton
@onready var key_line_edit:LineEdit = $VBoxContainer/HBoxContainer/KeyLineEdit
@onready var main_container:VBoxContainer = $VBoxContainer
@onready var props_container:VBoxContainer = $VBoxContainer/PropsContainer
@onready var premade_option_prop_input:SubEffectPropInputControl = $VBoxContainer/SubEffectPropertyControl

var prop_inputs:Dictionary = {}
var real_script:String = ''
var subeffect_data:Dictionary = {}
var resize:bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	script_drop_options.item_selected.connect(script_selected)
	script_drop_options.get_options_func = get_sub_effects_scripts
	premade_option_prop_input.visible = false

func on_index_lose_focus():
	index_changed.emit()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if resize:
		var new_size = Vector2i(self.size.x, main_container.size.y + 16) 
		#printerr("Setting Script Edit Entry Size: %s | %s" % [self.size, new_size])
		self.custom_minimum_size = new_size
		self.update_minimum_size()
		resize = false
	
func lose_focus_if_has():
	if key_line_edit.has_focus():
		key_line_edit.release_focus()
	for prop in prop_inputs.values():
		prop.lose_focus_if_has()
	
func load_subeffect_data(key:String, data:Dictionary):
	subeffect_data = data
	key_line_edit.text = key
	if data.keys().has("SubEffectScript"):
		real_script = subeffect_data['SubEffectScript']
		var short_script = real_script.trim_prefix(SUB_ACTIONS_PATH).trim_prefix("SubEffect_").trim_suffix(".gd")
		script_drop_options.load_options(short_script)
		_build_props_for_script(real_script)

func save_effect_data():
	var dict = {}
	dict['SubEffectScript'] = real_script
	for prop_i:SubEffectPropInputControl in prop_inputs.values():
		var val = prop_i.get_prop_value()
		if val:
			dict[prop_i.get_prop_name()] = val
	return dict

func script_selected(index:int):
	var script_name = script_drop_options.get_item_text(index)
	_build_props_for_script(SUB_ACTIONS_PATH + "SubEffect_" + script_name + ".gd")

func _build_props_for_script(script_name):
	real_script = script_name
	var sub_effect:BaseSubEffect = EffectLibary.get_sub_effect_script(script_name)
	var required_props = sub_effect.get_required_props()
	for child in prop_inputs.values():
		child.queue_free()
	prop_inputs.clear()
	for prop_name in required_props.keys():
		create_prop_input(prop_name, required_props[prop_name])
	for extr_prop_key in subeffect_data.keys():
		if required_props.has(extr_prop_key):
			continue
		if extr_prop_key == "SubEffectScript":
			continue
		create_prop_input(extr_prop_key, BaseSubEffect.SubEffectPropTypes.StringVal, true)
	resize = true
		

func create_prop_input(prop_name:String, prop_type, is_unknown:bool=false):
	var new_prop:SubEffectPropInputControl = premade_option_prop_input.duplicate()
	props_container.add_child(new_prop)
	new_prop.visible = true
	prop_inputs[prop_name] = new_prop
	var prop_value = subeffect_data.get(prop_name, null)
	var enum_options = []
	if prop_type == BaseSubEffect.SubEffectPropTypes.EnumOptions:
		var sub_effect:BaseSubEffect = EffectLibary.get_sub_effect_script(real_script)
		var options_dict = sub_effect.get_enum_option_values()
		enum_options = options_dict.get(prop_name, [])
		var t = true
	new_prop.set_prop(prop_name, prop_type, prop_value, is_unknown, enum_options)

static func get_sub_effects_scripts():
	var list = []
	if MainRootNode.effect_libary.loaded:
		_search_for_effects(SUB_ACTIONS_PATH, list)
	else:
		printerr("SubEffectEntryControl.get_sub_effects_scripts: Effects not loaded")
	return list

static func _search_for_effects(path, list):
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file:String = dir.get_next()
		while file != "":
			var full_path = path+file
			if dir.current_is_dir(): _search_for_effects(full_path, list)
			elif file.begins_with("SubEffect_") and file.ends_with(".gd"): 
				list.append(file.trim_prefix("SubEffect_").trim_suffix(".gd"))
			file = dir.get_next()
