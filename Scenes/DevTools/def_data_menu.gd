class_name DefDataMenu
extends Control

@export var instance_selector_button:LoadedOptionButton
@export var def_box:RichTextLabel
@export var data_box:RichTextLabel
@export var stats_box:FullStatDisplayControl

var inst_to_lib_mapping:Dictionary = {}

func _ready() -> void:
	instance_selector_button.get_options_func = get_load_options
	instance_selector_button.item_selected.connect(on_instance_selected)

func on_instance_selected(index):
	var id = instance_selector_button.get_current_option_text()
	var lib_key = inst_to_lib_mapping.get(id, '')
	var thing = null
	if lib_key == "Actor":
		thing = ActorLibrary.Instance.get_actor(id)
	if lib_key == "Item":
		thing = ItemLibrary.Instance.get_item(id)
	if lib_key == "Effect":
		thing = EffectLibrary.Instance.get_effect(id)
	if thing:
		set_object(thing)
	
func set_object(thing):
	def_box.text = format_dict_to_string(thing._def)
	data_box.text = format_dict_to_string(thing._data)
	
	if thing is BaseActor:
		stats_box.set_actor(thing)
		

func get_load_options()->Array:
	var out_list = []
	out_list.append("---- Actors ----")
	for obj_id in ActorLibrary.Instance._loaded_objects.keys():
		out_list.append(obj_id)
		inst_to_lib_mapping[obj_id] = "Actor"
	out_list.append("---- Items ----")
	for obj_id in ItemLibrary.Instance._loaded_objects.keys():
		out_list.append(obj_id)
		inst_to_lib_mapping[obj_id] = "Item"
	out_list.append("---- Effects ----")
	for obj_id in EffectLibrary.Instance._loaded_objects.keys():
		out_list.append(obj_id)
		inst_to_lib_mapping[obj_id] = "Effect"
	return out_list
	

func format_dict_to_string(dict:Dictionary)->String:
	var raw_string = str(dict)
	var indent_level = 0
	var in_list = false
	var in_super_list = false
	var out_string = ''
	var last_char = ''
	for char in raw_string:
		if char == '{':
			indent_level += 1
			out_string += char
			out_string += _new_line(indent_level)
		elif char == '}':
			indent_level -= 1
			out_string += _new_line(indent_level)
			out_string += char
		elif char == ',':
			out_string += char
			if not in_list or last_char == '"':
				out_string += _new_line(indent_level)
		elif char == '[':
			out_string += char
			in_list = true
			if last_char == '[':
				in_super_list = true
		elif char == ']':
			out_string += char
			if in_super_list:
				if last_char == ']':
					in_super_list = false
			elif last_char == '"':
				indent_level -= 1
					
			if not in_super_list:
				in_list = false
		elif char == '"' and in_list:
			if last_char == '[':
				indent_level += 1
				out_string += _new_line(indent_level)
				out_string += char
			else:
				out_string += char
			
		else:
			out_string += char
		last_char = char
	return out_string

func _new_line(indents:int)->String:
	var line = "\n"
	for i in range(indents):
		line += "\t"
	return line
			
